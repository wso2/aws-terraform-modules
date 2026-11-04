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

resource "aws_imagebuilder_distribution_configuration" "imagebuilder_distribution_configuration" {
  name        = join("-", compact([var.project, var.application, var.environment, var.region, var.name, "ib-dist-config"]))
  description = var.description
  tags        = var.tags

  dynamic "distribution" {
    for_each = var.distributions
    content {
      region = distribution.value.region

      ami_distribution_configuration {
        name               = distribution.value.ami_name
        description        = distribution.value.ami_description
        kms_key_id         = distribution.value.kms_key_id
        ami_tags           = length(distribution.value.ami_tags) > 0 ? distribution.value.ami_tags : null
        target_account_ids = length(distribution.value.target_account_ids) > 0 ? distribution.value.target_account_ids : null

        dynamic "launch_permission" {
          for_each = distribution.value.launch_permission == null ? [] : [distribution.value.launch_permission]
          content {
            user_ids                 = length(launch_permission.value.user_ids) > 0 ? launch_permission.value.user_ids : null
            user_groups              = length(launch_permission.value.user_groups) > 0 ? launch_permission.value.user_groups : null
            organization_arns        = length(launch_permission.value.organization_arns) > 0 ? launch_permission.value.organization_arns : null
            organizational_unit_arns = length(launch_permission.value.organizational_unit_arns) > 0 ? launch_permission.value.organizational_unit_arns : null
          }
        }
      }
    }
  }
}
