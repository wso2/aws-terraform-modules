locals {
  ec2_limit       = var.cost * (var.ec2_percentage / 100)
  logs_limit      = var.cost * (var.logs_percentage / 100)
  networking_limit = var.cost * (var.networking_percentage / 100)
}
