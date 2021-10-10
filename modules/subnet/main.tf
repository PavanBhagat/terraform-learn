
resource "aws_subnet" "my-app_subnet-1" {
  vpc_id            = var.vpc-id
  cidr_block        = var.subnet_cidir-blocks
  availability_zone = var.AZ
  tags = {
    Name = "${var.env-prefix}-subnet-1"
  }
}

resource "aws_route_table" "myapp-route-table" {
  vpc_id = var.vpc-id
  route {
    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.myapp-internet-gateway.id
  }

  tags = {
    Name = "${var.env-prefix}-rtb"
  }
}

resource "aws_internet_gateway" "myapp-internet-gateway" {

  vpc_id = var.vpc-id

  tags = {
    Name = "${var.env-prefix}-igw"
  }
}

resource "aws_route_table_association" "myapp-rtb-asso" {
  route_table_id = aws_route_table.myapp-route-table.id
  subnet_id = aws_subnet.my-app_subnet-1.id
}