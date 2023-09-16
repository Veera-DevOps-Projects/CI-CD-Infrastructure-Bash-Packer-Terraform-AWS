# Data source to retrieve the latest Nexus image from AWS
data "aws_ami" "latest_nexus_image" {
  #description = "Retrieve the latest Nexus machine image (AMI) from AWS."
  most_recent = true
  owners      = ["${var.image_owner}"] # Canonical

  filter {
    name   = "tag:Name"
    values = ["NexusImage"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Resource to create an AWS instance for the Nexus server
resource "aws_instance" "nexus_server" {
  #description = "Create an AWS instance for hosting the Nexus server."
  ami             = data.aws_ami.latest_nexus_image.id # us-west-2
  instance_type   = var.nexus_machine_data.type
  key_name        = var.key_pair_name
  subnet_id       = tolist(var.private_subnet_ids)[0]
  security_groups = [aws_security_group.nexus_sg.id]
  tags = {
    "Name" = var.nexus_machine_data.name
  }
  depends_on = [
    aws_security_group.nexus_sg
  ]
}
