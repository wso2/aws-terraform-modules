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

  availability_zones         = var.availability_zones
  private_subnet_cidr_blocks = var.private_subnet_cidr_blocks
  public_subnet_cidr_blocks  = var.public_subnet_cidr_blocks

  kubernetes_version   = var.kubernetes_version
  admin_principal_arns = var.admin_principal_arns

  endpoint_public_access = var.endpoint_public_access
  public_access_cidrs    = var.public_access_cidrs

  eks_addons = var.eks_addons

  node_instance_types = var.node_instance_types
  node_min_size       = var.node_min_size
  node_max_size       = var.node_max_size
  node_desired_size   = var.node_desired_size
  node_capacity_type  = var.node_capacity_type

  security_group_rules = var.security_group_rules

  enable_bastion        = var.enable_bastion
  bastion_instance_type = var.bastion_instance_type

  enable_secrets_encryption = var.enable_secrets_encryption
  enabled_cluster_log_types = var.enabled_cluster_log_types
  log_retention_in_days     = var.log_retention_in_days
  enable_vpc_flow_logs      = var.enable_vpc_flow_logs
  enable_artifact_archiving = var.enable_artifact_archiving

  argo_namespace                           = var.argo_namespace
  workflow_controller_service_account_name = var.workflow_controller_service_account_name

  eso_secretsmanager_key_prefix = var.eso_secretsmanager_key_prefix
}

# exec-based auth: avoids kubernetes_manifest's silent token-drop bug with
# static tokens.
provider "kubernetes" {
  host                   = module.cluster.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.cluster.eks_base64_encoded_ca_cert)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.cluster.eks_cluster_name, "--region", var.region]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.cluster.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.cluster.eks_base64_encoded_ca_cert)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.cluster.eks_cluster_name, "--region", var.region]
    }
  }
}

# lazy_load defers client construction past eager Configure()-time -
# without it, kubectl_manifest resources ran against whatever kubeconfig
# context happened to be ambient on the machine.
provider "kubectl" {
  host                   = module.cluster.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.cluster.eks_base64_encoded_ca_cert)
  load_config_file       = false
  lazy_load              = true

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.cluster.eks_cluster_name, "--region", var.region]
  }
}

module "apps" {
  source = "./apps"

  namespace        = var.namespace
  extra_namespaces = var.extra_namespaces
  config_maps      = var.config_maps

  tunnel_client_identities = var.tunnel_client_identities
  nats_client_identities   = var.nats_client_identities

  argo_workflows_chart_version = var.argo_workflows_chart_version
  argo_events_chart_version    = var.argo_events_chart_version
  nats_chart_version           = var.nats_chart_version
  argo_helm_repo               = var.argo_helm_repo
  nats_helm_repo               = var.nats_helm_repo

  argo_workflows_values = var.argo_workflows_values
  argo_events_values    = var.argo_events_values
  nats_values           = var.nats_values

  install_cert_manager       = var.install_cert_manager
  cert_manager_chart_version = var.cert_manager_chart_version
  cert_manager_helm_repo     = var.cert_manager_helm_repo
  cert_manager_namespace     = var.cert_manager_namespace

  install_traefik       = var.install_traefik
  traefik_chart_version = var.traefik_chart_version
  traefik_helm_repo     = var.traefik_helm_repo
  traefik_values        = var.traefik_values
  traefik_namespace     = var.traefik_namespace

  nats_server_external_dns_names = var.nats_server_external_dns_names

  manifest_files = var.manifest_files

  install_external_secrets = var.install_external_secrets
  eso_chart_version        = var.eso_chart_version
  eso_helm_repo            = var.eso_helm_repo
  eso_namespace            = var.eso_namespace

  # The one apps input NOT exposed as this module's own variable - wired
  # straight from the sibling cluster module's output instead, same as
  # environments/control-plane/main.tf's identical line. Every other
  # cluster output (workflow_controller_artifacts_role_arn/artifact_bucket_name
  # etc.) only ever gets consumed INSIDE a caller-authored Helm values
  # heredoc (argo_workflows_values), not as a discrete apps variable, so
  # there's no equivalent 1:1 wiring to replicate generically here - the
  # caller still supplies argo_workflows_values itself, referencing
  # module.cluster outputs from further up if using ./cluster and ./apps
  # directly, or from this module's own outputs.tf if composing through it.
  eso_role_arn = module.cluster.eso_role_arn

  kubectl_manifest_files = var.kubectl_manifest_files

  depends_on = [module.cluster]
}
