# Set the AWS region to "eu-central-1"
region = "eu-central-1"

# Define VPC variables for the specific environment
vpc_cidr    = "10.0.0.0/16"   # The CIDR block for the VPC
environment = "Development"   # The environment name

# Define CIDR blocks for public subnets
public_subnet_cidr = ["10.0.1.0/24", "10.0.2.0/24"]

# Define CIDR blocks for private subnets
private_subnet_cidr = ["10.0.3.0/24", "10.0.4.0/24"]

# Define availability zones (AZs) for subnets
zones = ["a", "b"]

# Specify the key pair name for secure access
key_pair_name = "demokey1"

# Configuration for Jenkins server instance
jenkins_machine_data = {
  image = "jenkins-server"
  name  = "JenkinsServer"
  type  = "t2.micro"
}

# Configuration for Nexus server instance
nexus_machine_data = {
  image = "nexus-server"
  name  = "NexusServer"
  type  = "t2.micro"
}

# Configuration for Postgres server instance
postgres_machine_data = {
  image = "postgres-sonardb-server"
  name  = "PostgresServer"
  type  = "t2.micro"
}

# Configuration for Sonarqube server instance
sonarqube_machine_data = {
  image = "sonarqube-server"
  name  = "SonarqubeServer"
  type  = "t2.micro"
}

# Specify the owner of the Amazon Machine Images (AMIs)
image_owner = "200244692886"

# Configuration for the jumpbox (Bastion Server)
jumpbox_image_id = "ami-00874d747dde814fa"
jumpbox_name     = "BastionServer"
jumpbox_type     = "t2.micro"

