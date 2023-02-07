locals {
  rt_name = join("-", ["rt", var.project, var.application, var.environment, var.region])
  rt_tags = merge(var.default_tags, { name : local.rt_name })
}