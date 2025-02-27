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

resource "aws_codebuild_project" "build_project" {
  name         = join("-", [var.project, var.application, var.environment, var.region, "codebuild"])
  service_role = var.eks_access != false ? var.custom_codebuild_role_arn : aws_iam_role.codebuild_role[0].arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = var.build_compute_type
    image           = var.build_image
    type            = var.build_environment_type
    privileged_mode = var.build_privileged_mode

    dynamic "environment_variable" {
      for_each = var.build_environment_variables
      content {
        name  = environment_variable.value["name"]
        value = environment_variable.value["value"]
      }
    }
  }

  dynamic "vpc_config" {
    for_each = var.build_vpc_config != null ? [var.build_vpc_config] : []
    content {
      vpc_id             = vpc_config.value.vpc_id
      subnets            = vpc_config.value.subnets
      security_group_ids = vpc_config.value.security_group_ids
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = var.buildspec_file
  }

  depends_on = [
    aws_iam_role.codebuild_role[0]
  ]
}
