# Create an AWS Virtual Private Cloud (VPC) with the specified CIDR block.
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "${var.environment}-VPC"
  }
}
