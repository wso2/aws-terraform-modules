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

resource "aws_imagebuilder_image_pipeline" "imagebuilder_image_pipeline" {
  name                             = join("-", compact([var.project, var.application, var.environment, var.region, var.name, "ib-pipeline"]))
  description                      = var.description
  image_recipe_arn                 = var.image_recipe_arn
  infrastructure_configuration_arn = var.infrastructure_configuration_arn
  distribution_configuration_arn   = var.distribution_configuration_arn
  enhanced_image_metadata_enabled  = var.enhanced_image_metadata_enabled
  status                           = var.status
  tags                             = var.tags

  image_tests_configuration {
    image_tests_enabled = var.image_tests_enabled
    timeout_minutes     = var.image_tests_timeout_minutes
  }

  # Amazon Inspector scanning. Needs Inspector enabled for the account.
  dynamic "image_scanning_configuration" {
    for_each = var.image_scanning_enabled ? [1] : []
    content {
      image_scanning_enabled = true
    }
  }

  # No schedule = the pipeline runs only when started, e.g. from a CI/CD pipeline.
  dynamic "schedule" {
    for_each = var.schedule == null ? [] : [var.schedule]
    content {
      schedule_expression                = schedule.value.schedule_expression
      pipeline_execution_start_condition = schedule.value.pipeline_execution_start_condition
      timezone                           = schedule.value.timezone
    }
  }
}
