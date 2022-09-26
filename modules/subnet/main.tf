resource "aws_subnet" "dev-subnet-1" {
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.availability_zone
  tags = {
    Name : "${var.env_prefix}-subnet"
  }
}

resource "aws_internet_gateway" "igw-subnet" {
  vpc_id = var.vpc_id
  tags = {
    "Name" = "${var.env_prefix}-igw"
  }
}

resource "aws_route_table" "dev-route_table" {
  vpc_id = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-subnet.id
  }
  tags = {
    "Name" = "${var.env_prefix}-rtb"
  }
}

resource "aws_route_table_association" "dev-route-table-association" {
  route_table_id = aws_route_table.dev-route_table.id
  subnet_id      = aws_subnet.dev-subnet-1.id
}