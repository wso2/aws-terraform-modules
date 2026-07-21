output "local_transit_gateway_attachment_id" {
  value = aws_ec2_transit_gateway_peering_attachment.transit_gateway_peering_attachment.id
}
output "peer_transit_gateway_attachment_id" {
  # Same attachment (one id shared by both TGWs); use the created resource, not a lookup.
  value = aws_ec2_transit_gateway_peering_attachment.transit_gateway_peering_attachment.id
}
