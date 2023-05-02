resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "lb-demo-key-${random_id.deployment_code.hex}"
  public_key = tls_private_key.example.public_key_openssh

  tags = var.tags
}

output "private_key" {
  value     = tls_private_key.example.private_key_pem
  sensitive = true
}