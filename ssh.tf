resource "tls_private_key" "ec2" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key_pem" {
  filename        = "${path.module}/${var.name_prefix}-ec2.pem"
  content         = tls_private_key.ec2.private_key_pem
  file_permission = "0400"
}

resource "aws_key_pair" "tfe" {
  key_name   = "${var.name_prefix}-key"
  public_key = tls_private_key.ec2.public_key_openssh

  tags = {
    Name = "${var.name_prefix}-key"
  }
}

