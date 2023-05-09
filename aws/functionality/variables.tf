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
    "us-east-1"
    ]
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
    "m5.xlarge"
    ]
}

// Lightbits

variable "lb_latest_template_url" {
  description = "URL of the latest Lightbits Cloud Formation template"
  type = string
  default = "https://lightbits-docs.s3.amazonaws.com/latest/cf-lb-root-marketplace.yml"
}

// Networking

variable "availability_zone" {
  description = "Availability Zone to be used -Make sure to set the AvailabilityZone to one of the AWS Zones available within the selected Region."
  type = list(string)
  default = ["us-east-1a"]
}

variable "existing_vpc_id" {
  description = "In order for the deployment to create a new VPC for the storage cluster, leave the ExistingVpcId field with its default value of 'create-new'. Once the VPC is created, CF continues to launch storage instances and configure Lightbits storage software on that new VPC. This new VPC can be used to deploy other EC2 client instances that can use the storage within the VPC. See the table below for deployment in an existing VPC"
  type = string
  default = "create-new"
}

variable "vpc_cidr" {
  description = "The VpcCIDR is used to define the IPV4 range for the new VPC. A private subnet will be created automatically based on this range. The expected VPC range is X.X.X.0/20 (12 bits range). In this case, assuming the use of the default automatic subnet creation, the private subnet will use /24 (8bits) from the range."
  type = string
  default = "10.240.96.0/20"
}

variable "private_subnet_cidr" {
  description = "If the ‘New VPC’ option is selected above, this parameter should remain as the default value 'create-auto', which means that CF sets the subnet range automatically. However, the option of auto range is limited, and will not work on every range of VpcCIDR. If you want to enforce specific ranges, set to the desired range (with a format of x.x.x.x/x), and ensure that the range is valid and included per the VpcCIDR range."
  type = string
  default = "create-auto"
}

variable "connectivity_cidr" {
  description = "The ConnectivityCIDR is used to define an initial IP range that has access to the storage cluster as part of SecurityGroup on the new VPC. ConnectivityCIDR is used for connectivity to the storage cluster. Any client IP (or IP range) that will use or have volumes on the Lightbits storage cluster should be part of the CIDR. Setting 0.0.0.0/0 will enable access from any client IP. If the hosts’ connectivity is inside VPC, set the ConnectivityCIDR to the same as the VpcCIDR. It is also possible to set connectivity ranges or specific individual IPs after the deployment stack is up. This is possible by changing the SecurityGroup definition and adding ingress rules. Note: Changing the SecurityGroup, adding instances manually to the VPC, or in general performing any manual change to an already created resource by CF post-deployment,  means you will need to revert these changes manually before you can delete the deployment stack. Otherwise, the stack delete operation will fail."
  type = string
  default = "10.240.96.0/20"
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

variable "instance_type" {
  description = "The type of storage instance. The instance type will dictate the storage, network, and CPU configuration. Supported type of instances: I3en storage class, i4i storage class (specific instance types in each class)"
  type = list(string)
  default = [
    "i3en.6xlarge"
    ]
}

// Backup Config

variable "enable_backup_service" {
    description = "Enable backups for all volumes in the cluster."
    type = string
    default = "False"
}

variable "exporter_instance_type" {
  description = "The type of backup instance."
  type = list(string)
  default = [
    "c5n.xlarge"
    ]
}

variable "s3_backup_bucket_name" {
  description = "The name of the bucket used for backups."
  type = string
  default = "create-new"
}