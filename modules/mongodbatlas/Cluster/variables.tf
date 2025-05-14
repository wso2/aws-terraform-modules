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

variable "project_id" {
  type = string
}
variable "name" {
  type = string
}
variable "major_version" {
  type = string
}
variable "num_shards" {
  type    = number
  default = 1
}
variable "cluster_type" {
  type = string
}
variable "disk_size_gb" {
  type    = number
  default = 10
}
variable "instance_size" {
  type = string
}
variable "compute_min_instance_size" {
  type = string
}
variable "compute_max_instance_size" {
  type = string
}
variable "continuous_backup_enabled" {
  type    = bool
  default = false
}
variable "replication_specs" {
  type = list(object({
    region_name     = string
    electable_nodes = number
    priority        = number
    read_only_nodes = number
  }))
}
