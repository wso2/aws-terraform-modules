# -------------------------------------------------------------------------------------
#
# Copyright (c) 2023, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
#
# This software is the property of WSO2 LLC. and its suppliers, if any.
# Dissemination of any information or reproduction of any material contained
# herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
# You may not alter or remove any copyright or other notice from copies of this content.
#
# --------------------------------------------------------------------------------------

locals {
  eks_cluster_name_key = join("", ["k8s.io/cluster-autoscaler/", var.eks_cluster_name])
  ng_tags              = merge(var.default_tags, { (local.eks_cluster_name_key) : "enabled", "k8s.io/cluster-autoscaler/enabled" : true })
}
