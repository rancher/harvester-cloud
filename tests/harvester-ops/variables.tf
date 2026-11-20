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

variable "private_ssh_key_file_path" {
  description = "Specifies the full path where the private SSH key file is located."
  type        = string
}

variable "private_ssh_key_file_name" {
  description = "Specifies the name of the private SSH key file used for authentication."
  type        = string
}

variable "create_image" {
  description = "Specifies whether a Harvester VM image should be created. Default is 'true'."
  type        = bool
  default     = true
}

variable "image_name" {
  description = "Specifies the name of the Harvester image to be created. Default is 'opensuse-leap-16-1'."
  type        = string
  default     = "opensuse-leap-16-1"
}

variable "image_namespace" {
  description = "Specifies the namespace in which the Harvester image will be created. Default is 'default'."
  type        = string
  default     = "default"
}

variable "image_source_type" {
  description = "Specifies the source type for the Harvester image. Default is 'download'."
  type        = string
  default     = "download"
}

variable "image_url" {
  description = "Specifies the URL used to download the Harvester image. Default is 'https://download.opensuse.org/distribution/leap/16.1/appliances/Leap-16.1-Minimal-VM.x86_64-Cloud.qcow2'."
  type        = string
  default     = "https://download.opensuse.org/distribution/leap/16.1/appliances/Leap-16.1-Minimal-VM.x86_64-Cloud.qcow2"
}

variable "cluster_network_count" {
  description = "Specifies the number of networks to be created on Harvester Nested VM's. Default is '1'."
  type        = number
  default     = 1
}

variable "cluster_network_name" {
  description = "Specifies the name of the Harvester Cluster Network. Default is 'cluster-vlan'."
  type        = string
  default     = "cluster-vlan"
}

variable "cluster_network_vlanconfig_name" {
  description = "Specifies the name of the VLAN configuration for the Harvester Cluster Network. Default is 'cluster-vlan-all-nodes'."
  type        = string
  default     = "cluster-vlan-all-nodes"
}

variable "cluster_network_vlan_nics" {
  description = "Specifies the list of NICs used for the Harvester Cluster Network VLAN. Default is '[\"virbr2\"]'."
  type        = list(any)
  default     = ["virbr2"]
}

variable "cluster_network_vlan_bond_mode" {
  description = "Specifies the bond mode for the Harvester Cluster Network VLAN. Default is 'active-backup'."
  type        = string
  default     = "active-backup"
}

variable "network_name" {
  description = "Specifies the name of the Harvester VM network. Default is 'vlan2'."
  type        = string
  default     = "vlan2"
}

variable "network_namespace" {
  description = "Specifies the namespace where the Harvester VM network is created. Default is 'default'."
  type        = string
  default     = "default"
}

variable "network_vlan_id" {
  description = "Specifies the VLAN ID for the Harvester VM network. Default is '1'."
  type        = number
  default     = 1
}

variable "network_route_mode" {
  description = "Specifies the routing mode for the Harvester VM network. Default is 'auto'."
  type        = string
  default     = "auto"
}

variable "network_route_dhcp_server_ip" {
  description = "Specifies the DHCP server IP address for the network route. Default is an empty string ('')."
  type        = string
  default     = ""
}

variable "harvester_airgapped" {
  description = "Specifies whether the Harvester cluster is deployed in an air-gapped environment without internet access. When set to 'true', internet connectivity is disabled on all nodes. Default is 'false'."
  type        = bool
  default     = false
}

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
