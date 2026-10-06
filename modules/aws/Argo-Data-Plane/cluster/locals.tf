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

locals {
  name = "${var.project}-${var.application}-${var.environment}"

  # Everything that differs between the two tiers. Tier-scoped resources
  # iterate over this map instead of being written out once per tier.
  tiers = {
    stage = {
      availability_zones       = var.stage_availability_zones
      subnet_cidr_blocks       = var.stage_subnet_cidr_blocks
      public_subnet_cidr_block = var.stage_public_subnet_cidr_block
      node_instance_types      = var.stage_node_instance_types
      node_min_size            = var.stage_node_min_size
      node_max_size            = var.stage_node_max_size
      node_desired_size        = var.stage_node_desired_size
      node_capacity_type       = var.stage_node_capacity_type
      node_extra_policy_json   = var.stage_node_extra_policy_json
      node_taint_value         = null
      security_group_rules     = var.stage_security_group_rules
    }
    prod = {
      availability_zones       = var.prod_availability_zones
      subnet_cidr_blocks       = var.prod_subnet_cidr_blocks
      public_subnet_cidr_block = var.prod_public_subnet_cidr_block
      node_instance_types      = var.prod_node_instance_types
      node_min_size            = var.prod_node_min_size
      node_max_size            = var.prod_node_max_size
      node_desired_size        = var.prod_node_desired_size
      node_capacity_type       = var.prod_node_capacity_type
      node_extra_policy_json   = var.prod_node_extra_policy_json
      node_taint_value         = var.prod_node_taint_value
      security_group_rules     = var.prod_security_group_rules
    }
  }

  # One entry per private subnet, keyed "<tier>/<availability zone>".
  private_subnets = merge([
    for tier, t in local.tiers : {
      for idx, az in t.availability_zones : "${tier}/${az}" => {
        tier              = tier
        availability_zone = az
        cidr_block        = t.subnet_cidr_blocks[idx]
      }
    }
  ]...)

  node_managed_policy_arns = {
    worker = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    cni    = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    ecr    = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  }

  # One entry per (tier, managed policy), keyed "<tier>/<policy>".
  node_policy_attachments = merge([
    for tier in keys(local.tiers) : {
      for name, arn in local.node_managed_policy_arns : "${tier}/${name}" => {
        tier       = tier
        policy_arn = arn
      }
    }
  ]...)

  oidc_issuer = replace(aws_iam_openid_connect_provider.eks.url, "https://", "")

  # "<namespace>:<ServiceAccount>" allowed to assume each IRSA role.
  irsa_service_accounts = merge(
    {
      ebs_csi = "kube-system:ebs-csi-controller-sa"
      eso     = "${var.eso_namespace}:external-secrets"
    },
    {
      for k, v in { workflow_controller_artifacts = "${var.argo_namespace}:${var.workflow_controller_service_account_name}" } :
      k => v if var.enable_artifact_archiving
    },
    { for k, v in var.deploy_identities : "deploy/${k}" => "${v.namespace}:${v.service_account_name}" },
  )

  # vpc-cni/kube-proxy must exist before either node group so nodes can
  # reach Ready; coredns depends on a node group instead, since it needs
  # a node to schedule onto.
  pre_compute_addon_names = ["vpc-cni", "kube-proxy"]
  pre_compute_addons      = { for a in var.eks_addons : a.name => a if contains(local.pre_compute_addon_names, a.name) }
  post_compute_addons     = { for a in var.eks_addons : a.name => a if !contains(local.pre_compute_addon_names, a.name) }
}
