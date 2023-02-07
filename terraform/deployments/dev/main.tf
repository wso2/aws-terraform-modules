module "ec2_bastion" {
  source             = "../../modules/aws/EC2-Instance"
  availability_zone  = var.availability_zone
  default_tags       = local.default_tags
  ec2_ami            = "ami-0a476a478b04d85ca"
  ec2_instance_type  = "t2.micro"
  ec2_vpc_cidr_block = module.bastion_vpc.vpc_cidr_block
  ec2_vpc_id         = module.bastion_vpc.vpc_id
  depends_on = [
    module.bastion_vpc
  ]
}

module "bastion_vpc" {
  source         = "../../modules/aws/VPC"
  default_tags   = local.default_tags
  vpc_cidr_block = "172.16.0.0/16"
}

module "eks_vpc" {
  source         = "../../modules/aws/VPC"
  default_tags   = local.default_tags
  vpc_cidr_block = "172.17.0.0/16"
}


module "eks_subnet_1" {
  source                = "../../modules/aws/Subnet"
  cidr_block            = "172.17.0.0/18"
  default_tags          = local.default_tags
  vpc_id                = module.eks_vpc.vpc_id
  availability_zone     = data.aws_availability_zones.available.names[1]
  auto_assign_public_ip = true
  depends_on = [
    module.eks_vpc
  ]
}

module "eks_subnet_2" {
  source                = "../../modules/aws/Subnet"
  cidr_block            = "172.17.64.0/18"
  default_tags          = local.default_tags
  vpc_id                = module.eks_vpc.vpc_id
  availability_zone     = data.aws_availability_zones.available.names[2]
  auto_assign_public_ip = true
  depends_on = [
    module.eks_vpc
  ]
}

module "eks_cluster" {
  source        = "../../modules/aws/EKS"
  eks_name      = "pdp-aws-eks"
  iam_role_name = "pdp-aws-role"
  subnet_ids    = [module.eks_subnet_1.subnet_id, module.eks_subnet_2.subnet_id]
  default_tags  = local.default_tags
  vpc_id        = module.eks_vpc.vpc_id
  depends_on = [
    module.eks_vpc,
    module.eks_subnet_1,
    module.eks_subnet_2
  ]
  route_table_id = module.eks_vpc.vpc_route_table_id
}

module "eks_cluster_node_group_default" {
  source           = "../../modules/aws/EKS-Node-Group"
  eks_cluster_name = module.eks_cluster.eks_cluster_name
  node_group_name  = "system"
  subnet_ids       = [module.eks_subnet_1.subnet_id, module.eks_subnet_2.subnet_id]
  default_tags     = local.default_tags
  depends_on = [
    module.eks_cluster
  ]
}
