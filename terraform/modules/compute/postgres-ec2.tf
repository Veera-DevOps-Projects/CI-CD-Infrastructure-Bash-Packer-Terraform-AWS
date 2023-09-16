# Data source to retrieve the latest PostgreSQL image from AWS
data "aws_ami" "latest_postgres_image" {
  #description = "Retrieve the latest PostgreSQL machine image (AMI) from AWS."
  most_recent = true
  #owners      = ["${var.image_owner}"] # Canonical

  filter {
    name   = "tag:Name"
    values = ["PostgresImage"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Data source to retrieve information about the PostgreSQL server instance
data "aws_instance" "postgres_server_instance" {
  #description = "Retrieve information about the PostgreSQL server instance."
  instance_id = aws_instance.postgres_server.id

  filter {
    name   = "tag:Name"
    values = [var.postgres_machine_data.name]
  }
}

# Resource to create an AWS instance for the PostgreSQL server
resource "aws_instance" "postgres_server" {
  #description = "Create an AWS instance for hosting the PostgreSQL server."
  ami             = data.aws_ami.latest_postgres_image.id # us-west-2
  instance_type   = var.postgres_machine_data.type
  key_name        = var.key_pair_name
  subnet_id       = tolist(var.private_subnet_ids)[1]
  security_groups = [aws_security_group.postgres_sg.id]
  user_data       = file(var.postgres_user_script)  
  tags = {
    "Name" = var.postgres_machine_data.name
  }
  depends_on = [
    aws_security_group.postgres_sg
  ]
}
