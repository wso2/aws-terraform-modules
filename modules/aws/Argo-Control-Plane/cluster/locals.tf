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
  name_prefix = join("-", [var.project, var.application, var.environment, var.region])

  vpc_name = join("-", [local.name_prefix, "vpc"])
  vpc_tags = merge(var.tags, { Name = local.vpc_name })

  igw_name = join("-", [local.name_prefix, "igw"])
  igw_tags = merge(var.tags, { Name = local.igw_name })

  cluster_sg_name = join("-", [local.name_prefix, "sg"])
  cluster_sg_tags = merge(var.tags, { Name = local.cluster_sg_name })

  eks_cluster_name      = join("-", [local.name_prefix, "eks"])
  eks_cluster_role_name = join("-", [local.name_prefix, "eks-cluster-role"])

  ebs_csi_role_name = join("-", [local.name_prefix, "ebs-csi-role"])

  eso_role_name   = join("-", [local.name_prefix, "eso-role"])
  eso_policy_name = join("-", [local.name_prefix, "eso-secretsmanager"])

  eks_secrets_kms_alias = join("-", [local.name_prefix, "eks-secrets"])

  flow_log_role_name   = join("-", [local.name_prefix, "flow-log-role"])
  flow_log_policy_name = join("-", [local.name_prefix, "flow-log-policy"])
  flow_log_tags        = merge(var.tags, { Name = join("-", [local.name_prefix, "flow-log"]) })

  artifact_bucket_name = join("-", [local.name_prefix, "argo-logs"])

  # No "-role" suffix: it would exceed IAM's 64-character role name limit.
  workflow_controller_artifacts_role_name   = join("-", [local.name_prefix, "workflow-artifacts"])
  workflow_controller_artifacts_policy_name = join("-", [local.name_prefix, "workflow-artifacts-s3"])

  node_role_name       = join("-", [local.name_prefix, "node-role"])
  node_group_name      = join("-", [local.name_prefix, "system"])
  launch_template_name = join("-", [local.name_prefix, "node"])
  launch_template_tags = merge(var.tags, { Name = local.launch_template_name })

  bastion_role_name    = join("-", [local.name_prefix, "bastion-role"])
  bastion_profile_name = join("-", [local.name_prefix, "bastion-profile"])
  bastion_sg_name      = join("-", [local.name_prefix, "bastion-sg"])
  bastion_sg_tags      = merge(var.tags, { Name = local.bastion_sg_name })
  bastion_name         = join("-", [local.name_prefix, "bastion"])
  bastion_tags         = merge(var.tags, { Name = local.bastion_name })
}
