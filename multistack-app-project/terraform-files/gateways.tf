# Internet Gateway for public subnet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.voting_app_vpc.id
  
  tags = {
    Name = "voting-app-igw"
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
}

# NAT Gateway
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id 
  subnet_id     = aws_subnet.ALB_public_subnet.id
  
  tags = {
    Name = "voting-app-nat-gw"
  }
}