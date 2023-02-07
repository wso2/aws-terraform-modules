variable "vpc_id" {}
variable "cidr_block" {}
variable "default_tags" {}
variable "availability_zone" {}
variable "auto_assign_public_ip" {
  type = bool
  default = false
}