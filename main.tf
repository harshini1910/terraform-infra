terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# Use default VPC for simplicity
data "aws_vpc" "default" {
  default = true
}

# Use available subnets from default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Latest Ubuntu 22.04 LTS AMI (recommended stable for cloud labs)
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# Security group: SSH + HTTP
resource "aws_security_group" "web_sg" {
  name        = "${var.tags_project}-web-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Project = var.tags_project
    Name    = "${var.tags_project}-web-sg"
  }
}

# User data scripts for Apache & Nginx
locals {
  apache_user_data = <<-EOF
    #!/bin/bash
    set -e
    apt-get update -y
    apt-get install -y apache2
    systemctl enable apache2
    systemctl start apache2
    echo "<h1>Apache Server - $(hostname)</h1>" > /var/www/html/index.html
  EOF

  nginx_user_data = <<-EOF
    #!/bin/bash
    set -e
    apt-get update -y
    apt-get install -y nginx
    systemctl enable nginx
    systemctl start nginx
    echo "<h1>Nginx Server - $(hostname)</h1>" > /var/www/html/index.html
  EOF
}

# 2 Apache instances
resource "aws_instance" "apache" {
  count         = 2
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_name

  # distribute across subnets (if multiple exist)
  subnet_id              = data.aws_subnets.default.ids[count.index % length(data.aws_subnets.default.ids)]
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = local.apache_user_data

  tags = {
    Project = var.tags_project
    Name    = "apache-${count.index + 1}"
    Role    = "apache"
  }
}

# 2 Nginx instances
resource "aws_instance" "nginx" {
  count         = 2
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_name

  subnet_id              = data.aws_subnets.default.ids[count.index % length(data.aws_subnets.default.ids)]
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = local.nginx_user_data

  tags = {
    Project = var.tags_project
    Name    = "nginx-${count.index + 1}"
    Role    = "nginx"
  }
}
