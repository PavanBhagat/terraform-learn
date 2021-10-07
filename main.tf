provider "aws" {
  region     = "us-east-1"
  secret_key = "Q/ITqHe7s3yepoiPQAo+ZHWwU9AOAmD9H6LbXiPM"
  access_key = "AKIA5A6TOYWOICLVPIW5"
}
variable "vpc_cidr-blocks" {}

variable "subnet_cidir-blocks" {}

variable "env-prefix" {}

variable "AZ" {}

variable "my_ip" {}

resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr-blocks
  tags = {
    Name = "${var.env-prefix}-vpc"
  }
}

resource "aws_subnet" "my-app_subnet-1" {
  vpc_id            = aws_vpc.myapp-vpc.id
  cidr_block        = var.subnet_cidir-blocks
  availability_zone = var.AZ
  tags = {
    Name = "${var.env-prefix}-subnet-1"
  }
}

resource "aws_route_table" "myapp-route-table" {
  vpc_id = aws_vpc.myapp-vpc.id
  route {
    cidr_block = "0.0.0.0/0"

  gateway_id = aws_internet_gateway.myapp-internet-gateway.id
  }

  tags = {
    Name = "${var.env-prefix}-rtb"
  }
}

resource "aws_internet_gateway" "myapp-internet-gateway" {

  vpc_id = aws_vpc.myapp-vpc.id

  tags = {
    Name = "${var.env-prefix}-igw"
  }
}

resource "aws_route_table_association" "myapp-rtb-asso" {
  route_table_id = aws_route_table.myapp-route-table.id
  subnet_id = aws_subnet.my-app_subnet-1.id
}

resource "aws_security_group" "myapp-sg" {
  name = "myapp-sg"
  vpc_id = aws_vpc.myapp-vpc.id
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = [var.my_ip]
  }
  ingress {
    from_port = 8080
    protocol = "tcp"
    to_port = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env-prefix}-sg"
  }
}