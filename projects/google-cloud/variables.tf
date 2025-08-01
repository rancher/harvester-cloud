variable "prefix" {
  description = "Specifies the prefix added to the names of all resources. Default is 'gcp-tf'."
  type        = string
  default     = "gcp-tf"
}

variable "project_id" {
  description = "Specifies the Google Project ID that will contain all created resources. Default is 'gcp-tf'."
  type        = string
  default     = "gcp-tf"
}

variable "region" {
  description = "Specifies the Google region used for all resources. Default is 'us-west2'."
  type        = string
  default     = "us-west2"
  validation {
    condition = contains([
      "asia-east1",
      "asia-east2",
      "asia-northeast1",
      "asia-northeast2",
      "asia-northeast3",
      "asia-south1",
      "asia-south2",
      "asia-southeast1",
      "asia-southeast2",
      "australia-southeast1",
      "australia-southeast2",
      "europe-central2",
      "europe-north1",
      "europe-southwest1",
      "europe-west1",
      "europe-west10",
      "europe-west12",
      "europe-west2",
      "europe-west3",
      "europe-west4",
      "europe-west6",
      "europe-west8",
      "europe-west9",
      "me-central1",
      "me-central2",
      "me-west1",
      "northamerica-northeast1",
      "northamerica-northeast2",
      "southamerica-east1",
      "southamerica-west1",
      "us-central1",
      "us-east1",
      "us-east4",
      "us-east5",
      "us-south1",
      "us-west1",
      "us-west2",
      "us-west3",
      "us-west4"
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

variable "create_vpc" {
  description = "Specifies whether a VPC and Subnet should be created for the instances. Default is 'true'."
  type        = bool
  default     = true
}

variable "vpc" {
  description = "Specifies the Google VPC used for all resources. Default is 'null'."
  type        = string
  default     = null
}

variable "subnet" {
  description = "Specifies the Google Subnet used for all resources. Default is 'null'."
  type        = string
  default     = null
}

variable "create_firewall" {
  description = "Specifies whether a Google Firewall should be created for all resources. Default is 'true'."
  type        = bool
  default     = true
}

variable "spot_instance" {
  description = "Specifies whether the instances should be Spot (preemptible) VMs. Default is 'true'."
  type        = bool
  default     = true
}

variable "os_disk_type" {
  description = "Specifies the type of the disk attached to each node (e.g., 'pd-standard', 'pd-ssd', or 'pd-balanced'). Default is 'pd-ssd'."
  type        = string
  default     = "pd-ssd"
}

variable "os_disk_size" {
  description = "Specifies the size of the disk attached to each node, in GB. Default is '50'."
  type        = number
  default     = 50
}

variable "data_disk_count" {
  description = "Specifies the number of additional data disks to attach to each VM instance. Must be at least 1."
  type        = number
  default     = 1
  validation {
    condition     = var.data_disk_count >= 1
    error_message = "The number of data disks must be greater than or equal to 1."
  }
}

variable "data_disk_type" {
  description = "Specifies the type of the disks attached to each node (e.g., 'pd-standard', 'pd-ssd', or 'pd-balanced'). Default is 'pd-ssd'."
  type        = string
  default     = "pd-ssd"
}

variable "data_disk_size" {
  description = "Specifies the size of the additional data disks for each VM instance, in GB. Default is '350'."
  type        = number
  default     = 350
}

variable "startup_script" {
  description = "Specifies a custom startup script to run when the VMs start. Default is 'null'."
  type        = string
  default     = null
}

variable "harvester_version" {
  description = "Specifies the Harvester version. Default is 'v1.5.1'."
  type        = string
  default     = "v1.5.1"
  validation {
    condition     = can(regex("^v.*$", var.harvester_version))
    error_message = "The Harvester version must start with 'v' (e.g., v1.4.1, v1.4.2-rc2, v1.5.0-dev-20250217)."
  }
}

variable "harvester_node_count" {
  description = "Specifies the number of Harvester nodes to create (1, 3, or 5). Default is '1'."
  type        = number
  default     = 1
  validation {
    condition     = contains([1, 3, 5], var.harvester_node_count)
    error_message = "The number of Harvester nodes must be 1, 3, or 5."
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

variable "harvester_airgapped" {
  description = "Specifies whether the Harvester cluster is deployed in an air-gapped environment without internet access. When set to 'true', internet connectivity is disabled on all nodes. Default is 'false'."
  type        = bool
  default     = false
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
