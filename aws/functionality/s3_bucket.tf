resource "aws_s3_bucket" "config" {
  bucket = "lb-demo-config-bucket-${random_id.deployment_code.hex}"

  tags = var.tags
}