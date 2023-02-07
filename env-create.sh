#!/bin/bash
# -------------------------------------------------------------------------------------
#
# Copyright (c) 2020, WSO2 Inc. (http://www.wso2.com). All Rights Reserved.
#
# This software is the property of WSO2 Inc. and its suppliers, if any.
# Dissemination of any information or reproduction of any material contained
# herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
# You may not alter or remove any copyright or other notice from copies of this content.
#
# --------------------------------------------------------------------------------------
# =====================================================================================================================
# Functions
# =====================================================================================================================

# Show usage of the script and exit with a zero code
#
show_usage_and_exit() {
    echo
    echo "Usage: bash $(basename "$0") -c [CONFIGFILE]"
    echo "Create a deployment using the artifacts."
    echo "This script creates a deployment based on the information provided by"
    echo "a configuration file. The configuration file to use should be passed "
    echo "in as an argument. Use flag \"-h\" to see the proper usage of the "
    echo "script."
    echo
    echo "Mandatory argument:"
    echo "     -c - the configuration file to use. The script will derive all "
    echo "          other configuration file locations from the values defined"
    echo "          in this file"
    echo
    echo "     -h - display this help and exit"
    echo
    echo
    echo "Exit status:"
    echo "     0 if OK,"
    echo "     1 if minor problems (e.g. cannot access configuration file),"
    echo "     2 if connectivity problems (e.g. cannot access AZ APIs),"
    echo "     3 if Terraform and other tools fail. Refer their guides on detailed "
    echo "        exit codes."
    echo "     4 if required tools cannot be found (e.g. cannot use az command),"
    echo
    echo
    exit 0
}

# Colour schema for logs
RED='\033[01;31m'
GREEN='\033[01;32m'
DEFAULT='\033[00m'
BOLD='\033[1m'
UNDERLINE='\033[4m'
YELLOW='\033[0;33m'

# Print a horizontal line across the terminal irrespective of the terminal width
# The character used is a dash '-'
#
hr() {
    printf '\e[1m%*s\e[0m\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
}

# Print a check mark (✔) and terminates the line
#
print_checkmark() {
    echo -en $'\e[1m \u2714\e[0m'
    echo
}

# Prints a header message between two horizontal lines
#
# $1 - Message to be printed
#
print_header() {
    echo
    echo
    hr
    echo $'\e[1m'"${1}"$'\e[0m'
    hr
    echo
}

# =====================================================================================================================
# Start Script Execution
# =====================================================================================================================

# Check for required tools
command -v terraform >/dev/null 2>&1 || {
    echo -e >&2 "${RED}Terraform cannot be found. Follow https://learn.hashicorp.com/terraform/getting-started/install.html to install Terraform."
    echo -e >&2 "Aborting...${DEFAULT}"
    exit 4
}
command -v az >/dev/null 2>&1 || {
    echo -e >&2 "${RED}AZ CLI cannot be found. Follow https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest."
    echo -e >&2 "Aborting...${DEFAULT}"
    exit 4
}

# Start calculating time taken to execute script
SECONDS=0

root_path=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# Mandatory flag -c value will be assigned to this
main_conf_file=""
# Parse flags
while getopts c:hi FLAG; do
    case $FLAG in
        c)
            main_conf_file=$OPTARG
            ;;
        h)
            show_usage_and_exit
            ;;
        i)
            execute_initialization=true
            ;;
        \?)
            show_usage_and_exit
    esac
done

# Sanitize input
if [[ "$main_conf_file" == "" ]]; then
   echo -e "${RED}A configuration file was not specified${DEFAULT}"
   show_usage_and_exit
fi

# Construct the conf file path
main_conf_file="${root_path}/${main_conf_file}"

# Check if the specified config file exists
if [[ ! -f ${main_conf_file} ]]; then
   echo -e "${RED}The configuration file specified was not found: ${main_conf_file}${DEFAULT}"
   echo
   exit 1
fi

# Provided config file name without the extension (exclude the tfvars part of the file string)
conf_filename_without_ext="${main_conf_file%.*}"

# Derive the secrets file name
secret_conf_file="${conf_filename_without_ext}.secrets.tfvars"

# Check for existence of secrets file
if [[ ! -f ${secret_conf_file} ]]; then
   echo -e "${RED}The secrets file, ${secret_conf_file} was not found. Please follow the${DEFAULT}"
   echo -e "${RED}README to create a secrets config file to store sensitive configuration.${DEFAULT}"
   echo
   exit 1
fi

echo -e "Using configuration ${GREEN}${main_conf_file}  ${DEFAULT}"
echo -e "Using secrets configuration ${GREEN}${secret_conf_file}  ${DEFAULT}"

