# -------------------------------------------------------------------------------------
#
# Copyright (c) 2025, WSO2 LLC. (https://www.wso2.com) All Rights Reserved.
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

resource "aws_eks_addon" "eks_addon" {
  cluster_name = var.eks_cluster_name
  addon_name   = var.eks_addon_name

  # Conditionally set optional values only if provided
  addon_version               = var.eks_addon_version != null ? var.eks_addon_version : null
  resolve_conflicts_on_update = var.eks_addon_update_conflict != null ? var.eks_addon_update_conflict : null
  resolve_conflicts_on_create = var.eks_addon_update_create != null ? var.eks_addon_update_create : null
  configuration_values        = var.eks_addon_configuration_values != null ? var.eks_addon_configuration_values : null
}

