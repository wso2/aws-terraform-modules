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

resource "aws_s3_object" "s3_object" {
  bucket                 = var.bucket
  key                    = var.key
  source                 = var.source_file
  content                = var.content
  content_type           = var.content_type
  server_side_encryption = var.server_side_encryption
  kms_key_id             = var.kms_key_id
  tags                   = var.tags

  source_hash = var.source_file == null ? null : filemd5(var.source_file)

  lifecycle {
    create_before_destroy = true

    precondition {
      condition     = (var.source_file == null) != (var.content == null)
      error_message = "Set exactly one of source_file or content."
    }
  }
}
