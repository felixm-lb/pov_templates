resource "azurerm_resource_group" "demo_rg" {
  name = "lb-demo-group-${random_id.deployment_code.hex}"
  location = var.region[0]

  tags = var.tags
}