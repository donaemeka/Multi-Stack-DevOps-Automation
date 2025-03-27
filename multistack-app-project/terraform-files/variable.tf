variable "voting_app_vpc" {
   default = "10.0.0.0/16"
   description = "VPC CIDR Block"
   type = string
}

# create variable for ALB_public_subnet
variable "ALB_public_subnet_1" {
    default = "10.0.1.0/24"
    description = "ALB public subnet"
    type = string
}

# create variable for ALB_public_subnet
variable "ALB_public_subnet" {
    default = "10.0.2.0/24"
    description = "ALB public subnet"
    type = string
}


# create variable for ec2_private_subnet
variable "ec2_private_subnet" {
    default = "10.0.3.0/24"
    description = "private subnet for all ec2"
    type = string
}


# Create variable for frontend_instance_anaka
variable "frontend_instance_anaka"{
    default = "t2.micro"
    description = "frontend instance anaka"
    type = string
}

# Create variable for services_instance_bacon
variable "services_instance_bacon"{
    default = "t2.micro"
    description = "services instance bacon"
    type = string
}

# Create variable for db_instance-donatus
variable "db_instance_donatus"{
    default = "t2.micro"
    description = "db instance donatus"
    type = string
}

# Create variable for ec2_bastion_host
variable "ec2_bastion_host"{
    default = "t2.micro"
    description = "host for private ec2"
    type = string
}

variable "ami_id" {
    description = "AMI ID for EC2 instances"
    default     = "ami-04f5a6a7ecc99fbe2"
    type        = string
}

variable "state-s3-store"{
    description  = "s3 bucket for terraform state"
    default      = "state-s3-store"
    type         = string
}

#create variable for dynamodb
variable "terraform-state-lock"{
    description  = "terraform state lock"
    default      = "terraform-state-lock"
    type         = string
}