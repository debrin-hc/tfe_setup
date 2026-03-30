variable "tfe_hostname" {
  description = "Hostname that will be used for TFE."
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy resources into."
  type        = string
  default     = "ap-south-1"
}

variable "name_prefix" {
  description = "Prefix used for naming AWS resources."
  type        = string
  default     = "tfe"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "Availability zone for subnet, EC2 instance, and EBS volume."
  type        = string
  default     = "ap-south-1a"
}

variable "instance_type" {
  description = "EC2 instance type for Terraform Enterprise."
  type        = string
  default     = "t3.medium"
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH into the instance."
  type        = string
  default     = "0.0.0.0/0"
}

variable "root_volume_size" {
  description = "Size of the EC2 root volume in GB."
  type        = number
  default     = 50
}

variable "data_volume_size" {
  description = "Size of the mounted EBS data volume in GB."
  type        = number
  default     = 100
}

variable "tfe_license" {
  description = "Terraform Enterprise license."
  type        = string
  sensitive   = true
}

variable "tfe_encryption_password" {
  description = "Encryption password for Terraform Enterprise."
  type        = string
  sensitive   = true
}

variable "tfe_image" {
  description = "Terraform Enterprise image tag."
  type        = string
  default     = "images.releases.hashicorp.com/hashicorp/terraform-enterprise:v202408-1"
}

variable "tls_cert_pem" {
  description = "TLS certificate PEM content."
  type        = string
  sensitive   = true
}

variable "tls_key_pem" {
  description = "TLS private key PEM content."
  type        = string
  sensitive   = true
}

variable "tls_bundle_pem" {
  description = "TLS CA bundle PEM content."
  type        = string
  sensitive   = true
}
