# Create data source to fetch private subnets based on their tags.
data "aws_subnets" "private-subnets" {
  filter {
    name   = "tag:Name"
    values = ["Private-Subnet-*"]
  }
  depends_on = [aws_subnet.private-subnet]
}

# Create data source to fetch public subnets based on their tags.
data "aws_subnets" "public-subnets" {
  filter {
    name   = "tag:Name"
    values = ["Public-Subnet-*"]
  }
  depends_on = [aws_subnet.public-subnet]
}

# Create public subnets based on the provided CIDR blocks.
resource "aws_subnet" "public-subnet" {
  count = length(var.public_subnet_cidr)

  cidr_block        = var.public_subnet_cidr[count.index]
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "${var.region}${var.zones[count.index]}"

  tags = {
    Name = "Public-Subnet-${count.index}"
  }
  depends_on = [
    aws_vpc.vpc
  ]
}

# Create private subnets based on the provided CIDR blocks.
resource "aws_subnet" "private-subnet" {
  count = length(var.private_subnet_cidr)

  cidr_block        = var.private_subnet_cidr[count.index]
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "${var.region}${var.zones[count.index]}"

  tags = {
    Name = "Private-Subnet-${count.index}"
  }
  depends_on = [
    aws_vpc.vpc
  ]
}
