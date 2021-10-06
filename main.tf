provider "aws" {
  region     = "us-east-1"
  secret_key = "Q/ITqHe7s3yepoiPQAo+ZHWwU9AOAmD9H6LbXiPM"
  access_key = "AKIA5A6TOYWOICLVPIW5"
}
variable "cidr-blocks" {
  description = "cidr for vpc and subnet"
  type        = list(object({ cidr_block = string, name = string }))
}
variable "envirnoment" {

}
resource "aws_vpc" "dev-vpc" {
  cidr_block = var.cidr-blocks[0].cidr_block
  tags = {
    Name = var.cidr-blocks[0].name
  }
}

resource "aws_subnet" "dev-subnet-1" {
  vpc_id            = aws_vpc.dev-vpc.id
  cidr_block        = var.cidr-blocks[1].cidr_block
  availability_zone = "us-east-1a"
  tags = {
    Name = var.cidr-blocks[1].name
    envr = var.envirnoment
  }
}

data "aws_vpc" "existing-test-vpc" {
  cidr_block = "10.209.64.0/24"
}

resource "aws_subnet" "test-sb-3" {
  cidr_block        = "10.209.64.64/26"
  vpc_id            = data.aws_vpc.existing-test-vpc.id
  availability_zone = "us-east-1d"

  tags = {
    Name = "test-sb-3-new"
  }
}
output "dev-vpc-id" {
  value = aws_subnet.dev-subnet-1.id
}