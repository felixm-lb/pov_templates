resource "aws_s3_bucket" "config" {
  bucket = "lb-demo-config-bucket-${random_id.deployment_code.hex}"
  force_destroy = true // Destroy the bucket if not empty

  tags = var.tags
}