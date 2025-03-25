# Configure the AWS Provider
provider "aws" {
  region = "us-west-2"
}



# VPC Creation
resource "aws_vpc" "voting_app_vpc" {
  cidr_block           = "${var.voting_app_vpc}"
  enable_dns_support   = true
  enable_dns_hostnames = true
  
  tags = {
    Name = "voting_app_vpc"
  }
}



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




# EC2 Instances
resource "aws_instance" "frontend_instance_anaka" {
  ami                    = "${var.ami_id}"
  instance_type          = "${var.frontend_instance_anaka}"
  key_name               = "bacon-EC2-sub-key"
  subnet_id              = aws_subnet.ec2_private_subnet.id
  vpc_security_group_ids = [aws_security_group.vote-result-sg.id]
  
  tags = {
    Name = "frontend_instance_anaka"
  }
}

resource "aws_instance" "services_instance_bacon" {
  ami                    = "${var.ami_id}" 
  instance_type          = "${var.services_instance_bacon}"
  key_name               = "bacon-EC2-sub-key"
  subnet_id              = aws_subnet.ec2_private_subnet.id
  vpc_security_group_ids = [aws_security_group.redis-worker-sg.id]
  
  tags = {
    Name = "services-instance-bacon"
  }
}

resource "aws_instance" "db_instance_donatus" {
  ami                    = "${var.ami_id}" 
  instance_type          = "${var.db_instance_donatus}"
  key_name               = "bacon-EC2-sub-key"
  subnet_id              = aws_subnet.ec2_private_subnet.id
  vpc_security_group_ids = [aws_security_group.postgres-sg.id]
  
  tags = {
    Name = "db_instance_donatus"
  }
}

resource "aws_instance" "ec2_bastion_host" {
  ami                    = "${var.ami_id}" 
  instance_type          = "${var.ec2_bastion_host}"
  key_name               = "bacon-EC2-sub-key"
  subnet_id              = aws_subnet.ALB_public_subnet.id
  vpc_security_group_ids = [aws_security_group.bastion-sg.id]
  
  tags = {
    Name = "ec2_bastion_host"
  }
}



# Remote State Configuration
resource "aws_s3_bucket" "state-s3"{
    bucket         = var.state-s3
   
  }

resource "aws_s3_bucket_versioning" "state_s3" {
  bucket = aws_s3_bucket.state-s3.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = var.terraform-state-lock
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  
  attribute {
    name = "LockID"
    type = "S"
  }
}



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



#ALB Security Group

