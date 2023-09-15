# Create a public route table associated with the VPC.
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "Public-Route-Table"
  }
}

# Create a private route table associated with the VPC.
resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "Private-Route-Table"
  }
}

# Create associations between public subnets and the public route table.
resource "aws_route_table_association" "public-route-association" {
  count = length(var.public_subnet_cidr)

  route_table_id = aws_route_table.public-route-table.id
  subnet_id      = element(aws_subnet.public-subnet.*.id, count.index)
}

# Create associations between private subnets and the private route table.
resource "aws_route_table_association" "private-route-association" {
  count = length(var.private_subnet_cidr)

  route_table_id = aws_route_table.private-route-table.id
  subnet_id      = element(aws_subnet.private-subnet.*.id, count.index)
}
