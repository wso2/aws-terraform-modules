#!/bin/bash
# -------------------------------------------------------------------------------------
#
# Copyright (c) 2026, WSO2 LLC. (https://www.wso2.com) All Rights Reserved.
#
# WSO2 LLC. licenses this file to you under the Apache License,
# Version 2.0 (the "License"); you may not use this file except
# in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied. See the License for the
# specific language governing permissions and limitations
# under the License.
#
# --------------------------------------------------------------------------------------

show_usage_and_exit() {
    echo
    echo "Usage: bash $(basename "$0") -c [CONFIGFILE] -l [LAYER]"
    echo "Mandatory arguments:"
    echo "     -c - the configuration file to use, relative to the aws-orphan-resources directory."
    echo "          e.g. terraform/aws/conf/rnd/orphan-scanner.rnd.conf.tfvars"
    echo "     -l - deployment layer to apply (scanner)."
    echo "          e.g. -l scanner"
    echo "     -h - display this help and exit"
    exit 0
}

# Colour schema
RED='\033[01;31m'
GREEN='\033[01;32m'
DEFAULT='\033[00m'
BOLD='\033[1m'
YELLOW='\033[0;33m'

hr() { printf '\e[1m%*s\e[0m\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -; }

print_header() {
    echo; echo; hr; echo $'\e[1m'"${1}"$'\e[0m'; hr; echo
}

# Check for required tools
command -v terraform >/dev/null 2>&1 || { echo -e >&2 "${RED}Terraform not found.${DEFAULT}"; exit 4; }
command -v aws >/dev/null 2>&1 || { echo -e >&2 "${RED}AWS CLI not found.${DEFAULT}"; exit 4; }

SECONDS=0
root_path=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
main_conf_file=""
layer_flag=""

while getopts :c:l:h FLAG; do
    case $FLAG in
        c) main_conf_file=$OPTARG ;;
        l) layer_flag=$OPTARG ;;
        h) show_usage_and_exit ;;
        \?) show_usage_and_exit ;;
    esac
done

if [[ "$main_conf_file" == "" ]]; then
    echo -e "${RED}A configuration file was not specified${DEFAULT}"
    show_usage_and_exit
fi

main_conf_file="${root_path}/${main_conf_file}"

if [[ ! -f ${main_conf_file} ]]; then
    echo -e "${RED}Config file not found: ${main_conf_file}${DEFAULT}"; exit 1
fi

# Derive secrets file
conf_filename_without_ext="${main_conf_file%.*}"
secret_conf_file="${conf_filename_without_ext}.secrets.tfvars"

if [[ ! -f ${secret_conf_file} ]]; then
    echo -e "${RED}Secrets file not found: ${secret_conf_file}${DEFAULT}"; exit 1
fi

echo -e "Using configuration ${GREEN}${main_conf_file}  ${DEFAULT}"
echo -e "Using secrets configuration ${GREEN}${secret_conf_file}  ${DEFAULT}"

# --- READ CONFIGURATION VALUES ---
get_var() { grep -E "^[ ]*$1[ ]+=" "$2" | awk '{$1=$2=""; gsub(/^[ \t]+|[ \t]+$/,"",$0); print $0}' | tr -d '"'; }

deployment_project=$(get_var "project" "$main_conf_file")
deployment_environment=$(get_var "deployment_environment" "$main_conf_file")
deployment_location=$(get_var "aws_region" "$main_conf_file")

# Use -l flag if provided, otherwise fall back to deployment_layer in the conf file
if [[ -n "$layer_flag" ]]; then
    deployment_layer="$layer_flag"
else
    deployment_layer=$(get_var "deployment_layer" "$main_conf_file")
fi

if [[ -z "$deployment_layer" ]]; then
    echo -e "${RED}Deployment layer not specified. Use -l scanner${DEFAULT}"
    show_usage_and_exit
fi

deployment_path="$deployment_layer"

#  AWS BACKEND CONFIG
backend_bucket=$(get_var "backend_s3_bucket" "$main_conf_file")
backend_region=$(get_var "backend_region" "$main_conf_file")

# Default backend region to deployment location if missing
if [[ -z "$backend_region" ]]; then backend_region="$deployment_location"; fi

key="${deployment_project}.${deployment_layer}.${deployment_location}.terraform.tfstate"
aws_profile=$(get_var "aws_profile" "$secret_conf_file")

