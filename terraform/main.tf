terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region     = "eu-north-1"
  access_key = ""
  secret_key = ""
}

resource "aws_instance" "fcs_frontend" {
  ami           = "ami-0dd574ef87b79ac6c"
  instance_type = "t3.micro"
  key_name      = aws_key_pair.terraform_ec2_key.key_name
  vpc_security_group_ids = [aws_security_group.fcs_sg.id]

  tags = {
    Name = "FCS-Frontend"
  }
}

resource "aws_instance" "fcs_backend" {
  ami           = "ami-0dd574ef87b79ac6c"
  instance_type = "t3.micro"
  key_name      = aws_key_pair.terraform_ec2_key.key_name
  vpc_security_group_ids = [aws_security_group.fcs_sg.id]

  tags = {
    Name = "FCS-Backend"
  }
}

resource "aws_instance" "fcs_database" {
  ami           = "ami-0dd574ef87b79ac6c"
  instance_type = "t3.micro"
  key_name      = aws_key_pair.terraform_ec2_key.key_name
  vpc_security_group_ids = [aws_security_group.fcs_sg.id]
  tags = {
    Name = "FCS-Database"
  }
}

resource "aws_key_pair" "terraform_ec2_key" {
  key_name   = "terraform_ec2_key"
  public_key = file("terraform_ec2_key.pub")
}


resource "aws_security_group" "fcs_sg" {
  name        = "fcs_sg"
  description = "Allow SSH, HTTP and MONGO"
  vpc_id      = data.aws_vpc.default.id 

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "MONGO"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_vpc" "default" {
  default = true
}


output "instances_info" {
  description = "IPs publiques et noms DNS des instances"
  value = {
    frontend = {
      ip  = aws_instance.fcs_frontend.public_ip
      dns = aws_instance.fcs_frontend.public_dns
    }
    backend = {
      ip  = aws_instance.fcs_backend.public_ip
      dns = aws_instance.fcs_backend.public_dns
    }
    database = {
      ip  = aws_instance.fcs_database.public_ip
      dns = aws_instance.fcs_database.public_dns
    }
  }
}


