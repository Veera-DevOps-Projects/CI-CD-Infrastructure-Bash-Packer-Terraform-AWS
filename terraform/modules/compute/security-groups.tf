# Create an AWS security group for the Jenkins EC2 instance.
resource "aws_security_group" "jenkins_sg" {
  name        = "Jenkins-SG"
  description = "Jenkins EC2 instance security rules"
  vpc_id      = var.vpc_id # Specify the VPC ID.

  # Define ingress rules to allow incoming traffic.
  ingress {
    from_port       = 8080
    protocol        = "TCP"
    to_port         = 8080
    security_groups = [aws_security_group.buildplatform_lb_security_group.id] # Allow traffic from the load balancer.
    description     = "Traffic from load balancer"
  }

  ingress {
    from_port       = 22
    protocol        = "TCP"
    to_port         = 22
    security_groups = [aws_security_group.jumpbox_sg.id] # Allow traffic from the jumpbox.
    description     = "Traffic from jumpbox"
  }

  # Define an egress rule to allow all outbound traffic.
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  depends_on = [
    aws_security_group.jumpbox_sg,
    aws_security_group.buildplatform_lb_security_group
  ]
}

# Create an AWS security group for the Nexus EC2 instance.
resource "aws_security_group" "nexus_sg" {
  name        = "Nexus-SG"
  description = "Nexus EC2 instance security rules"
  vpc_id      = var.vpc_id # Specify the VPC ID.

  # Define ingress rules to allow incoming traffic.
  ingress {
    from_port       = 8081
    protocol        = "TCP"
    to_port         = 8081
    security_groups = [aws_security_group.buildplatform_lb_security_group.id] # Allow traffic from the load balancer.
    description     = "Traffic from load balancer"
  }

  ingress {
    from_port       = 8081
    protocol        = "TCP"
    to_port         = 8081
    security_groups = [aws_security_group.jenkins_sg.id] # Allow traffic from Jenkins.
  }

  ingress {
    from_port       = 22
    protocol        = "TCP"
    to_port         = 22
    security_groups = [aws_security_group.jumpbox_sg.id] # Allow traffic from the jumpbox.
    description     = "Traffic from jumpbox"
  }

  # Define an egress rule to allow all outbound traffic.
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  depends_on = [
    aws_security_group.jumpbox_sg,
    aws_security_group.buildplatform_lb_security_group,
    aws_security_group.jenkins_sg
  ]
}

# Create an AWS security group for the SonarQube EC2 instance.
resource "aws_security_group" "sonarqube_sg" {
  name        = "SonarQube-SG"
  description = "SonarQube EC2 instance security rules"
  vpc_id      = var.vpc_id # Specify the VPC ID.

  # Define ingress rules to allow incoming traffic.
  ingress {
    from_port       = 80
    protocol        = "TCP"
    to_port         = 80
    security_groups = [aws_security_group.jenkins_sg.id] # Allow traffic from Jenkins.
    description     = "Traffic from jenkins sg"
  }

  ingress {
    from_port       = 80
    protocol        = "TCP"
    to_port         = 80
    security_groups = [aws_security_group.buildplatform_lb_security_group.id] # Allow traffic from the load balancer.
    description     = "Traffic from load balancer"
  }

  ingress {
    from_port       = 22
    protocol        = "TCP"
    to_port         = 22
    security_groups = [aws_security_group.jumpbox_sg.id] # Allow traffic from the jumpbox.
    description     = "Traffic from jumpbox"
  }

  # Define an egress rule to allow all outbound traffic.
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  depends_on = [
    aws_security_group.jumpbox_sg,
    aws_security_group.buildplatform_lb_security_group,
    aws_security_group.jenkins_sg
  ]
}

# Create an AWS security group for the Postgres EC2 instance.
resource "aws_security_group" "postgres_sg" {
  name        = "Postgres-SG"
  description = "Postgres EC2 instance security rules"
  vpc_id      = var.vpc_id # Specify the VPC ID.

  # Define ingress rules to allow incoming traffic.
  ingress {
    from_port       = 5432
    protocol        = "TCP"
    to_port         = 5432
    security_groups = [aws_security_group.sonarqube_sg.id] # Allow traffic from SonarQube.
    description     = "Traffic from sonarqube sg"
  }

  ingress {
    from_port       = 22
    protocol        = "TCP"
    to_port         = 22
    security_groups = [aws_security_group.jumpbox_sg.id] # Allow traffic from the jumpbox.
    description     = "Traffic from jumpbox"
  }

  # Define an egress rule to allow all outbound traffic.
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  depends_on = [
    aws_security_group.jumpbox_sg,
    aws_security_group.sonarqube_sg
  ]
}

# Create an AWS security group for the BuildPlatform load balancer.
resource "aws_security_group" "buildplatform_lb_security_group" {
  name        = "BuildPlatform-LB-SG"
  description = "BuildPlatform LB Security Group"
  vpc_id      = var.vpc_id # Specify the VPC ID.

  # Define an ingress rule to allow all inbound traffic to the load balancer.
  ingress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow web traffic to load balancer"
  }

  # Define egress rules if needed.

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an AWS security group for the JumpBox EC2 instance.
resource "aws_security_group" "jumpbox_sg" {
  name        = "JumpBox-SG"
  description = "JumpBox EC2 instance security rules"
  vpc_id      = var.vpc_id # Specify the VPC ID.

  # Define ingress rules to allow SSH traffic (port 22) from anywhere.
  ingress {
    from_port   = 22
    protocol    = "TCP"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Define egress rules if needed.

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
