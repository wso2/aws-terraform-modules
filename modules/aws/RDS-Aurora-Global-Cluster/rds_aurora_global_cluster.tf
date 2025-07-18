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

resource "aws_rds_global_cluster" "global_cluster" {
  global_cluster_identifier    = local.cluster_name
  engine                       = var.engine
  engine_version               = var.engine_version
  database_name                = var.database_name
  source_db_cluster_identifier = var.source_db_cluster_identifier
  deletion_protection          = var.deletion_protection
  tags                         = var.tags
  force_destroy                = var.source_db_cluster_identifier != null ? false : true
  storage_encrypted            = var.storage_encrypted
}
