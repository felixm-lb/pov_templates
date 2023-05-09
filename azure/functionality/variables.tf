// Functional

variable "tags" {
    description = "Tags to be assigned to resources"
    type = map
    default = {
        Creator = "Demo"
        Method = "Terraform"
    }
}

variable "region" {
  description = "Region to be used"
  type = list(string)
  default = [
    "US East"
    ]
}

variable "zone" {
  description = "Region to be used"
  type = list(string)
  default = [
    "1"
    ]
}

variable "username" {
  description = "Username for login"
  type = string
  default = "azureuser"
}

// Network

variable "address_space" {
  description = "The IP address space that will be used for the network"
  type = list(string)
  default = [ "10.0.0.0/16" ]
}

variable "address_subnet_space" {
  description = "The IP address space that will be used for the subnet"
  type = string
  default = "10.0.0.0/24"
}

// Client

variable "client_count" {
    description = "Number of test clients to deploy."
    type = number
    default = 1
}

variable "client_instance_type" {
  description = "The type of client instance."
  type = list(string)
  default = [
    "Standard_D2s_v3"
    ]
}

// Lightbits

variable "lb_latest_template_url" {
  description = "URL of the latest Lightbits Cloud Formation template"
  type = string
  default = "https://lightbits-docs.s3.amazonaws.com/latest/cf-lb-root-marketplace.yml"
}

// Storage Config

variable "instance_count" {
  description = "The number of storage instances to initiate a storage cluster. A minimum of 3 is allowed, up to 16."
  type = number

  validation {
    condition = var.instance_count >= 3 && var.instance_count <= 16
    error_message = "The cluster size must be between 3 and 16 instances!"
  }

  default = 3
}

variable "target_instance_type" {
  description = "The type of storage instance. The instance type will dictate the storage, network, and CPU configuration. Supported type of instances: I3en storage class, i4i storage class (specific instance types in each class)"
  type = list(string)
  default = [
    "Standard_L16s_v3"
    ]
}