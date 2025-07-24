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

resource "aws_ssm_document" "session_manager_doc" {
  name            = "${local.user_name}-session-manager-doc"
  document_type   = "Session"
  document_format = "JSON"

  content = jsonencode({
    schemaVersion = "1.0",
    description   = "Document to hold regional settings for Session Manager",
    sessionType   = "Standard_Stream",
    inputs = {
      s3BucketName                = "",
      s3KeyPrefix                 = "",
      s3EncryptionEnabled        = true,
      cloudWatchLogGroupName     = var.cloud_watch_group_name,
      cloudWatchEncryptionEnabled= true,
      cloudWatchStreamingEnabled = true,
      idleSessionTimeout         = var.session_timeout,
      maxSessionDuration         = var.max_session_duration,
      kmsKeyId                   = "",
      runAsEnabled               = true,
      runAsDefaultUser           = var.user_email,
      shellProfile = {
        windows = "",
        linux   = "timestamp=$(date '+%Y-%m-%dT%H:%M:%SZ');user=$(whoami);echo $timestamp && echo \"Welcome $user\"'!';cd /home/$user/"
      }
    }
  })

  tags = {
    Name = "${local.user_name}-session-manager-doc"
    Owner = var.user_email
  }
}
