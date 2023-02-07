output "vpc_cidr_block" {
  value = aws_vpc.vpc.cidr_block
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "vpc_route_table_id" {
  value = aws_vpc.vpc.default_route_table_id
}