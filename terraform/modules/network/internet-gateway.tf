# Create an AWS internet gateway and associate it with the VPC.
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id # Attach the internet gateway to the specified VPC.

  tags = {
    Name = "${var.environment}-IGW" # Assign a name to the internet gateway.
  }
}

# Define a route in the public route table to direct traffic to the internet via the internet gateway.
resource "aws_route" "public-internet-igw-route" {
  route_table_id         = aws_route_table.public-route-table.id # Specify the public route table to update.
  gateway_id             = aws_internet_gateway.igw.id # Use the internet gateway as the target.
  destination_cidr_block = "0.0.0.0/0" # Route all traffic (0.0.0.0/0) to the internet gateway.
}
