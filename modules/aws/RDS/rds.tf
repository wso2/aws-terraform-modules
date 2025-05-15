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

resource "aws_db_instance" "rds_instance" {
  allow_major_version_upgrade = var.allow_major_version_upgrade

  availability_zone = var.availability_zone
  network_type      = var.network_type
  port              = var.database_port

  backup_retention_period         = var.backup_retention_period
  backup_window                   = var.backup_window
  performance_insights_enabled    = var.performance_insights_enabled
  performance_insights_kms_key_id = var.performance_insights_kms_key_id

  db_name                     = var.engine != "custom-sqlserver-se" ? local.cluster_name : null
  username                    = var.master_username
  password                    = var.master_password
  manage_master_user_password = var.master_password == null ? true : null
  custom_iam_instance_profile = var.custom_iam_instance_profile

  license_model     = var.license_model
  allocated_storage = var.allocated_storage
  engine            = var.engine
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  storage_type      = var.storage_type

  db_subnet_group_name            = var.db_subnet_group_name
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_log_exports

  iam_database_authentication_enabled = var.iam_database_authentication_enabled

  vpc_security_group_ids = var.vpc_security_group_ids

  skip_final_snapshot = var.skip_final_snapshot

  engine_lifecycle_support = var.engine_lifecycle_support

  deletion_protection = var.deletion_protection

  storage_encrypted = var.storage_encrypted
  kms_key_id        = var.storage_encrypted == true ? var.kms_key_id : null

  publicly_accessible = var.publicly_accessible

  tags = var.tags
}
