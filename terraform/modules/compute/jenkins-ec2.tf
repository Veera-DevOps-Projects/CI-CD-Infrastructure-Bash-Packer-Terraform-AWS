# Define a data source to retrieve the latest AWS AMI (Amazon Machine Image) for Jenkins Server.
data "aws_ami" "latest_jenkins_image" {
  most_recent = true
  owners      = ["${var.image_owner}"] # Specify the image owner (Canonical).

  # Filter the AMIs based on name, matching the provided Jenkins image name.
  filter {
    name   = "tag:Name"
    values = ["JenkinsImage"]
  }

  # Filter the AMIs based on virtualization type (HVM - Hardware Virtual Machine).
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Define an AWS EC2 instance resource for the Jenkins server using the retrieved AMI.
resource "aws_instance" "jenkins_server" {
  ami             = data.aws_ami.latest_jenkins_image.id # Use the AMI ID from the data source.
  instance_type   = var.jenkins_machine_data.type          # Specify the instance type for Jenkins.
  key_name        = var.key_pair_name                        # Use the specified SSH key pair.
  subnet_id       = tolist(var.private_subnet_ids)[0]       # Specify the subnet for the instance.
  security_groups = [aws_security_group.jenkins_sg.id]     # Attach the Jenkins security group.

  # Define tags for the Jenkins instance, including its name.
  tags = {
    "Name" = var.jenkins_machine_data.name
  }

  # Ensure the instance creation depends on the Jenkins security group.
  depends_on = [
    aws_security_group.jenkins_sg
  ]
}
