provider "aws" {
  region = "eu-west-2"
}

variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable "availability_zone" {}
variable "env_prefix" {}
variable "my_ip" {}
variable "instance_type" {}
variable "key_pair" {}
variable "public_key_location" {}

resource "aws_vpc" "development-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    "Name" : "${var.env_prefix}-vpc"
  }
}

resource "aws_subnet" "dev-subnet-1" {
  vpc_id            = aws_vpc.development-vpc.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.availability_zone
  tags = {
    Name : "${var.env_prefix}-subnet"
  }
}

resource "aws_internet_gateway" "igw-subnet" {
  vpc_id = aws_vpc.development-vpc.id
  tags = {
    "Name" = "${var.env_prefix}-igw"
  }
}

resource "aws_route_table" "dev-route_table" {
  vpc_id = aws_vpc.development-vpc.id
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

# security group
resource "aws_security_group" "allow_tls" {
  name        = "${var.env_prefix}-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.development-vpc.id

  ingress {
    description = "SSH INTO INSTANCE"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    description = "APP PORT INTO INSTANCE"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description     = "APP PORT INTO INSTANCE"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name = "${var.env_prefix}-sg"
  }
}

data "aws_ami" "latest_amazon_linux_image" {
  most_recent = true
  owners      = [137112412989]
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "SSH_KEY" {
  key_name   = "server-key"
  public_key = file(var.public_key_location)
}

resource "aws_instance" "dev-ec2-instance" {
  ami                         = data.aws_ami.latest_amazon_linux_image.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.dev-subnet-1.id
  vpc_security_group_ids      = [aws_security_group.allow_tls.id]
  availability_zone           = var.availability_zone
  associate_public_ip_address = true
  key_name                    = aws_key_pair.SSH_KEY.key_name
  user_data = file("install.sh")
  tags = {
    "Name" = "${var.env_prefix}-server"
  }
}

output "ec2-public-ip" {
  value = aws_instance.dev-ec2-instance.public_ip
}