# -------------------------------------------------------------------------------------
#
# Copyright (c) 2026, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
#
# This software is the property of WSO2 LLC. and its suppliers, if any.
# Dissemination of any information or reproduction of any material contained
# herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
# You may not alter or remove any copyright or other notice from copies of this content.
#
# --------------------------------------------------------------------------------------
#
# Composite entrypoint wiring ./cluster to ./apps in one module call, as an
# ALTERNATIVE to calling the two submodules separately (see README.md).
#
# --------------------------------------------------------------------------------------

module "cluster" {
  source = "./cluster"

  project     = var.project
  environment = var.environment
  region      = var.region
  application = var.application
  tags        = var.tags

  vpc_cidr_block = var.vpc_cidr_block

  kubernetes_version   = var.kubernetes_version
  admin_principal_arns = var.admin_principal_arns

  endpoint_public_access = var.endpoint_public_access
  public_access_cidrs    = var.public_access_cidrs

  eks_addons = var.eks_addons

  stage_availability_zones       = var.stage_availability_zones
  stage_subnet_cidr_blocks       = var.stage_subnet_cidr_blocks
  stage_public_subnet_cidr_block = var.stage_public_subnet_cidr_block
  stage_node_instance_types      = var.stage_node_instance_types
  stage_node_min_size            = var.stage_node_min_size
  stage_node_max_size            = var.stage_node_max_size
  stage_node_desired_size        = var.stage_node_desired_size
  stage_node_capacity_type       = var.stage_node_capacity_type
  stage_security_group_rules     = var.stage_security_group_rules
  stage_node_extra_policy_json   = var.stage_node_extra_policy_json

  prod_availability_zones       = var.prod_availability_zones
  prod_subnet_cidr_blocks       = var.prod_subnet_cidr_blocks
  prod_public_subnet_cidr_block = var.prod_public_subnet_cidr_block
  prod_node_instance_types      = var.prod_node_instance_types
  prod_node_min_size            = var.prod_node_min_size
  prod_node_max_size            = var.prod_node_max_size
  prod_node_desired_size        = var.prod_node_desired_size
  prod_node_capacity_type       = var.prod_node_capacity_type
  prod_security_group_rules     = var.prod_security_group_rules
  prod_node_taint_value         = var.prod_node_taint_value
  prod_node_extra_policy_json   = var.prod_node_extra_policy_json

  enable_bastion        = var.enable_bastion
  bastion_instance_type = var.bastion_instance_type

  eso_secretsmanager_key_prefix = var.eso_secretsmanager_key_prefix
  deploy_identities             = var.deploy_identities

  enable_secrets_encryption = var.enable_secrets_encryption
  enabled_cluster_log_types = var.enabled_cluster_log_types
  log_retention_in_days     = var.log_retention_in_days
  enable_vpc_flow_logs      = var.enable_vpc_flow_logs
  enable_artifact_archiving = var.enable_artifact_archiving

  argo_namespace                           = var.argo_namespace
  workflow_controller_service_account_name = var.workflow_controller_service_account_name
}

# EKS-Cluster's own auth-token data source, same as
# environments/aws-dataplane/main.tf - no exec plugin needed, unlike
# control-plane's composite (see that module's main.tf comment on why it
# uses exec instead). No depends_on = [module.cluster] here on purpose -
# same real bug that environment's own comment on this exact data source
# documents: depending on the WHOLE module forces every one of its
# resources to refresh before this is considered resolved, which can burn
# through this 15-minute token's whole lifetime before it's actually used.
# The `name = module.cluster.eks_cluster_name` argument below already
# creates the correct, narrower implicit dependency.
data "aws_eks_cluster_auth" "this" {
  name = module.cluster.eks_cluster_name
}

provider "kubernetes" {
  host                   = module.cluster.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.cluster.eks_base64_encoded_ca_cert)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = module.cluster.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.cluster.eks_base64_encoded_ca_cert)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

provider "kubectl" {
  host                   = module.cluster.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.cluster.eks_base64_encoded_ca_cert)
  token                  = data.aws_eks_cluster_auth.this.token
  load_config_file       = false
  lazy_load              = true
}

module "apps" {
  source = "./apps"

  namespaces       = var.namespaces
  system_namespace = var.system_namespace

  argo_workflows_chart_version = var.argo_workflows_chart_version
  argo_events_chart_version    = var.argo_events_chart_version
  argo_helm_repo               = var.argo_helm_repo

  argo_workflows_values = var.argo_workflows_values
  argo_events_values    = var.argo_events_values

  install_argocd       = var.install_argocd
  argocd_namespace     = var.argocd_namespace
  argocd_chart_version = var.argocd_chart_version
  argocd_helm_repo     = var.argocd_helm_repo
  argocd_values        = var.argocd_values

  manifest_files = var.manifest_files

  install_external_secrets = var.install_external_secrets
  eso_chart_version        = var.eso_chart_version
  eso_helm_repo            = var.eso_helm_repo
  eso_namespace            = var.eso_namespace

  # The one apps input NOT exposed as this module's own variable - wired
  # straight from the sibling cluster module's output instead, same as
  # environments/aws-dataplane/main.tf's identical line. cluster's other
  # relevant outputs (workflow_controller_artifacts_role_arn/
  # artifact_bucket_name, deploy_identity_role_arns) only ever get consumed
  # INSIDE a caller-authored Helm values heredoc (argo_workflows_values) or
  # a caller-authored ServiceAccount annotation, never as a discrete apps
  # variable, so there's no equivalent 1:1 wiring to replicate generically
  # here - see outputs.tf, which re-exposes those for a caller composing
  # through this module to reference in its own argo_workflows_values.
  eso_role_arn = module.cluster.eso_role_arn

  kubectl_manifest_files  = var.kubectl_manifest_files
  rendered_manifest_files = var.rendered_manifest_files

  depends_on = [module.cluster]
}
