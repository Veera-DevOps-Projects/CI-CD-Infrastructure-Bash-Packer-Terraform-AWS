# Create an Elastic IP address and associate it with a specific private IP in the VPC.
resource "aws_eip" "elastic-ip-for-nat-gw" {
  vpc                       = true # This Elastic IP is for use in a VPC.
  associate_with_private_ip = "10.0.0.5" # Associate the Elastic IP with a specific private IP.

  tags = {
    Name = "${var.environment}-EIP" # Assign a name to the Elastic IP.
  }

  depends_on = [aws_internet_gateway.igw] # Ensure the internet gateway is created first.
}

# Create a NAT gateway and associate it with the Elastic IP.
resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.elastic-ip-for-nat-gw.id # Use the Elastic IP created above.
  subnet_id     = element(aws_subnet.public-subnet.*.id, 0) # Specify the subnet for the NAT gateway.

  tags = {
    Name = "${var.environment}-NAT-GW" # Assign a name to the NAT gateway.
  }

  depends_on = [aws_eip.elastic-ip-for-nat-gw] # Ensure the Elastic IP is allocated first.
}

# Define a route in the private route table to direct traffic to the NAT gateway.
resource "aws_route" "nat-gw-route" {
  route_table_id         = aws_route_table.private-route-table.id # Specify the private route table.
  nat_gateway_id         = aws_nat_gateway.nat-gw.id # Use the NAT gateway as the target.
  destination_cidr_block = "0.0.0.0/0" # Route all traffic (0.0.0.0/0) to the NAT gateway.
}
