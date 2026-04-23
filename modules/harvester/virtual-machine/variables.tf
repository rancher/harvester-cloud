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
}

variable "memory" {
  description = "Specifies the amount of memory allocated to each VM, in GB. Default is '4'."
  type        = number
  default     = 4
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
}

variable "startup_script" {
  description = "Specifies a custom startup script to be executed when the VM is initialized. Default is 'null'."
  type        = string
  default     = null
}

variable "extra_packages" {
  description = "Specifies additional packages to install via cloud-init during VM startup. Default is '[]'."
  type        = list(string)
  default     = []
}

variable "extra_runcmd" {
  description = "Specifies additional runcmd entries to execute via cloud-init during VM startup. Default is '[]'."
  type        = list(string)
  default     = []
}

variable "extra_write_files" {
  description = "Specifies additional files to write via cloud-init during VM startup. Default is '[]'."
  type = list(object({
    path        = string
    permissions = string
    encoding    = string
    content     = string
  }))
  default = []
}
