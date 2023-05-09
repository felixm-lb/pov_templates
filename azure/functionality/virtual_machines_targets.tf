resource "azurerm_network_interface" "lb_target_interface" {
  count = var.instance_count

  name                = "lb-demo-target-interface-${random_id.deployment_code.hex}-${count.index}"
  location            = azurerm_resource_group.demo_rg.location
  resource_group_name = azurerm_resource_group.demo_rg.name

  ip_configuration {
    name                          = "lb-demo-target-interface-ip-config-${random_id.deployment_code.hex}"
    subnet_id                     = azurerm_virtual_network.demo_vnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  enable_accelerated_networking = true
  secure_boot_enabled = false

  tags = var.tags
}

resource "azurerm_linux_virtual_machine" "demo_target_vm" {
    count = var.instance_count

  name                = "lb-demo-target-vm-${random_id.deployment_code.hex}-${count.index}"
  location            = azurerm_resource_group.demo_rg.location
  resource_group_name = azurerm_resource_group.demo_rg.name
  size                = var.target_instance_type
  admin_username      = var.username
  network_interface_ids = [
    azurerm_network_interface.lb_target_interface[count.index].id,
  ]
  proximity_placement_group_id = azurerm_proximity_placement_group.demo_ppg.id

  admin_ssh_key {
    username   = var.username
    public_key = tls_private_key.example.public_key_pem
  }

  os_disk {
    name = "lb-demo-target-disk-${random_id.deployment_code.hex}-${count.index}"
    caching              = "None"
    storage_account_type = "Premium_LRS"
    disk_size_gb = "75"
  }

  source_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "86-gen2"
    version   = "latest"
  }

  user_data = base64encode(data.template_file.configure_target.rendered)
}

data "template_file" "configure_target" {
  template = file("configure_target.sh")
}