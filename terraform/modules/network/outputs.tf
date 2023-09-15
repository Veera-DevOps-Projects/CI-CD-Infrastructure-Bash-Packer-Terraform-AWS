# Define an output for the VPC ID.
output "vpc_id" {
  value = aws_vpc.vpc.id # Output the ID of the VPC.
}

# Define an output for the VPC's CIDR block.
output "vpc_cidr_block" {
  value = aws_vpc.vpc.cidr_block # Output the CIDR block of the VPC.
}

# Define an output for the IDs of private subnets.
output "private_subnet_ids" {
  value = data.aws_subnets.private-subnets.ids # Output the IDs of private subnets using a data source.
}

# Define an output for the IDs of public subnets.
output "public_subnet_ids" {
  value = data.aws_subnets.public-subnets.ids # Output the IDs of public subnets using a data source.
}
