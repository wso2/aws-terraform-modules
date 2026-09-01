moved {
  from = aws_vpc.this
  to   = aws_vpc.vpc
}

moved {
  from = aws_internet_gateway.this
  to   = aws_internet_gateway.gw
}

moved {
  from = aws_nat_gateway.this
  to   = aws_nat_gateway.nat_gateway
}

moved {
  from = aws_security_group.this
  to   = aws_security_group.security_group
}

moved {
  from = aws_eks_cluster.this
  to   = aws_eks_cluster.eks_cluster
}

moved {
  from = aws_launch_template.this
  to   = aws_launch_template.launch_template
}

moved {
  from = aws_eks_node_group.this
  to   = aws_eks_node_group.eks_node_group
}
