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

resource "aws_fms_policy" "fms_policy" {
  name                               = join("-", [var.project, var.environment, var.application, var.region, "fms-policy"])
  exclude_resource_tags              = var.exclude_resource_tags
  remediation_enabled                = var.enable_remediation
  resource_type                      = var.resource_type
  resource_type_list                 = var.resource_type_list
  delete_all_policy_resources        = var.delete_all_policy_resources
  delete_unused_fm_managed_resources = var.delete_unused_fm_managed_resources

  dynamic "include_map" {
    for_each = length(var.included_account_list) > 0 || length(var.included_organizational_unit_list) > 0 ? [1] : []
    content {
      account = var.included_account_list
      orgunit = var.included_organizational_unit_list
    }
  }

  security_service_policy_data {
    type = var.security_service_policy_data_type

    managed_service_data = var.managed_service_data
  }

  tags = var.tags
}
