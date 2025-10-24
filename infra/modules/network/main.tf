resource "aws_vpc" "tf-app_vpc_ec2" {
  cidr_block = "10.123.0.0/16"
}

resource "aws_subnet" "public_subnet_ec2" {
  vpc_id            = aws_vpc.tf-app_vpc_ec2.id
  cidr_block        = "10.123.0.0/24"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "tf_igw_ec2" {
  vpc_id = aws_vpc.tf-app_vpc_ec2.id
}

resource "aws_route_table" "tf_public_rt_ec2" {
  vpc_id = aws_vpc.tf-app_vpc_ec2.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf_igw_ec2.id
  }
}

resource "aws_route_table_association" "tf_public_assoc_ec2" {
  subnet_id      = aws_subnet.public_subnet_ec2.id
  route_table_id = aws_route_table.tf_public_rt_ec2.id
}