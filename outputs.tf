# output "private_key_path" {
#   description = "Path to the generated private key PEM file."
#   value       = local_file.private_key_pem.filename
#   sensitive   = true
# }

output "instance_id" {
  description = "EC2 instance ID."
  value       = aws_instance.tfe.id
}

output "public_ip" {
  description = "Public IP of the TFE instance."
  value       = aws_instance.tfe.public_ip
}

output "public_dns" {
  description = "Public DNS of the TFE instance."
  value       = aws_instance.tfe.public_dns
}

output "ssh_command" {
  description = "SSH command to connect to the instance."
  value       = "ssh -i ${local_file.private_key_pem.filename} ec2-user@${aws_instance.tfe.public_ip}"
}

output "tfe_url" {
  description = "Terraform Enterprise URL."
  value       = "https://${var.tfe_hostname}"
}

