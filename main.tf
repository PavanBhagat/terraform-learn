provider "aws" {
  region     = "us-east-1"
}


/*variable "private-key-location"{}*/
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  cidr = var.vpc_cidr-blocks
  name = "my-vpc"

  azs             = [var.AZ]
  public_subnets  = [var.subnet_cidir-blocks]
  private_subnet_tags = {Name = "${var.env-prefix}-subnet-1"}
  public_route_table_tags = {Name = "${var.env-prefix}-rtb"}
  tags = {
    Name = "${var.env-prefix}-vpc"

  }
}


module "my-web-sg" {
  source = "./modules/security-group"
  vpc-id = module.vpc.vpc_id
  env-prefix = var.env-prefix
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



resource "aws_key_pair" "tf-gen-key" {
  key_name = "tf-gen-key"
  public_key = file(var.rsa-key-location)
}


resource "aws_instance" "myapp-server" {
  ami = data.aws_ami.latest-aws-linux-ami.id
  instance_type = var.instance_type
  subnet_id = module.vpc.public_subnets[0]
  vpc_security_group_ids = [module.my-web-sg.security-group.id]
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
