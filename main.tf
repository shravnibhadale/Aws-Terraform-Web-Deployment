terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.52.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1" # Mumbai Region
}

# ==============================================================================
# S3 BUCKET
# ==============================================================================
resource "aws_s3_bucket" "example" {
  bucket = "my-tf-test-bucket11bbbcc22"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

# ==============================================================================
# DEFAULT NETWORKING LAYER
# ==============================================================================

# 1. Adopt your existing Default VPC
resource "aws_default_vpc" "main_vpc" {
  tags = {
    Name        = "Default VPC"
    Environment = "Dev"
  }
}

# 2. Adopt an existing Default Subnet inside your Default VPC
resource "aws_default_subnet" "public_subnet" {
  availability_zone = "ap-south-1a"

  tags = {
    Name        = "Default Subnet 1a"
    Environment = "Dev"
  }
}

# ==============================================================================
# SECURITY GROUPS & SSH KEYS
# ==============================================================================

# 3. Security Group
resource "aws_security_group" "ec2_sg" {
  name        = "allow-ssh-web"
  description = "Allow inbound SSH and HTTP traffic"
  vpc_id      = aws_default_vpc.main_vpc.id

  # Inbound Rule: Allow SSH from anywhere
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound Rule: Allow HTTP web traffic
  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound Rule: Allow all traffic out
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "ec2-security-group"
    Environment = "Dev"
  }
}

# 4. Generate local private key
resource "tls_private_key" "rsa_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# 5. Send public key to AWS
resource "aws_key_pair" "deployer_key" {
  key_name   = "tf-deployer-key"
  public_key = tls_private_key.rsa_key.public_key_openssh
}

# 6. Save private key locally (.pem file)
resource "local_file" "private_key" {
  content         = tls_private_key.rsa_key.private_key_pem
  filename        = "${path.module}/tf-deployer-key.pem"
  file_permission = "0400" 
}

# ==============================================================================
# COMPUTE LAYER (EC2 Server with Automated Web Server Install)
# ==============================================================================

# 7. EC2 Instance (t3.micro for Free Tier Eligibility)
resource "aws_instance" "web_server" {
  ami           = "ami-0dee22c13ea7a9a67" # Ubuntu 24.04 LTS for ap-south-1
  instance_type = "t3.micro"               

  subnet_id              = aws_default_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = aws_key_pair.deployer_key.key_name
  user_data              = <<-EOF
    #!/bin/bash
    sudo apt update -y
    sudo apt install apache2 -y
    cd /var/www/html
    sudo rm -rf *
    git clone https://github.com/shravnibhadale/Aws-Terraform-Web-Deployment.git .
    systemctl restart apache2
  EOF
  tags = {
    Name        = "Terraform-Managed-Server"
    Environment = "Dev"
  }
}

# ==============================================================================
# OUTPUT BLOCKS
# ==============================================================================

output "vpc_id" {
  description = "The ID of the default VPC used"
  value       = aws_default_vpc.main_vpc.id
}

output "instance_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.web_server.public_ip
}

output "web_server_url" {
  description = "The link to test your new web server in a browser tab"
  value       = "http://${aws_instance.web_server.public_ip}"
}

output "ssh_connection_command" {
  description = "The exact terminal command to run locally to connect to the server"
  value       = "ssh -i ${local_file.private_key.filename} ubuntu@${aws_instance.web_server.public_ip}"
}
