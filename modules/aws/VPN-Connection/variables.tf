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

variable "transit_gateway_id" {
  description = "The ID of the transit gateway."
  type        = string
  default     = null
}
variable "customer_gateway_id" {
  description = "The ID of the customer gateway."
  type        = string
}
variable "type" {
  type        = string
  description = "The type of VPN connection. The only type AWS supports is ipsec.1."
}
variable "vpn_gateway_id" {
  description = "The ID of the VPN gateway."
  default     = null
  type        = string
}
variable "static_routes_only" {
  description = "Indicates whether the VPN connection uses static routes exclusively. Static routes must be used for devices that don't support BGP."
  default     = false
  type        = bool
}
variable "local_ipv4_network_cidr" {
  description = "The IPv4 CIDR on the customer gateway (on-premises) side of the VPN connection."
  default     = null
  type        = string
}
variable "outside_ip_address_type" {
  description = "The type of outside IP address to use for the VPN tunnel. Valid values are ipv4 and ipv6."
  default     = null
  type        = string
}
variable "remote_ipv4_network_cidr" {
  description = "The IPv4 CIDR on the AWS side of the VPN connection."
  default     = null
  type        = string
}
variable "tunnel1_inside_cidr" {
  description = "The range of inside IPv4 addresses for the tunnel. Any specified CIDR blocks must be unique across all VPN connections that use the same virtual private gateway."
  default     = null
  type        = string
}
variable "tunnel1_preshared_key" {
  description = "The pre-shared key (PSK) to establish initial authentication between the virtual private gateway and the customer gateway."
  default     = null
  type        = string
}
variable "tunnel1_dpd_timeout_action" {
  description = "The action to take after DPD timeout occurs. Valid values are clear, none, restart."
  default     = null
  type        = string
}
variable "tunnel1_dpd_timeout_seconds" {
  description = "The number of seconds after which a DPD timeout occurs."
  default     = null
  type        = number
}
variable "tunnel1_ike_versions" {
  description = "The IKE versions that are permitted for the VPN tunnel. Valid values are ikev1 and ikev2."
  default     = null
  type        = list(string)
}
variable "tunnel1_phase1_dh_group_numbers" {
  description = "One or more Diffie-Hellman group numbers that are permitted for the VPN tunnel for phase 1 IKE negotiations. Valid values are 2, 5, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24."
  default     = null
  type        = list(number)
}
variable "tunnel1_phase1_encryption_algorithms" {
  description = "One or more encryption algorithms that are permitted for the VPN tunnel for phase 1 IKE negotiations. Valid values are AES128, AES256, AES128-GCM-16, AES256-GCM-16, 3DES."
  default     = null
  type        = list(string)
}
variable "tunnel1_phase1_integrity_algorithms" {
  description = "One or more integrity algorithms that are permitted for the VPN tunnel for phase 1 IKE negotiations. Valid values are SHA1, SHA2-256, SHA2-384, SHA2-512."
  default     = null
  type        = list(string)
}
variable "tunnel1_phase1_lifetime_seconds" {
  description = "The lifetime for phase 1 of the IKE negotiation, in seconds."
  default     = null
  type        = number
}
variable "tunnel1_phase2_dh_group_numbers" {
  description = "One or more Diffie-Hellman group numbers that are permitted for the VPN tunnel for phase 2 IKE negotiations. Valid values are 2, 5, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24."
  default     = null
  type        = list(number)
}
variable "tunnel1_phase2_encryption_algorithms" {
  description = "One or more encryption algorithms that are permitted for the VPN tunnel for phase 2 IKE negotiations. Valid values are AES128, AES256, AES128-GCM-16, AES256-GCM-16, 3DES."
  default     = null
  type        = list(string)
}
variable "tunnel1_phase2_integrity_algorithms" {
  description = "One or more integrity algorithms that are permitted for the VPN tunnel for phase 2 IKE negotiations. Valid values are SHA1, SHA2-256, SHA2-384, SHA2-512."
  default     = null
  type        = list(string)
}
variable "tunnel1_phase2_lifetime_seconds" {
  description = "The lifetime for phase 2 of the IKE negotiation, in seconds."
  default     = null
  type        = number
}
variable "tunnel1_rekey_fuzz_percentage" {
  description = "The percentage of the rekey window (determined by replay_window_size) during which the rekey time is randomly selected."
  default     = null
  type        = number
}
variable "tunnel1_rekey_margin_time_seconds" {
  description = "The margin time, in seconds, before the phase 2 lifetime expires, during which the AWS side of the VPN connection performs an IKE rekey. The exact time of the rekey is randomly selected based on the value for rekey_fuzz_percentage."
  default     = null
  type        = number
}
variable "tunnel1_replay_window_size" {
  description = "The number of packets in an IKE replay window."
  default     = null
  type        = number
}
variable "tunnel1_startup_action" {
  description = "The action to take when the establishing the tunnel for the VPN connection. By default, your customer gateway device must initiate the IKE negotiation and bring up the tunnel. Specify add to automatically bring up the tunnel when the virtual private gateway is attached to a VPC."
  default     = null
  type        = string
}
variable "tunnel2_inside_cidr" {
  description = "The range of inside IPv4 addresses for the tunnel. Any specified CIDR blocks must be unique across all VPN connections that use the same virtual private gateway."
  default     = null
  type        = string
}
variable "tunnel2_preshared_key" {
  description = "The pre-shared key (PSK) to establish initial authentication between the virtual private gateway and the customer gateway."
  default     = null
  type        = string
}
variable "tunnel2_dpd_timeout_action" {
  description = "The action to take after DPD timeout occurs. Valid values are clear, none, restart."
  default     = null
  type        = string
}
variable "tunnel2_dpd_timeout_seconds" {
  description = "The number of seconds after which a DPD timeout occurs."
  default     = null
  type        = number
}
variable "tunnel2_ike_versions" {
  description = "The IKE versions that are permitted for the VPN tunnel. Valid values are ikev1 and ikev2."
  default     = null
  type        = list(string)
}
variable "tunnel2_phase1_dh_group_numbers" {
  description = "One or more Diffie-Hellman group numbers that are permitted for the VPN tunnel for phase 1 IKE negotiations. Valid values are 2, 5, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24."
  default     = null
  type        = list(number)
}
variable "tunnel2_phase1_encryption_algorithms" {
  description = "One or more encryption algorithms that are permitted for the VPN tunnel for phase 1 IKE negotiations. Valid values are AES128, AES256, AES128-GCM-16, AES256-GCM-16, 3DES."
  default     = null
  type        = list(string)
}
variable "tunnel2_phase1_integrity_algorithms" {
  description = "One or more integrity algorithms that are permitted for the VPN tunnel for phase 1 IKE negotiations. Valid values are SHA1, SHA2-256, SHA2-384, SHA2-512."
  default     = null
  type        = list(string)
}
variable "tunnel2_phase1_lifetime_seconds" {
  description = "The lifetime for phase 1 of the IKE negotiation, in seconds."
  default     = null
  type        = number
}
variable "tunnel2_phase2_dh_group_numbers" {
  description = "One or more Diffie-Hellman group numbers that are permitted for the VPN tunnel for phase 2 IKE negotiations. Valid values are 2, 5, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24."
  default     = null
  type        = list(number)
}
variable "tunnel2_phase2_encryption_algorithms" {
  description = "One or more encryption algorithms that are permitted for the VPN tunnel for phase 2 IKE negotiations. Valid values are AES128, AES256, AES128-GCM-16, AES256-GCM-16, 3DES."
  default     = null
  type        = list(string)
}
variable "tunnel2_phase2_integrity_algorithms" {
  description = "One or more integrity algorithms that are permitted for the VPN tunnel for phase 2 IKE negotiations. Valid values are SHA1, SHA2-256, SHA2-384, SHA2-512."
  default     = null
  type        = list(string)
}
variable "tunnel2_phase2_lifetime_seconds" {
  description = "The lifetime for phase 2 of the IKE negotiation, in seconds."
  default     = null
  type        = number
}
variable "tunnel2_rekey_fuzz_percentage" {
  description = "The percentage of the rekey window (determined by replay_window_size) during which the rekey time is randomly selected."
  default     = null
  type        = number
}
variable "tunnel2_rekey_margin_time_seconds" {
  description = "The margin time, in seconds, before the phase 2 lifetime expires, during which the AWS side of the VPN connection performs an IKE rekey. The exact time of the rekey is randomly selected based on the value for rekey_fuzz_percentage."
  default     = null
  type        = number
}
variable "tunnel2_replay_window_size" {
  description = "The number of packets in an IKE replay window."
  default     = null
  type        = number
}
variable "tunnel2_startup_action" {
  description = "The action to take when the establishing the tunnel for the VPN connection. By default, your customer gateway device must initiate the IKE negotiation and bring up the tunnel. Specify add to automatically bring up the tunnel when the virtual private gateway is attached to a VPC."
  default     = null
  type        = string
}
variable "transport_transit_gateway_attachment_id" {
  description = "The ID of the attachment."
  default     = null
  type        = string
}
variable "project" {
  type        = string
  description = "Name of the project"
}
variable "environment" {
  type        = string
  description = "Name of the environment"
}
variable "region" {
  type        = string
  description = "Code of the region"
}
variable "application" {
  type        = string
  description = "Purpose of the Customer gateway"
}
variable "tags" {
  type        = map(string)
  description = "Default tags for the Connection resource"
  default     = {}
}
