# Define an AWS EC2 instance resource for the Jump Box server.
resource "aws_instance" "jumpbox_server" {
  ami                         = var.jumpbox_image_id          # Specify the AMI ID for the Jump Box (Amazon Machine Image).
  instance_type               = var.jumpbox_type              # Specify the instance type for the Jump Box.
  key_name                    = var.key_pair_name             # Use the specified SSH key pair.
  subnet_id                   = tolist(var.public_subnet_ids)[1]  # Specify the public subnet for the instance.
  associate_public_ip_address = true                          # Automatically assign a public IP address.
  security_groups             = [aws_security_group.jumpbox_sg.id]  # Attach the Jump Box security group.

  # Define tags for the Jump Box instance, including its name.
  tags = {
    "Name" = var.jumpbox_name
  }

  # Ensure the instance creation depends on the Jump Box security group.
  depends_on = [
    aws_security_group.jumpbox_sg
  ]
}
