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





