# Read basic values from the configuration file
deployment_project=$(grep -E "^[ ]*project[ ]+=" $main_conf_file | awk '{$1=$2=""; gsub(/^[ \t]+|[ \t]+$/,"",$0); print $0}' | tr -d '"')
deployment_environment=$(grep -E "^[ ]*environment[ ]+=" $main_conf_file | awk '{$1=$2=""; gsub(/^[ \t]+|[ \t]+$/,"",$0); print $0}' | tr -d '"')
deployment_location=$(grep -E "^[ ]*availability_zone[ ]+=" $main_conf_file | awk '{$1=$2=""; gsub(/^[ \t]+|[ \t]+$/,"",$0); print $0}' | tr -d '"')

# Reading values related to azurerm backend for terraform
backend_storage_account_name=$(grep -E "^[ ]*backend_storage_account_name[ ]+=" $main_conf_file | awk '{$1=$2=""; gsub(/^[ \t]+|[ \t]+$/,"",$0); print $0}' | tr -d '"')
backend_container_name=$(grep -E "^[ ]*backend_container_name[ ]+=" $main_conf_file | awk '{$1=$2=""; gsub(/^[ \t]+|[ \t]+$/,"",$0); print $0}' | tr -d '"')
key="${deployment_project}.${deployment_environment}.terraform.tfstate"

# Read Client Secret key from $secret_conf_file for terraform backend
backend_key=$(grep -E "^[ ]*backend_key[ ]+=" $secret_conf_file | awk '{$1=$2=""; gsub(/^[ \t]+|[ \t]+$/,"",$0); print $0}' | tr -d '"')

#print_header "Initializing deployment..."

echo
echo -e "Project            : ${BOLD}${deployment_project}${DEFAULT}"
echo -e "Environment        : ${BOLD}${deployment_environment}${DEFAULT}"
echo -e "Availability Zone  : ${BOLD}${deployment_location}${DEFAULT}"
echo

# Directory where Terraform deployment is
pattern_location="${root_path}/terraform/deployments/${deployment_environment}"

## Export ARM_ACCESS_KEY to use for the azurerm terraform remote backend
export ARM_ACCESS_KEY=${backend_key}

# =====================================================================================================================

# Start the creation process
pushd "${pattern_location}" > /dev/null 2>&1  || exit

   if [[ $execute_initialization == "true" ]]; then

     echo -e "${BOLD}Getting any updates for terraform modules...${DEFAULT}"
     terraform get

     echo -e "${BOLD}Initializing Terraform remote backend...${DEFAULT}"

     # Adding values such as region and bucket here because interpolation at
     # backend definition is not allowed

     echo "runs"
     terraform init -backend-config="storage_account_name=${backend_storage_account_name}" \
                    -backend-config="container_name=${backend_container_name}" \
                    -backend-config="key=${key}"

     # Collect exit code
     tf_init_ec=$?
     echo
   else
     tf_init_ec=0
   fi

   # Cannot continue without the backend being initialized
   if [ $tf_init_ec != 0 ]; then
       echo -e "${RED}Backend initialization failed.${DEFAULT}"
       echo "\`terraform init\` exit code $tf_init_ec"
       exit 3
   fi

   echo
   echo -e "${BOLD}Validating Terraform scripts files.${DEFAULT}"
   terraform validate
   tf_validate_ec=$?

   # Cannot continue if validation fails
   if [ $tf_validate_ec != 0 ]; then
      echo -e "${RED}Terraform script validation failed.${DEFAULT}"
      echo "\`terraform validation\` exit code $tf_validate_ec"
      exit 3
   fi

   echo
   echo -e "${YELLOW}Formatting Terraform source files.${DEFAULT}"
   terraform fmt

# =====================================================================================================================
   print_header "Creating Infrastructure for Choreo ${deployment_environment}"
   echo
   terraform apply -var-file="${secret_conf_file}" -var-file="${main_conf_file}"
   tf_apply_ec=$?

   if [ $tf_apply_ec != 0 ]; then
      echo -e "${RED}Environment creation failed.${DEFAULT}"
      echo "\`terraform apply\` exit code $tf_apply_ec"
      exit 3
   fi
   popd > /dev/null 2>&1 || exit

# =====================================================================================================================

# Unset credential variables so that these values will not be available after the required period
unset ARM_ACCESS_KEY

hr
echo
echo
duration=$SECONDS
echo -e "${GREEN}Completed execution in ${YELLOW}$(( ${duration} / 60 ))m $(( $duration % 60 ))s.${DEFAULT}"
