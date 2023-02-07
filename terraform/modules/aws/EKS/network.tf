#resource "aws_route_table" "route_table" {
#  vpc_id = var.vpc_id
#
#  route {
#    cidr_block = "0.0.0.0/0"
#    gateway_id = aws_internet_gateway.gw.id
#  }
#
#  tags = var.default_tags
#}
#
resource "aws_internet_gateway" "gw" {
  vpc_id = var.vpc_id

  tags = var.default_tags
}

resource "aws_route" "route" {
  route_table_id            = var.route_table_id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gw.id
}