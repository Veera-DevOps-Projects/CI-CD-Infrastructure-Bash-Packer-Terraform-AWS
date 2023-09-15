# Define the AWS region where the infrastructure will be deployed.
variable "region" {
  default     = "eu-central-1"
  description = "AWS Region"
}

# Define the environment name to be used in resource naming.
variable "environment" {
  description = "Environment"
}

# Define the CIDR block for the Virtual Private Cloud (VPC).
variable "vpc_cidr" {
  description = "CIDR Block for VPC"
}

# Define a list of CIDR addresses for public subnets.
variable "public_subnet_cidr" {
  type        = list(string)
  description = "CIDR address for public subnets"
}

# Define a list of CIDR addresses for private subnets.
variable "private_subnet_cidr" {
  type        = list(string)
  description = "CIDR address for private subnets"
}

# Define a list of availability zones for subnet deployment.
variable "zones" {
  type        = list(string)
  description = "Availability zones for subnet deployment"
}
