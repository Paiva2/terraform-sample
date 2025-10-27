resource "aws_vpc" "app_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
}

# Subnets for ALB
resource "aws_subnet" "public_subnet_alb_a" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "${var.aws_region}a"
}

resource "aws_subnet" "public_subnet_alb_b" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true
}

# Subnet for APP
resource "aws_subnet" "public_subnet_ec2_app" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.app_vpc.id
}

resource "aws_route_table" "public_routing_table" {
  vpc_id = aws_vpc.app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "lb_public_assoc_subnet_a" {
  subnet_id      = aws_subnet.public_subnet_alb_a.id
  route_table_id = aws_route_table.public_routing_table.id
}

resource "aws_route_table_association" "lb_public_assoc_subnet_b" {
  subnet_id      = aws_subnet.public_subnet_alb_b.id
  route_table_id = aws_route_table.public_routing_table.id
}

resource "aws_route_table_association" "app_public_assoc_ec2" {
  subnet_id      = aws_subnet.public_subnet_ec2_app.id
  route_table_id = aws_route_table.public_routing_table.id
}