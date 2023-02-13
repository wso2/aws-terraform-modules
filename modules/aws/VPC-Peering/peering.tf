# -------------------------------------------------------------------------------------
#
# Copyright (c) 2023, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
#
# This software is the property of WSO2 LLC. and its suppliers, if any.
# Dissemination of any information or reproduction of any material contained
# herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
# You may not alter or remove any copyright or other notice from copies of this content.
#
# --------------------------------------------------------------------------------------

resource "aws_vpc_peering_connection" "vpc_peering_connection" {
  peer_owner_id = var.peer_owner_id
  peer_vpc_id   = var.peer_vpc_id
  vpc_id        = var.vpc_id
  auto_accept   = var.auto_accept
  peer_region   = var.peer_region

  accepter {
    allow_remote_vpc_dns_resolution  = var.accepter_allow_remote_vpc_dns_resolution
    allow_classic_link_to_remote_vpc = var.accepter_allow_classic_link_to_remote_vpc
    allow_vpc_to_remote_classic_link = var.accepter_allow_vpc_to_remote_classic_link
  }

  requester {
    allow_remote_vpc_dns_resolution  = var.requester_allow_remote_vpc_dns_resolution
    allow_classic_link_to_remote_vpc = var.requester_allow_classic_link_to_remote_vpc
    allow_vpc_to_remote_classic_link = var.requester_allow_vpc_to_remote_classic_link
  }
}
