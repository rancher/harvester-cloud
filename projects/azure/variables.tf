variable "prefix" {
  description = "Specifies the prefix added to the names of all resources. Default is 'azure-tf'."
  type        = string
  default     = "azure-tf"
}

variable "subscription_id" {
  description = "Specifies the Azure Subscription ID that will contain all created resources. Default is 'azure-tf'."
  type        = string
  default     = "azure-tf"
}

variable "region" {
  description = "Specifies the Azure region used for all resources. Default is 'westeurope'."
  type        = string
  default     = "westeurope"
  validation {
    condition = contains([
      "australiacentral",
      "australiacentral2",
      "australiaeast",
      "australiasoutheast",
      "austriaeast",
      "brazilsouth",
      "brazilsoutheast",
      "canadacentral",
      "canadaeast",
      "centralindia",
      "centralus",
      "centraluseuap",
      "chilecentral",
      "eastasia",
      "eastus",
      "eastus2",
      "eastus2euap",
      "francecentral",
      "francesouth",
      "germanynorth",
      "germanywestcentral",
      "indonesiacentral",
      "israelcentral",
      "italynorth",
      "japaneast",
      "japanwest",
      "jioindiacentral",
      "jioindiawest",
      "koreacentral",
      "koreasouth",
      "malaysiasouth",
      "malaysiawest",
      "mexicocentral",
      "northcentralus",
      "northeurope",
      "norwayeast",
      "norwaywest",
      "polandcentral",
      "southafricanorth",
      "southafricawest",
      "southcentralus",
      "southcentralusstg",
      "southeastasia",
      "southindia",
      "spaincentral",
      "swedencentral",
      "switzerlandnorth",
      "switzerlandwest",
      "taiwannorth",
      "uaenorth",
      "uksouth",
      "ukwest",
      "westcentralus",
      "westeurope",
      "westus",
      "westus2",
      "westus3"
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
  description = "Specifies the range of private IPs available for the Azure Subnet. Default is '10.10.0.0/24'."
  type        = string
  default     = "10.10.0.0/24"
}

variable "create_vnet" {
  description = "Specifies whether a Virtual Network should be created for the instances. Default is 'true'."
  type        = bool
  default     = true
}

variable "spot_instance" {
  description = "Specifies whether the instances should be Spot (preemptible) VMs. Default is 'true'."
  type        = bool
  default     = false
}

variable "os_disk_type" {
  description = "Specifies the type of the disk attached to each node ('Standard_LRS, 'StandardSSD_LRS', 'Premium_LRS' or 'UltraSSD_LRS'). Default is 'Premium_LRS'."
  type        = string
  default     = "Premium_LRS"
}

variable "os_disk_size" {
  description = "Specifies the size of the disk attached to each node, in GB. Default is '50'."
  type        = number
  default     = 50
}

variable "data_disk_type" {
  description = "Specifies the type of the disk attached to each node ('Standard_LRS, 'StandardSSD_LRS', 'Premium_LRS' or 'UltraSSD_LRS'). Default is 'Premium_LRS'."
  type        = string
  default     = "Premium_LRS"
}

variable "data_disk_size" {
  description = "Specifies the size of the additional data disk for each VM instance, in GB. Default is '350'."
  type        = number
  default     = 350
}

variable "create_additional_disks" {
  description = "Specifies if 1 additional data disk on each Harvester node is required"
  type        = bool
  default     = false
}

variable "startup_script" {
  description = "Specifies a custom startup script to run when the VMs start. Default is 'null'."
  type        = string
  default     = null
}

variable "harvester_version" {
  description = "Specifies the Harvester version. Default is 'v1.4.2'."
  type        = string
  default     = "v1.4.2"
  validation {
    condition     = can(regex("^v.*$", var.harvester_version))
    error_message = "The Harvester version must start with 'v' (e.g., v1.4.1, v1.4.2-rc2, v1.5.0-dev-20250217)."
  }
}

variable "harvester_node_count" {
  description = "Specifies the number of Harvester nodes to create (1 or 3). Default is '1'."
  type        = number
  default     = 1
  validation {
    condition     = contains([1, 3], var.harvester_node_count)
    error_message = "The number of data disks must be 1 or 3."
  }
}

variable "harvester_first_node_token" {
  description = "Specifies the token used to join additional nodes to the Harvester cluster (HA setup). Default is 'SecretToken.123'."
  type        = string
  default     = "SecretToken.123"
}

variable "harvester_password" {
  description = "Specifies the password used to access the Harvester nodes. Default is 'SecretPassword.123'."
  type        = string
  default     = "SecretPassword.123"
}

variable "harvester_cluster_size" {
  description = "Specifies the size of the Harvester cluster. Allowed values are 'small' (8 CPUs, 32 GB RAM) and 'medium' (16 CPUs, 64 GB RAM). Default is 'small'."
  type        = string
  default     = "small"
  validation {
    condition     = contains(["small", "medium"], var.harvester_cluster_size)
    error_message = "Invalid value for harvester_cluster_size. Allowed values are 'small' or 'medium'."
  }
}

variable "rancher_api_url" {
  description = "Specifies the Rancher API endpoint used to manage the Harvester cluster. Default is empty."
  type        = string
  default     = ""
}

variable "rancher_access_key" {
  description = "Specifies the Rancher access key for authentication. Default is empty."
  type        = string
  default     = ""
  sensitive   = true
}

variable "rancher_secret_key" {
  description = "Specifies the Rancher secret key for authentication. Default is empty."
  type        = string
  default     = ""
  sensitive   = true
}

variable "rancher_insecure" {
  description = "Specifies whether to allow insecure connections to the Rancher API. Default is 'false'."
  type        = bool
  default     = false
}
