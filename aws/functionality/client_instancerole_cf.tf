resource "aws_cloudformation_stack" "client_instance_role" {
  name = "lb-demo-stack-client-permissions-${random_id.deployment_code.hex}"

  capabilities = [ "CAPABILITY_IAM", "CAPABILITY_NAMED_IAM" ] // Required because we're deploying IAM related resources

  parameters = {
      NamePrefix = "lb-demo-${random_id.deployment_code.hex}"
    }

  template_body = file("${path.module}/client_permissions_cf.yaml")
}