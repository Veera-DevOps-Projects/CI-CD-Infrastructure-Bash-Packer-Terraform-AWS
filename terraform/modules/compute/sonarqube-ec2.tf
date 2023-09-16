# Define a data source to retrieve the latest SonarQube Amazon Machine Image (AMI).
data "aws_ami" "latest_sonarqube_image" {
  most_recent = true
  #owners      = ["${var.image_owner}"] # Specify the AMI owner (Canonical).

  filter {
    name   = "tag:Name"
    values = ["SonarqubeImage"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Define a template_file data source to render the user data script for SonarQube.
data "template_file" "sonar_user_script" {
  template = file(var.sonar_user_script) # Use the provided user data script file.

  vars = {
    postgres_host = data.aws_instance.postgres_server_instance.private_ip # Pass the private IP of the Postgres instance.
  }

  depends_on = [
    aws_instance.postgres_server,
  ]
}

# Create an AWS instance for SonarQube.
resource "aws_instance" "sonarqube_server" {
  ami           = data.aws_ami.latest_sonarqube_image.id # Use the latest SonarQube AMI ID.
  instance_type = var.sonarqube_machine_data.type
  key_name      = var.key_pair_name
  subnet_id     = tolist(var.private_subnet_ids)[0] # Place the SonarQube instance in the specified subnet.
  security_groups = [aws_security_group.sonarqube_sg.id] # Attach the SonarQube security group.

  # Use the rendered user data script as base64-encoded user data.
  user_data_base64 = base64encode(data.template_file.sonar_user_script.rendered)

  tags = {
    "Name" = var.sonarqube_machine_data.name
  }

  depends_on = [
    aws_security_group.sonarqube_sg,
    aws_instance.postgres_server # Ensure the Postgres server is created before creating SonarQube instance.
  ]
}
