terraform {
  # Terraform version constraints (optional)
  # required_version = ">= 4.48.0"

  # Configure the Terraform backend to store state in an S3 bucket
  backend "s3" {
    bucket = "ci-cd-packer-terraform-demo" # Name of the S3 bucket
    key    = "dev/ci-cd-packer-terraform/terraform.tfstate" # Key (path) for the state file
    region = "eu-central-1" # AWS region for the S3 bucket

    # Enable state locking with DynamoDB
    dynamodb_table = "ci-cd-packer-terraform" # Name of the DynamoDB table
  }
}

# Configure the AWS provider with the specified region
provider "aws" {
  region = var.region # Use the region specified in the "region" variable
}
