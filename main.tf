terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.52.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "ap-south-1"
}

#vpc
#subnet
#route table
#internet gateway
#association
#ec2 instance
#security group
#output block 

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/24"
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "Custom VPC"
  }
}
resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.0.0/25"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "Public Subnet"
  }
}

resource "aws_route_table" "terrart"{
    vpc_id = aws_vpc.main.id
    
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.CustomIGW.id
    }
    tags = {
        Name = "CustomRT"
    }
}


resource "aws_internet_gateway" "CustomIGW" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "CustomIGW"
  }
}

resource "aws_route_table_association" "association" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.terrart.id
}
resource "aws_key_pair" "deployer" {
  key_name   = "customkey"
  public_key = file("customkey.pub")
}

resource "aws_instance"  "newinstance" {
      ami = "ami-01a00762f46d584a1"
      subnet_id = aws_subnet.main.id
      instance_type = "t3.micro"
      key_name = aws_key_pair.deployer.id
     user_data = file("script.sh")
     security_groups = [aws_security_group.custom_sg.id]
     associate_public_ip_address = true

      
      root_block_device {
        volume_size = 8
        volume_type = "gp3"

      }
      tags = {
        Name = "CustomTerrainstance"
      }
}

resource "aws_security_group" "custom_sg" {
    vpc_id = aws_vpc.main.id
    name = "custom_sg"

    ingress{
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress{
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress{
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

output "instance_public_ip" {
  value = aws_instance.newinstance.public_ip
}
output "instance_private_ip" {
  value = aws_instance.newinstance.public_dns
}