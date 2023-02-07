locals {
  ec2_name    = join("-", ["ec2", var.project, var.application, var.environment, var.region, var.availability_zone, var.padding])
  rt_name     = join("-", ["rt", var.project, var.application, var.environment, var.region])
  subnet_name = join("-", ["snet", var.project, var.application, var.environment, var.region, var.availability_zone])
  ec2_tags    = merge(var.default_tags, { name : local.ec2_name })
  rt_tags     = merge(var.default_tags, { name : local.rt_name })
  subnet_tags = merge(var.default_tags, { name : local.subnet_name })
}