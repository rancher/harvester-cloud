variable "vm_prefix" {
  description = "Specifies the prefix added to the names of all VMs. Default is 's3-server'."
  type        = string
  default     = "s3-server"
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
  description = "Specifies the number of CPU cores allocated to each VM. Default is '4'."
  type        = number
  default     = 4
}

variable "memory" {
  description = "Specifies the amount of memory allocated to each VM, in GB. Default is '6'."
  type        = number
  default     = 6
}

variable "network_name" {
  description = "Specifies the name of the Harvester VM network that was created. Default is an empty string ('')."
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
  description = "Specifies the size of the data disk attached to each VM, in GB. Default is '100'."
  type        = number
  default     = 100
}

## -- S3 Server (Garage) configuration

variable "s3_bucket_name" {
  description = "Specifies the name of the S3 bucket to create. Default is 'bucket1'."
  type        = string
  default     = "bucket1"
}

variable "s3_bucket_region" {
  description = "Specifies the S3 bucket region name. Default is 'region1'."
  type        = string
  default     = "region1"
}

variable "s3_garage_version" {
  description = "Specifies the URL to the Garage binary version to install."
  type        = string
  default     = "https://garagehq.deuxfleurs.fr/_releases/v1.1.0/x86_64-unknown-linux-musl/garage"
}

## -- Harvester connection

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
