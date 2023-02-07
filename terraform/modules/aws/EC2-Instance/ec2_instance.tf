resource "aws_instance" "ec2_instance" {
  ami           = var.ec2_ami
  instance_type = var.ec2_instance_type

  tags = var.default_tags

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.ec2_network_interface.id
  }
}
