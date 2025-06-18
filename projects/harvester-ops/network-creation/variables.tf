variable "ssh_username" {
  description = "Specifies the username used for SSH authentication (Harvester nodes). Default is 'sles'."
  type        = string
  default     = "sles"
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

variable "harvester_airgapped" {
  description = "Specifies whether the Harvester cluster is deployed in an air-gapped environment without internet access. When set to 'true', internet connectivity is disabled on all nodes. Default is 'false'."
  type        = bool
  default     = false
}
