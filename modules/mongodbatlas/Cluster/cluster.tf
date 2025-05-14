# -------------------------------------------------------------------------------------
#
# Copyright (c) 2025, WSO2 Inc. (http://www.wso2.com). All Rights Reserved.
#
# This software is the property of WSO2 Inc. and its suppliers, if any.
# Dissemination of any information or reproduction of any material contained
# herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
# You may not alter or remove any copyright or other notice from copies of this content.
#
# --------------------------------------------------------------------------------------

resource "mongodbatlas_cluster" "cluster" {
  project_id   = var.project_id
  name         = var.name
  cluster_type = var.cluster_type
  disk_size_gb = var.disk_size_gb
  replication_specs {
    num_shards = var.num_shards
    dynamic "regions_config" {
      for_each = var.replication_specs
      content {
        region_name     = regions_config.value.region_name
        electable_nodes = regions_config.value.electable_nodes
        priority        = regions_config.value.priority
        read_only_nodes = regions_config.value.read_only_nodes
      }
    }
  }
  cloud_backup                            = true
  auto_scaling_compute_enabled            = true
  auto_scaling_compute_scale_down_enabled = true
  auto_scaling_disk_gb_enabled            = true
  mongo_db_major_version                  = var.major_version

  //Provider Settings "block"
  provider_name = "AWS"
  lifecycle {
    ignore_changes = [
      provider_instance_size_name,
      bi_connector_config
    ]
  }
  provider_instance_size_name                     = var.instance_size
  provider_auto_scaling_compute_min_instance_size = var.compute_min_instance_size
  provider_auto_scaling_compute_max_instance_size = var.compute_max_instance_size
  pit_enabled                                     = var.continuous_backup_enabled
}
