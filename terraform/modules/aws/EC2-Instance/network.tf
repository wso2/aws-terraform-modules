resource "aws_subnet" "ec2_subnet" {
  vpc_id            = var.ec2_vpc_id
  cidr_block        = var.ec2_vpc_cidr_block
  availability_zone = var.availability_zone

  tags = var.default_tags
}

resource "aws_network_interface" "ec2_network_interface" {
  subnet_id   = aws_subnet.ec2_subnet.id
  tags = var.default_tags
}
