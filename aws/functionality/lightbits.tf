resource "aws_cloudformation_stack" "lightbits_cf" {
  name = "lb-demo-stack-${random_id.deployment_code.hex}"

  capabilities = [ "CAPABILITY_IAM" ] // Required because we're deploying IAM related resources in the nested stacks

  parameters = {
    //Network
    "AvailabilityZone" = var.availability_zone[0]
    "ExistingVpcId" = var.existing_vpc_id
    "VpcCIDR" = var.vpc_cidr
    "PrivateSubnetCIDR" = var.private_subnet_cidr
    "ConnectivityCIDR" = var.vpc_cidr

    //Storage
    "InstanceCount" = var.instance_count
    "InstanceType" = var.instance_type[0]
    "KeyPairName" = aws_key_pair.generated_key.id
    "S3ConfBucketName" = aws_s3_bucket.config.id

    //Backup
    "EnableBackupService" = var.enable_backup_service
    "ExporterImageId" = var.exporter_instance_type[0]
    "S3BackupBucketName" = var.s3_backup_bucket_name
  }

  template_url = var.lb_latest_template_url

  tags = var.tags
}

data "aws_vpc" "lb_vpc" {
  filter {
    name = "tag:Name"
    values = [format("*${aws_cloudformation_stack.lightbits_cf.name}*")]
  }
}

data "aws_subnet" "private_sn" {
  filter {
    name = "tag:Name"
    values = [format("*${aws_cloudformation_stack.lightbits_cf.name}*private*")]
  }
}

data "aws_security_group" "targets" {
    filter {
        name = "tag:Name"
        values = [format("*${aws_cloudformation_stack.lightbits_cf.name}*")]
    }
}

data "aws_iam_instance_profile" "targets" {
    name = format("*${aws_cloudformation_stack.lightbits_cf.name}*storage*")
}
