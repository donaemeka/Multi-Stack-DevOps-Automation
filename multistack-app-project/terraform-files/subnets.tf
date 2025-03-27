# Subnet Creation
resource "aws_subnet" "ALB_public_subnet_1" {
  vpc_id                  = aws_vpc.voting_app_vpc.id
  cidr_block              = "${var.ALB_public_subnet_1}"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true
  
  tags = {
    Name = "ALB_public_subnet_1"
  }
}

 #Subnet Creation
resource "aws_subnet" "ALB_public_subnet" {
  vpc_id                  = aws_vpc.voting_app_vpc.id
  cidr_block              = "${var.ALB_public_subnet}"
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = true
  
  tags = {
    Name = "ALB_public_subnet"
  }
}

 #Subnet Creation
resource "aws_subnet" "ec2_private_subnet" {
  vpc_id                  = aws_vpc.voting_app_vpc.id
  cidr_block              = "${var.ec2_private_subnet}"
  availability_zone       = "us-west-2a"
  
  tags = {
    Name = "ec2_private_subnet"
  }
}