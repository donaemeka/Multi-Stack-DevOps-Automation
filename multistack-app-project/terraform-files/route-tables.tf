# Private Route Table
resource "aws_route_table" "private_route" {
  vpc_id = aws_vpc.voting_app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw.id
  }
  tags = {
    Name = "private_route"
  }
}

# Associate Private Subnet with Private Route Table
resource "aws_route_table_association" "private_route_assoc" {
  subnet_id      = aws_subnet.ec2_private_subnet.id
  route_table_id = aws_route_table.private_route.id
}



# Route Table for Public Subnet
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.voting_app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# Associate Public Subnet with Public Route Table
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.ALB_public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_association_1" {
  subnet_id      = aws_subnet.ALB_public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}
