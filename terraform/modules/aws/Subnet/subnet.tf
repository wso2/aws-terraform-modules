resource "aws_subnet" "subnet" {
  vpc_id     = var.vpc_id
  cidr_block = var.cidr_block
  tags = var.default_tags
  availability_zone = var.availability_zone
  map_public_ip_on_launch = var.auto_assign_public_ip
}