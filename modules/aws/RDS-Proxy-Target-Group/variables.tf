variable "db_instance_identifier" {
  type        = string
  default     = null
  description = "Either db_instance_identifier or db_cluster_identifier should be specified"
}
variable "db_cluster_identifier" {
  type        = string
  default     = null
  description = "Either db_instance_identifier or db_cluster_identifier should be specified"
}
variable "db_proxy_name" {
  type = string
}
variable "default_target_group_name" {
  type = string
}