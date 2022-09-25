provider "aws" {
  region     = "eu-west-2"
}
variable "subnet_cidr_block" {
  description = "subnet cidr block"
  type = list(string)
}

resource "aws_vpc" "development-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    "Name" : "dev-vpc"
  }
}

resource "aws_subnet" "dev-subnet-1" {
  vpc_id            = aws_vpc.development-vpc.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "eu-west-2a"
  tags = {
    Name : "dev-subnet1"
  }
}
data "aws_vpc" "existing_vpc" {
  default = true
}

resource "aws_subnet" "dev-subnet-2" {
  vpc_id            = data.aws_vpc.existing_vpc.id
  cidr_block        = var.subnet_cidr_block[1] 
  availability_zone = "eu-west-2a"
  tags              = { Name : "dev-subnet2" }
}

output "output1" {
  value = aws_vpc.development-vpc.id
}
output "output2" {
  value = aws_subnet.dev-subnet-1.id
}