echo
echo -e "Project        : ${BOLD}${deployment_project}${DEFAULT}"
echo -e "Environment    : ${BOLD}${deployment_environment}${DEFAULT}"
echo -e "Region         : ${BOLD}${deployment_location}${DEFAULT}"
echo -e "Layer          : ${BOLD}${deployment_layer}${DEFAULT}"
echo -e "Code Path      : ${BOLD}terraform/aws/deployments/${deployment_path}${DEFAULT}"
if [[ -n "$backend_bucket" ]]; then
    echo -e "State Bucket   : ${BOLD}${backend_bucket}${DEFAULT}"
    echo -e "State Key      : ${BOLD}${key}${DEFAULT}"
else
    echo -e "State Backend  : ${BOLD}default (no backend_s3_bucket set - using local / your own backend)${DEFAULT}"
fi
if [[ -n "$aws_profile" ]]; then echo -e "AWS Profile    : ${BOLD}${aws_profile}${DEFAULT}"; fi
echo

pattern_location="${root_path}/terraform/aws/deployments/${deployment_path}"

if [ -f "${pattern_location}/.terraform/terraform.tfstate" ] ; then
    rm "${pattern_location}/.terraform/terraform.tfstate"
fi

echo "Changing directory to: ${pattern_location}"
pushd "${pattern_location}" > /dev/null || { echo -e "${RED}Error: Directory not found: ${pattern_location}${DEFAULT}"; exit 1; }

    if [[ -n "$aws_profile" ]]; then
        echo -e "${BOLD}Setting AWS Profile to ${aws_profile}...${DEFAULT}"
        export AWS_PROFILE="$aws_profile"
    fi

    echo -e "${BOLD}Verifying AWS Identity...${DEFAULT}"
    if ! aws sts get-caller-identity > /dev/null 2>&1; then
        echo -e "${RED}Failed to authenticate with AWS. Check credentials.${DEFAULT}"
        exit 2
    fi
    echo -e "${GREEN}AWS Identity verified.${DEFAULT}"

    if [[ -n "$backend_bucket" ]]; then
        echo -e "${BOLD}Initializing Terraform with S3 remote backend...${DEFAULT}"

        # No backend is committed to the Terraform code, so consumers can bring
        # their own. When backend_s3_bucket is set, declare an S3 backend at init
        # time via this git-ignored override file (*_override.tf) and inject the
        # bucket/key/region below. The state bucket must already exist.
        cat > backend_override.tf <<'EOF'
terraform {
  backend "s3" {}
}
EOF

        terraform init \
            -upgrade \
            -backend-config="bucket=${backend_bucket}" \
            -backend-config="key=${key}" \
            -backend-config="region=${backend_region}" \
            -backend-config="encrypt=true"
    else
        echo -e "${BOLD}Initializing Terraform (no backend_s3_bucket set - local state / your own backend)...${DEFAULT}"
        terraform init -upgrade
    fi
    tf_init_ec=$?
    echo

    if [ $tf_init_ec != 0 ]; then
        echo -e "${RED}Backend initialization failed.${DEFAULT}"
        exit 3
    fi

    echo -e "${BOLD}Validating Terraform scripts...${DEFAULT}"
    if ! terraform validate; then
        echo -e "${RED}Validation failed.${DEFAULT}"
        exit 3
    fi

    echo -e "${YELLOW}Checking Terraform formatting...${DEFAULT}"
    if ! terraform fmt -check -recursive; then
        echo -e "${RED}Formatting check failed. Run 'terraform fmt --recursive' locally and re-run deploy.${DEFAULT}"
        exit 3
    fi

    print_header "Deploying ${deployment_project} - ${deployment_environment}"
    echo

    terraform apply \
        -var-file="${main_conf_file}" \
        -var-file="${secret_conf_file}" \
        -var "deployment_layer=${deployment_layer}"
    tf_apply_ec=$?

    if [ $tf_apply_ec != 0 ]; then
        echo -e "${RED}Apply failed.${DEFAULT}"
        exit 3
    fi
    popd > /dev/null 2>&1 || exit

hr
echo
duration=$SECONDS
echo -e "${GREEN}Completed execution in ${YELLOW}$(( duration / 60 ))m $(( duration % 60 ))s.${DEFAULT}"
