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

resource "aws_vpn_connection" "vpn_connection" {
  customer_gateway_id                     = var.customer_gateway_id
  type                                    = var.type
  vpn_gateway_id                          = var.vpn_gateway_id
  static_routes_only                      = var.static_routes_only
  local_ipv4_network_cidr                 = var.local_ipv4_network_cidr
  outside_ip_address_type                 = var.outside_ip_address_type
  remote_ipv4_network_cidr                = var.remote_ipv4_network_cidr
  tunnel1_inside_cidr                     = var.tunnel1_inside_cidr
  tunnel1_preshared_key                   = var.tunnel1_preshared_key
  tunnel1_dpd_timeout_action              = var.tunnel1_dpd_timeout_action
  tunnel1_dpd_timeout_seconds             = var.tunnel1_dpd_timeout_seconds
  tunnel1_ike_versions                    = var.tunnel1_ike_versions
  tunnel1_phase1_dh_group_numbers         = var.tunnel1_phase1_dh_group_numbers
  tunnel1_phase1_encryption_algorithms    = var.tunnel1_phase1_encryption_algorithms
  tunnel1_phase1_integrity_algorithms     = var.tunnel1_phase1_integrity_algorithms
  tunnel1_phase1_lifetime_seconds         = var.tunnel1_phase1_lifetime_seconds
  tunnel1_phase2_dh_group_numbers         = var.tunnel1_phase2_dh_group_numbers
  tunnel1_phase2_encryption_algorithms    = var.tunnel1_phase2_encryption_algorithms
  tunnel1_phase2_integrity_algorithms     = var.tunnel1_phase2_integrity_algorithms
  tunnel1_phase2_lifetime_seconds         = var.tunnel1_phase2_lifetime_seconds
  tunnel1_rekey_fuzz_percentage           = var.tunnel1_rekey_fuzz_percentage
  tunnel1_rekey_margin_time_seconds       = var.tunnel1_rekey_margin_time_seconds
  tunnel1_replay_window_size              = var.tunnel1_replay_window_size
  tunnel1_startup_action                  = var.tunnel1_startup_action
  tunnel2_inside_cidr                     = var.tunnel2_inside_cidr
  tunnel2_preshared_key                   = var.tunnel2_preshared_key
  tunnel2_dpd_timeout_action              = var.tunnel2_dpd_timeout_action
  tunnel2_dpd_timeout_seconds             = var.tunnel2_dpd_timeout_seconds
  tunnel2_ike_versions                    = var.tunnel2_ike_versions
  tunnel2_phase1_dh_group_numbers         = var.tunnel2_phase1_dh_group_numbers
  tunnel2_phase1_encryption_algorithms    = var.tunnel2_phase1_encryption_algorithms
  tunnel2_phase1_integrity_algorithms     = var.tunnel2_phase1_integrity_algorithms
  tunnel2_phase1_lifetime_seconds         = var.tunnel2_phase1_lifetime_seconds
  tunnel2_phase2_dh_group_numbers         = var.tunnel2_phase2_dh_group_numbers
  tunnel2_phase2_encryption_algorithms    = var.tunnel2_phase2_encryption_algorithms
  tunnel2_phase2_integrity_algorithms     = var.tunnel2_phase2_integrity_algorithms
  tunnel2_phase2_lifetime_seconds         = var.tunnel2_phase2_lifetime_seconds
  tunnel2_rekey_fuzz_percentage           = var.tunnel2_rekey_fuzz_percentage
  tunnel2_rekey_margin_time_seconds       = var.tunnel2_rekey_margin_time_seconds
  tunnel2_replay_window_size              = var.tunnel2_replay_window_size
  tunnel2_startup_action                  = var.tunnel2_startup_action
  transport_transit_gateway_attachment_id = var.transport_transit_gateway_attachment_id

  tags = local.connection_tags
}
