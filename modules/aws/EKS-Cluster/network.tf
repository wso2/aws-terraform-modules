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

resource "aws_subnet" "eks_subnet" {
  count = length(var.cluster_subnet_ids) == 0 ? length(var.subnet_details) : 0

  vpc_id            = var.eks_vpc_id
  cidr_block        = var.subnet_details[count.index].cidr_block
  availability_zone = var.subnet_details[count.index].availability_zone


  tags = merge(var.tags, {
    Name = join("-", [var.subnet_abbreviation, var.subnet_details[count.index].availability_zone, var.subnet_name]),
  })
}

resource "aws_route_table" "route_table" {
  count  = length(var.cluster_subnet_ids) == 0 ? length(var.subnet_details) : 0
  vpc_id = var.eks_vpc_id
  tags   = local.rt_tags

  dynamic "route" {
    for_each = var.subnet_details[count.index].custom_routes
    content {
      cidr_block                = route.value.cidr_block
      carrier_gateway_id        = route.value.ep_type == "carrier_gateway_id" ? route.value.ep_id : null
      core_network_arn          = route.value.ep_type == "core_network_arn" ? route.value.ep_id : null
      egress_only_gateway_id    = route.value.ep_type == "egress_only_gateway_id" ? route.value.egress_only_gateway_id : null
      gateway_id                = route.value.ep_type == "gateway_id" ? route.value.ep_id : null
      local_gateway_id          = route.value.ep_type == "local_gateway_id" ? route.value.ep_id : null
      nat_gateway_id            = route.value.ep_type == "nat_gateway_id" ? route.value.ep_id : null
      network_interface_id      = route.value.ep_type == "network_interface_id" ? route.value.ep_id : null
      transit_gateway_id        = route.value.ep_type == "transit_gateway_id" ? route.value.ep_id : null
      vpc_endpoint_id           = route.value.ep_type == "vpc_endpoint_id" ? route.value.ep_id : null
      vpc_peering_connection_id = route.value.ep_type == "vpc_peering_connection_id" ? route.value.ep_id : null
    }
  }
}

resource "aws_route_table_association" "route_table_association" {
  count = length(aws_subnet.eks_subnet[*].id)

  subnet_id      = aws_subnet.eks_subnet[count.index].id
  route_table_id = aws_route_table.route_table[count.index].id

  depends_on = [
    aws_route_table.route_table,
    aws_subnet.eks_subnet
  ]
}
