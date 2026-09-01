# -------------------------------------------------------------------------------------
#
# Copyright (c) 2026, WSO2 LLC. (https://www.wso2.com) All Rights Reserved.
#
# WSO2 LLC. licenses this file to you under the Apache License,
# Version 2.0 (the "License"); you may not use this file except
# in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied. See the License for the
# specific language governing permissions and limitations
# under the License.
#
# --------------------------------------------------------------------------------------

output "eks_cluster_name" {
  value = aws_eks_cluster.eks_cluster.name
}

output "eks_cluster_arn" {
  value = aws_eks_cluster.eks_cluster.arn
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "eks_base64_encoded_ca_cert" {
  value = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}

output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.eks.arn
}

output "oidc_provider_url" {
  value = aws_iam_openid_connect_provider.eks.url
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "private_subnet_ids" {
  value = [for az in var.availability_zones : aws_subnet.private[az].id]
}

output "nat_gateway_public_ips" {
  value = { for az in var.availability_zones : az => aws_eip.nat[az].public_ip }
}

output "bastion_instance_id" {
  description = "aws ssm start-session --target <this> to reach the bastion"
  value       = var.enable_bastion ? aws_instance.bastion[0].id : null
}

output "eso_role_arn" {
  description = "IRSA role ARN for External Secrets Operator's own controller ServiceAccount (external-secrets/external-secrets)"
  value       = aws_iam_role.eso.arn
}
