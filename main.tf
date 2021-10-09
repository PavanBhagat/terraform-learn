provider "aws" {
  region     = "us-east-1"
}
variable "vpc_cidr-blocks" {}

variable "subnet_cidir-blocks" {}

variable "env-prefix" {}

variable "AZ" {}

variable "my_ip" {}

variable "instance_type" {}

variable "rsa-key-location" {}

variable "script-path" {}

/*variable "private-key-location"{}*/

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
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
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

data "aws_ami" "latest-aws-linux-ami" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}

output "aws-public-ip" {
  value = aws_instance.myapp-server.public_ip
}

resource "aws_key_pair" "tf-gen-key" {
  key_name = "tf-gen-key"
  public_key = file(var.rsa-key-location)
}


resource "aws_instance" "myapp-server" {
  ami = data.aws_ami.latest-aws-linux-ami.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.my-app_subnet-1.id
  vpc_security_group_ids = [aws_security_group.myapp-sg.id]
  availability_zone = var.AZ
  key_name = aws_key_pair.tf-gen-key.key_name
  associate_public_ip_address = true
  user_data = file(var.script-path)

  /*provisioner "remote-exec" {
    script = file("script.sh")
  }

  connection {
    type = "ssh"
    host = self.public_ip
    user = "ec2-user"
    private_key = file(var.private-key-location)

  }

  provisioner "file"{
    source = "E:\\Scripts\\docker-script.sh"
    destination = "/home/ec2-user/script.sh"
  }
*/
  tags = {
    Name = "${var.env-prefix}-server"
  }
}
