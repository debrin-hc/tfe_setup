terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

#data "aws_ami" "ubuntu" {
#  most_recent = true
#  owners      = ["self", "amazon"]
#
#  filter {
#    name   = "name"
#    values = ["hc-base-ubuntu-2204-*"]
#  }
#}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name_prefix}-vpc"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name_prefix}-igw"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name_prefix}-public-subnet"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.name_prefix}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "tfe" {
  name        = "${var.name_prefix}-sg"
  description = "Security group for Terraform Enterprise"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-sg"
  }
}

resource "aws_instance" "tfe" {
  ami                         = "ami-00a75634d835d9f15"
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.tfe.id]
  associate_public_ip_address = true
  availability_zone           = var.availability_zone
  key_name                    = aws_key_pair.tfe.key_name

  user_data = templatefile("${path.module}/user_data.sh.tftpl", {
    tfe_license             = var.tfe_license
    tfe_hostname            = var.tfe_hostname
    tfe_encryption_password = var.tfe_encryption_password
    tfe_image               = var.tfe_image
    tls_cert_pem            = var.tls_cert_pem
    tls_key_pem             = var.tls_key_pem
    tls_bundle_pem          = var.tls_bundle_pem
  })

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name = "${var.name_prefix}-ec2"
  }
}

resource "aws_ebs_volume" "tfe_data" {
  availability_zone = var.availability_zone
  size              = var.data_volume_size
  type              = "gp3"

  tags = {
    Name = "${var.name_prefix}-data"
  }
}

resource "aws_volume_attachment" "tfe_data" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.tfe_data.id
  instance_id = aws_instance.tfe.id
}
