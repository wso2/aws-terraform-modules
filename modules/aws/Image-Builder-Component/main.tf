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

resource "aws_imagebuilder_component" "imagebuilder_component" {
  name                  = local.name
  version               = var.component_version
  platform              = var.platform
  description           = var.description
  change_description    = var.change_description
  uri                   = var.uri
  data                  = var.data
  kms_key_id            = var.kms_key_id
  supported_os_versions = var.supported_os_versions
  skip_destroy          = var.skip_destroy
  tags                  = var.tags

  lifecycle {
    create_before_destroy = true

    precondition {
      condition     = (var.uri == null) != (var.data == null)
      error_message = "Set exactly one of uri or data."
    }
  }
}
