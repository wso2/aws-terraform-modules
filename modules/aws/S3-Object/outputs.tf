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

output "id" {
  description = "Key of the object"
  value       = aws_s3_object.s3_object.id
}

output "bucket" {
  description = "Name of the bucket holding the object"
  value       = aws_s3_object.s3_object.bucket
}

output "key" {
  description = "Key of the object"
  value       = aws_s3_object.s3_object.key
}

output "uri" {
  description = "S3 URI of the object, in the form s3://<bucket>/<key>"
  value       = "s3://${aws_s3_object.s3_object.bucket}/${aws_s3_object.s3_object.key}"
}

output "version_id" {
  description = "Version ID of the object, when the bucket has versioning enabled"
  value       = aws_s3_object.s3_object.version_id
}
