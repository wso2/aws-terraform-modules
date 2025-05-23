variable "peer_account_id" {
  description = "The AWS account ID of the peer transit gateway"
  type        = string
}
variable "peer_region" {
  description = "The AWS region of the peer transit gateway"
  type        = string
}
variable "peer_transit_gateway_id" {
  description = "The ID of the peer transit gateway"
  type        = string
}
variable "local_transit_gateway_id" {
  description = "The ID of the local transit gateway"
  type        = string
}
variable "default_tags" {
  description = "Default tags to apply to the transit gateway peering attachment"
  type        = map(string)
  default     = {}
}
variable "dynamic_routing" {
  description = "Dynamic routing for the transit gateway peering attachment"
  type        = string
  default     = "enable"
}
