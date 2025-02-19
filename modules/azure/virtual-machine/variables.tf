variable "prefix" {
  description = "Specifies the prefix added to the names of all resources. Default is 'azure-tf'."
  type        = string
  default     = "azure-tf"
}

variable "region" {
  description = "Specifies the Azure region used for all resources. Default is 'eastus'."
  type        = string
  default     = "spaincentral"
  validation {
    condition = contains([
      "eastus",
      "eastus2",
      "centralus",
      "northcentralus",
      "southcentralus",
      "westus",
      "westus2",
      "northeurope",
      "westeurope",
      "spaincentral",
      "francecentral",
      "germanycentral",
      "centralindia",
      "southindia",
      "westindia",
      "israelcentral",
      "japaneast",
      "koreacentral",
      "koreasouth",
      "norwayeast",
      "norwaywest",
      "singapore",
      "swedencentral",
      "switzerlandnorth",
      "uaecentral",
      "ukwest",
      "uksouth"
    ], var.region)
    error_message = "Invalid Region specified."
  }
}

variable "create_ssh_key_pair" {
  description = "Specifies whether a new SSH key pair needs to be created for the instances. Default is 'true'."
  type        = bool
  default     = true
}

variable "ssh_private_key_path" {
  description = "Specifies the full path where the pre-generated SSH PRIVATE key is located (not generated by Terraform). Default is 'null'."
  type        = string
  default     = null
}

variable "ssh_public_key_path" {
  description = "Specifies the full path where the pre-generated SSH PUBLIC key is located (not generated by Terraform). Default is 'null'."
  type        = string
  default     = null
}

variable "ip_cidr_range" {
  description = "Specifies the range of private IPs available for the Google Subnet. Default is '10.10.0.0/24'."
  type        = string
  default     = "10.10.0.0/24"
}

variable "create_vnet" {
  description = "Specifies whether a VPC and Subnet should be created for the instances. Default is 'true'."
  type        = bool
  default     = true
}

variable "spot_instance" {
  description = "Specifies whether the instances should be Spot (preemptible) VMs. Default is 'true'."
  type        = bool
  default     = false
}

variable "os_disk_type" {
  description = "Specifies the type of the disk attached to each node (e.g., 'Premium_LRS', 'Standard_LRS'). Default is 'Premium_LRS'."
  type        = string
  default     = "Premium_LRS"
}

variable "os_disk_size" {
  description = "Specifies the size of the disk attached to each node, in GB. Default is '50'."
  type        = number
  default     = 50
}

variable "instance_type" {
  description = "Specifies the name of a Azure Virtual Machine size. Default is 'Standard_D16as_v5'."
  type        = string
  default     = "Standard_D16as_v5"
}

variable "create_data_disk" {
  description = "Specifies whether to create an additional data disk for each VM instance. Default is 'true'."
  type        = bool
  default     = true
}

variable "data_disk_count" {
  description = "Specifies the number of data disks to create (1 or 3). Default is '1'."
  type        = number
  default     = 1
  validation {
    condition     = contains([1, 3], var.data_disk_count)
    error_message = "The number of data disks must be 1 or 3."
  }
}

variable "data_disk_type" {
  description = "Specifies the type of the disk attached to each node (e.g., 'Premium_LRS', 'Standard_LRS'). Default is 'Premium_LRS'."
  type        = string
  default     = "Premium_LRS"
}

variable "data_disk_size" {
  description = "Specifies the size of the additional data disk for each VM instance, in GB. Default is '350'."
  type        = number
  default     = 350
}

variable "startup_script" {
  description = "Specifies a custom startup script to run when the VMs start. Default is 'null'."
  type        = string
  default     = null
}
