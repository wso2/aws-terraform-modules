locals {
  ec2_name    = join("-", [var.project, var.application, var.environment, var.region, var.availability_zone, "ec2"])
  rt_name     = join("-", [var.project, var.application, var.environment, var.region, var.availability_zone, "ec2-snet-rt"])
  subnet_name = join("-", [var.project, var.application, var.environment, var.region, var.availability_zone, "ec2-snet"])
  nic_name    = join("-", [var.project, var.application, var.environment, var.region, var.availability_zone, "ec2-nic"])
  ip_name     = join("-", [var.project, var.application, var.environment, var.region, var.availability_zone, "ec2-eip"])
  ec2_tags    = merge(var.default_tags, { Name : local.ec2_name })
  rt_tags     = merge(var.default_tags, { Name : local.rt_name })
  subnet_tags = merge(var.default_tags, { Name : local.subnet_name })
  nic_tags    = merge(var.default_tags, { Name : local.nic_name })
  ip_tags     = merge(var.default_tags, { Name : local.ip_name })
}
