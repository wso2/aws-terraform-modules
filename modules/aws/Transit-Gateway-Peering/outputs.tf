output "local_transit_gateway_attachment_id" {
  value = aws_ec2_transit_gateway_peering_attachment.transit_gateway_peering_attachment.id
}
output "peer_transit_gateway_attachment_id" {
  value = data.aws_ec2_transit_gateway_peering_attachment.peer_transit_gateway_peering_attachment.id
}
