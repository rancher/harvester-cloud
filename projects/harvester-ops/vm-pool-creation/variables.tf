variable "vm_prefix" {
  description = "Specifies the prefix added to the names of all VMs. Default is 'demo-tf'."
  type        = string
  default     = "demo-tf"
}

variable "vm_count" {
  description = "Specifies the number of VM instances to be created. Default is '1'."
  type        = number
  default     = 1
}

variable "vm_namespace" {
  description = "Specifies the namespace where the VMs will be created. Default is 'default'."
  type        = string
  default     = "default"
}

variable "ssh_username" {
  description = "Specifies the username used for SSH login (Harvester VMs). Default is 'opensuse'."
  type        = string
  default     = "opensuse"
}

variable "ssh_password" {
  description = "Specifies the password used for SSH login. Default is 'SecretPassword.123'."
  type        = string
  default     = "SecretPassword.123"
}

variable "cpu" {
  description = "Specifies the number of CPU cores allocated to each VM. Default is '2'."
  type        = number
  default     = 2
  validation {
    condition     = var.s3_server_install == false || var.cpu >= 4
    error_message = "When s3_server_install is enabled, cpu must be at least 4."
  }
}

variable "memory" {
  description = "Specifies the amount of memory allocated to each VM, in GB. Default is '4'."
  type        = number
  default     = 4
  validation {
    condition     = var.s3_server_install == false || var.memory >= 6
    error_message = "When s3_server_install is enabled, memory must be at least 6 GB."
  }
}

variable "network_name" {
  description = "Specifies the name of the Harvester VM network that was created. Default is an empty string ('')." # management network by default
  type        = string
  default     = ""
}

variable "image_namespace" {
  description = "Specifies the namespace in which the Harvester image was created. Default is 'default'."
  type        = string
  default     = "default"
}

variable "image_name" {
  description = "Specifies the OS image name. Default is 'opensuse-leap-15-6'."
  type        = string
  default     = "opensuse-leap-15-6"
}

variable "os_disk_size" {
  description = "Specifies the size of the root disk attached to each VM, in GB. Default is '25'."
  type        = number
  default     = 25
}

variable "data_disk_size" {
  description = "Specifies the size of the data disk attached to each VM, in GB. Default is '25'."
  type        = number
  default     = 25
  validation {
    condition     = var.s3_server_install == false || var.data_disk_size >= 100
    error_message = "When s3_server_install is enabled, data_disk_size must be at least 100 GB."
  }
}

variable "startup_script" {
  description = "Specifies a custom startup script to be executed when the VM is initialized. Default is 'null'."
  type        = string
  default     = null
}

variable "harvester_url" {
  description = "Specifies the URL of the Harvester cluster API."
  type        = string
}

variable "kubeconfig_file_path" {
  description = "Specifies the full path where the Kubeconfig file is located."
  type        = string
}

variable "kubeconfig_file_name" {
  description = "Specifies the name of the Kubeconfig file used to access the Harvester cluster."
  type        = string
}

variable "s3_server_install" {
  description = "Enables the automated installation of an S3-compatible server (Garage) on the VM during startup. Default is 'false'."
  type        = bool
  default     = false
}

variable "s3_bucket_name" {
  description = "Specifies the name of the S3 bucket to create. Only used when 's3_server_install' is true. Default is 'bucket1'."
  type        = string
  default     = "bucket1"
}

variable "s3_bucket_region" {
  description = "Specifies the S3 bucket region name. Only used when 's3_server_install' is true. Default is 'region1'."
  type        = string
  default     = "region1"
}

variable "s3_garage_version" {
  description = "Specifies the URL to the Garage binary version to install. Only used when 's3_server_install' is true."
  type        = string
  default     = "https://garagehq.deuxfleurs.fr/_releases/v1.1.0/x86_64-unknown-linux-musl/garage"
}

variable "nfs_server_install" {
  description = "Enables the automated installation of an NFS server on the VM during startup. Default is 'false'."
  type        = bool
  default     = false
  validation {
    condition     = !(var.nfs_server_install && var.s3_server_install)
    error_message = "You cannot enable both NFS and S3 server installation at the same time. Choose only one."
  }
}

variable "nfs_export_path" {
  description = "Specifies the directory path to export via NFS. Only used when 'nfs_server_install' is true. Default is '/mnt/nfs-data'."
  type        = string
  default     = "/mnt/nfs-data"
}

variable "nfs_export_options" {
  description = "Specifies the NFS export options for /etc/exports. Only used when 'nfs_server_install' is true. Default is '*(rw,sync,no_subtree_check,no_root_squash)'."
  type        = string
  default     = "*(rw,sync,no_subtree_check,no_root_squash)"
}

variable "nfs_data_disk_size" {
  description = "Specifies the size of the data disk used for NFS exports, in GB. Only used when 'nfs_server_install' is true. Default is '50'."
  type        = number
  default     = 100
}
