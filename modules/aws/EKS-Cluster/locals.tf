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
  rt_name         = join("-", [var.route_table_abbreviation, var.eks_cluster_name, "snet"])
  rt_tags         = merge(var.tags, { Name : local.rt_name })
  oidc_thumbprint = length(var.oidc_thumbprint_override) > 0 ? var.oidc_thumbprint_override : [data.tls_certificate.tls.certificates[0].sha1_fingerprint]
}
