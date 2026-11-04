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

resource "aws_imagebuilder_image_recipe" "imagebuilder_image_recipe" {
  name              = join("-", compact([var.project, var.application, var.environment, var.region, var.name, "ib-recipe"]))
  version           = var.recipe_version
  parent_image      = var.parent_image
  description       = var.description
  working_directory = var.working_directory
  user_data_base64  = var.user_data_base64
  tags              = var.tags

  dynamic "component" {
    for_each = var.components
    content {
      component_arn = component.value.component_arn

      dynamic "parameter" {
        for_each = component.value.parameters
        content {
          name  = parameter.key
          value = parameter.value
        }
      }
    }
  }

  dynamic "block_device_mapping" {
    for_each = var.block_device_mappings
    content {
      device_name  = block_device_mapping.value.device_name
      no_device    = block_device_mapping.value.no_device
      virtual_name = block_device_mapping.value.virtual_name

      dynamic "ebs" {
        for_each = block_device_mapping.value.ebs == null ? [] : [block_device_mapping.value.ebs]
        content {
          volume_size           = ebs.value.volume_size
          volume_type           = ebs.value.volume_type
          iops                  = ebs.value.iops
          throughput            = ebs.value.throughput
          encrypted             = ebs.value.encrypted
          kms_key_id            = ebs.value.kms_key_id
          snapshot_id           = ebs.value.snapshot_id
          delete_on_termination = ebs.value.delete_on_termination
        }
      }
    }
  }

  dynamic "systems_manager_agent" {
    for_each = var.uninstall_ssm_agent_after_build == null ? [] : [var.uninstall_ssm_agent_after_build]
    content {
      uninstall_after_build = systems_manager_agent.value
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
