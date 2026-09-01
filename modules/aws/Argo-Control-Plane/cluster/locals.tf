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
# Naming/tagging convention matches the repo's other modules (see VPC,
# EKS-Cluster, EC2-Instance, Security-Group): a shared name_prefix built
# via join("-", [project, application, environment, region]), then one
# named local per singular resource, tagged via merge(var.tags, { Name = ... }).
# For-each-keyed resources (per-AZ subnets/route tables/NAT/EIP) still build
# their per-key name inline in main.tf from local.name_prefix, since a
# static local can't carry a for_each key.
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
