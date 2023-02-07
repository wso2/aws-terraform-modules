locals {
  default_tags = {
    project           = var.project
    environment       = var.environment
    availability_zone = var.availability_zone
    terraform         = "true"
    user              = "hirana@wso2.com"
  }
}