resource "aws_security_group" "alb-sg" {
  name        = "lb-sg"
  vpc_id      = aws_vpc.voting_app_vpc.id

  tags = {
    Name = "frontend_alb_SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow-HTTP_lb" {
  security_group_id = aws_security_group.alb-sg.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port  = 80
  ip_protocol = "tcp"
  to_port = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow-HTTPS_lb" {
  security_group_id = aws_security_group.alb-sg.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port  = 443
  ip_protocol = "tcp"
  to_port = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow-HTTP_lb_81" {
  security_group_id = aws_security_group.alb-sg.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port  = 81
  ip_protocol = "tcp"
  to_port = 81
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_lb" {
  security_group_id = aws_security_group.alb-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}



# Redis/Worker(service) Security Group
resource "aws_security_group" "redis-worker-sg" {
  name   = "redis-worker-sg"
  vpc_id = aws_vpc.voting_app_vpc.id

  tags = {
    Name = "service_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_redis_from_vote_result" {
  security_group_id = aws_security_group.redis-worker-sg.id
  referenced_security_group_id = aws_security_group.vote-result-sg.id
  from_port         = 6379
  ip_protocol       = "tcp"
  to_port           = 6379
}

resource "aws_vpc_security_group_egress_rule" "allow_postgres_outbound_from_worker" {
  security_group_id = aws_security_group.redis-worker-sg.id
  referenced_security_group_id = aws_security_group.postgres-sg.id
  from_port         = 5432
  ip_protocol       = "tcp"
  to_port           = 5432
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_redis_worker" {
  security_group_id = aws_security_group.redis-worker-sg.id
  referenced_security_group_id = aws_security_group.bastion-sg.id
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "redis_worker_allow_outbound" {
  security_group_id = aws_security_group.redis-worker-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}



# Postgres Security Group
resource "aws_security_group" "postgres-sg" {
  name   = "postgres-sg"
  vpc_id = aws_vpc.voting_app_vpc.id
  tags = {
    Name = "db_postgres_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_postgres_from_worker" {
  security_group_id = aws_security_group.postgres-sg.id
  referenced_security_group_id = aws_security_group.redis-worker-sg.id
  from_port         = 5432
  ip_protocol       = "tcp"
  to_port           = 5432
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_postgres" {
  security_group_id = aws_security_group.postgres-sg.id
  referenced_security_group_id = aws_security_group.bastion-sg.id
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "postgres_allow_outbound" {
  security_group_id = aws_security_group.postgres-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "allow_postgres_from_result" {
  security_group_id = aws_security_group.postgres-sg.id
  referenced_security_group_id = aws_security_group.vote-result-sg.id  
  from_port         = 5432
  ip_protocol       = "tcp"
  to_port           = 5432
}





# Vote/Result Security Group
resource "aws_security_group" "vote-result-sg" {
  name   = "vote-result-sg"
  vpc_id = aws_vpc.voting_app_vpc.id

  tags = {
    Name = "app_vote_result_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_from_alb_80" {
  security_group_id = aws_security_group.vote-result-sg.id
  referenced_security_group_id = aws_security_group.alb-sg.id
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_from_alb_81" {
  security_group_id = aws_security_group.vote-result-sg.id
  referenced_security_group_id = aws_security_group.alb-sg.id
  from_port         = 81
  ip_protocol       = "tcp"
  to_port           = 81
}

resource "aws_vpc_security_group_egress_rule" "allow_redis_outbound" {
  security_group_id = aws_security_group.vote-result-sg.id
  referenced_security_group_id = aws_security_group.redis-worker-sg.id
  from_port         = 6379
  ip_protocol       = "tcp"
  to_port           = 6379
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_vote_result" {
  security_group_id = aws_security_group.vote-result-sg.id
  referenced_security_group_id = aws_security_group.bastion-sg.id
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "vote_result_allow_outbound" {
  security_group_id = aws_security_group.vote-result-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "allow_postgres_outbound" {
  security_group_id = aws_security_group.vote-result-sg.id
  referenced_security_group_id = aws_security_group.postgres-sg.id
  from_port         = 5432
  ip_protocol       = "tcp"
  to_port           = 5432
}




#bastion Host Security Group
resource "aws_security_group" "bastion-sg" {
  name   = "bastion-sg"
  vpc_id = aws_vpc.voting_app_vpc.id

  tags = {
    Name = "ec2_bastion_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_from_internet" {
    security_group_id = aws_security_group.bastion-sg.id
    cidr_ipv4         = "0.0.0.0/0"
    from_port         = 22
    ip_protocol       = "tcp"
    to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "bastion_to_vote_result" {
  security_group_id = aws_security_group.bastion-sg.id
  referenced_security_group_id = aws_security_group.vote-result-sg.id
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "bastion_to_redis_worker" {
  security_group_id = aws_security_group.bastion-sg.id
  referenced_security_group_id = aws_security_group.redis-worker-sg.id
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "bastion_to_postgres" {
  security_group_id = aws_security_group.bastion-sg.id
  referenced_security_group_id = aws_security_group.postgres-sg.id
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "bastion_allow_outbound" {
  security_group_id = aws_security_group.bastion-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}



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



# Application Load Balancer
resource "aws_lb" "voting-applications-alb" {
  name               = "voting-applications-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg.id]
  subnets            = [aws_subnet.ALB_public_subnet_1.id, aws_subnet.ALB_public_subnet.id]

  tags = {
    Name = "voting-applications-alb"
  }
}

# Target Group for Port 80
resource "aws_lb_target_group" "frontend-80-tg" {
  name     = "frontend-80-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.voting_app_vpc.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "frontend-80-tg"
  }
}

# Target Group for Port 81
resource "aws_lb_target_group" "frontend-81-tg" {
  name     = "frontend-81-tg"
  port     = 81
  protocol = "HTTP"
  vpc_id   = aws_vpc.voting_app_vpc.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "frontend-81-tg"
  }
}

# Attach frontend instance to both target groups
resource "aws_lb_target_group_attachment" "frontend-80" {
  target_group_arn = aws_lb_target_group.frontend-80-tg.arn
  target_id        = aws_instance.frontend_instance_anaka.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "frontend-81" {
  target_group_arn = aws_lb_target_group.frontend-81-tg.arn
  target_id        = aws_instance.frontend_instance_anaka.id
  port             = 81
}

# Listener for Port 80
resource "aws_lb_listener" "http-80" {
  load_balancer_arn = aws_lb.voting-applications-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend-80-tg.arn
  }
}


