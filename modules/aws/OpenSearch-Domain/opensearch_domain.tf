# -------------------------------------------------------------------------------------
#
# Copyright (c) 2024, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
#
# This software is the property of WSO2 LLC. and its suppliers, if any.
# Dissemination of any information or reproduction of any material contained
# herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
# You may not alter or remove any copyright or other notice from copies of this content.
#
# --------------------------------------------------------------------------------------

resource "aws_iam_service_linked_role" "vpc_enabled_service_linked_role" {
  count            = var.create_service_linked_role ? 1 : 0
  aws_service_name = "opensearchservice.amazonaws.com"
}

resource "aws_opensearch_domain" "opensearch_domain" {
  domain_name      = local.domain_name
  engine_version   = var.engine_version
  advanced_options = var.advanced_options

  access_policies = data.aws_iam_policy_document.es_admins_policy_document.json

  cluster_config {
    instance_type          = var.instance_type
    instance_count         = var.instance_count
    zone_awareness_enabled = var.zone_awareness_enabled

    dynamic "zone_awareness_config" {
      for_each = var.zone_awareness_enabled ? [1] : []
      content {
        availability_zone_count = var.availability_zone_count
      }
    }
  }

  dynamic "ebs_options" {
    for_each = var.ebs_volume != null ? [1] : []
    content {
      ebs_enabled = true
      volume_size = var.ebs_volume.size
      volume_type = var.ebs_volume.type
      throughput  = var.ebs_volume.throughput
      iops        = var.ebs_volume.iops
    }
  }

  encrypt_at_rest {
    enabled    = true
    kms_key_id = var.kms_key_arn
  }

  node_to_node_encryption {
    enabled = true
  }

  dynamic "log_publishing_options" {
    for_each = var.log_publishing_options != null ? [1] : []
    content {
      cloudwatch_log_group_arn = var.log_publishing_options.cloudwatch_log_group_arn
      log_type                 = var.log_publishing_options.log_type
    }
  }

  snapshot_options {
    automated_snapshot_start_hour = var.automated_snapshot_start_hour
  }

  dynamic "advanced_security_options" {
    for_each = var.advanced_security_options != null ? [1] : []
    content {
      enabled                        = var.advanced_security_options.enabled
      internal_user_database_enabled = var.advanced_security_options.internal_user_database_enabled
      master_user_options {
        master_user_arn      = var.advanced_security_options.master_user_options.master_user_arn
        master_user_name     = var.advanced_security_options.master_user_options.master_user_name
        master_user_password = var.advanced_security_options.master_user_options.master_user_name
      }
    }
  }


  dynamic "vpc_options" {
    for_each = var.vpc_options != null ? [1] : []
    content {
      security_group_ids = var.vpc_options.security_group_ids
      subnet_ids         = var.vpc_options.subnet_ids
    }
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  tags = var.tags

  depends_on = [aws_iam_service_linked_role.vpc_enabled_service_linked_role]
}
