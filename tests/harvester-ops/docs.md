## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_harvester"></a> [harvester](#requirement\_harvester) | 1.9.0 |
| <a name="requirement_ssh"></a> [ssh](#requirement\_ssh) | 2.9.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_external"></a> [external](#provider\_external) | n/a |
| <a name="provider_local"></a> [local](#provider\_local) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |
| <a name="provider_ssh"></a> [ssh](#provider\_ssh) | 2.9.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_harvester_image"></a> [harvester\_image](#module\_harvester\_image) | ../../modules/harvester/image | n/a |
| <a name="module_harvester_network"></a> [harvester\_network](#module\_harvester\_network) | ../../modules/harvester/network | n/a |
| <a name="module_harvester_vm"></a> [harvester\_vm](#module\_harvester\_vm) | ../../modules/harvester/virtual-machine | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [local_file.qemu_vlanx_config](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [null_resource.copy_qemu_vlanx_xml_file_to_first_node](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.wait_harvester_services_startup](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [ssh_resource.attach_network_interface](https://registry.terraform.io/providers/loafoe/ssh/2.9.0/docs/resources/resource) | resource |
| [ssh_resource.create_vlanx](https://registry.terraform.io/providers/loafoe/ssh/2.9.0/docs/resources/resource) | resource |
| [ssh_resource.creating_subnet_nftables_rule](https://registry.terraform.io/providers/loafoe/ssh/2.9.0/docs/resources/resource) | resource |
| [ssh_resource.harvester_airgapped](https://registry.terraform.io/providers/loafoe/ssh/2.9.0/docs/resources/resource) | resource |
| [external_external.verify_harvester_ops](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |
| [local_file.load_kubeconfig_file](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_cluster_network_count"></a> [cluster\_network\_count](#input\_cluster\_network\_count) | Specifies the number of networks to be created on Harvester Nested VM's. Default is '1'. | `number` | `1` | no |
| <a name="input_cluster_network_name"></a> [cluster\_network\_name](#input\_cluster\_network\_name) | Specifies the name of the Harvester Cluster Network. Default is 'cluster-vlan'. | `string` | `"cluster-vlan"` | no |
| <a name="input_cluster_network_vlan_bond_mode"></a> [cluster\_network\_vlan\_bond\_mode](#input\_cluster\_network\_vlan\_bond\_mode) | Specifies the bond mode for the Harvester Cluster Network VLAN. Default is 'active-backup'. | `string` | `"active-backup"` | no |
| <a name="input_cluster_network_vlan_nics"></a> [cluster\_network\_vlan\_nics](#input\_cluster\_network\_vlan\_nics) | Specifies the list of NICs used for the Harvester Cluster Network VLAN. Default is '["virbr2"]'. | `list(any)` | <pre>[<br/>  "virbr2"<br/>]</pre> | no |
| <a name="input_cluster_network_vlanconfig_name"></a> [cluster\_network\_vlanconfig\_name](#input\_cluster\_network\_vlanconfig\_name) | Specifies the name of the VLAN configuration for the Harvester Cluster Network. Default is 'cluster-vlan-all-nodes'. | `string` | `"cluster-vlan-all-nodes"` | no |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | Specifies the number of CPU cores allocated to each VM. Default is '2'. | `number` | `2` | no |
| <a name="input_create_image"></a> [create\_image](#input\_create\_image) | Specifies whether a Harvester VM image should be created. Default is 'true'. | `bool` | `true` | no |
| <a name="input_data_disk_size"></a> [data\_disk\_size](#input\_data\_disk\_size) | Specifies the size of the data disk attached to each VM, in GB. Default is '25'. | `number` | `25` | no |
| <a name="input_harvester_airgapped"></a> [harvester\_airgapped](#input\_harvester\_airgapped) | Specifies whether the Harvester cluster is deployed in an air-gapped environment without internet access. When set to 'true', internet connectivity is disabled on all nodes. Default is 'false'. | `bool` | `false` | no |
| <a name="input_harvester_url"></a> [harvester\_url](#input\_harvester\_url) | Specifies the URL of the Harvester cluster API. | `string` | n/a | yes |
| <a name="input_image_name"></a> [image\_name](#input\_image\_name) | Specifies the name of the Harvester image to be created. Default is 'opensuse-leap-16-1'. | `string` | `"opensuse-leap-16-1"` | no |
| <a name="input_image_namespace"></a> [image\_namespace](#input\_image\_namespace) | Specifies the namespace in which the Harvester image will be created. Default is 'default'. | `string` | `"default"` | no |
| <a name="input_image_source_type"></a> [image\_source\_type](#input\_image\_source\_type) | Specifies the source type for the Harvester image. Default is 'download'. | `string` | `"download"` | no |
| <a name="input_image_url"></a> [image\_url](#input\_image\_url) | Specifies the URL used to download the Harvester image. Default is 'https://download.opensuse.org/distribution/leap/16.1/appliances/Leap-16.1-Minimal-VM.x86_64-Cloud.qcow2'. | `string` | `"https://download.opensuse.org/distribution/leap/16.1/appliances/Leap-16.1-Minimal-VM.x86_64-Cloud.qcow2"` | no |
| <a name="input_kubeconfig_file_name"></a> [kubeconfig\_file\_name](#input\_kubeconfig\_file\_name) | Specifies the name of the Kubeconfig file used to access the Harvester cluster. | `string` | n/a | yes |
| <a name="input_kubeconfig_file_path"></a> [kubeconfig\_file\_path](#input\_kubeconfig\_file\_path) | Specifies the full path where the Kubeconfig file is located. | `string` | n/a | yes |
| <a name="input_memory"></a> [memory](#input\_memory) | Specifies the amount of memory allocated to each VM, in GB. Default is '4'. | `number` | `4` | no |
| <a name="input_network_name"></a> [network\_name](#input\_network\_name) | Specifies the name of the Harvester VM network. Default is 'vlan2'. | `string` | `"vlan2"` | no |
| <a name="input_network_namespace"></a> [network\_namespace](#input\_network\_namespace) | Specifies the namespace where the Harvester VM network is created. Default is 'default'. | `string` | `"default"` | no |
| <a name="input_network_route_dhcp_server_ip"></a> [network\_route\_dhcp\_server\_ip](#input\_network\_route\_dhcp\_server\_ip) | Specifies the DHCP server IP address for the network route. Default is an empty string (''). | `string` | `""` | no |
| <a name="input_network_route_mode"></a> [network\_route\_mode](#input\_network\_route\_mode) | Specifies the routing mode for the Harvester VM network. Default is 'auto'. | `string` | `"auto"` | no |
| <a name="input_network_vlan_id"></a> [network\_vlan\_id](#input\_network\_vlan\_id) | Specifies the VLAN ID for the Harvester VM network. Default is '1'. | `number` | `1` | no |
| <a name="input_os_disk_size"></a> [os\_disk\_size](#input\_os\_disk\_size) | Specifies the size of the root disk attached to each VM, in GB. Default is '25'. | `number` | `25` | no |
| <a name="input_private_ssh_key_file_name"></a> [private\_ssh\_key\_file\_name](#input\_private\_ssh\_key\_file\_name) | Specifies the name of the private SSH key file used for authentication. | `string` | n/a | yes |
| <a name="input_private_ssh_key_file_path"></a> [private\_ssh\_key\_file\_path](#input\_private\_ssh\_key\_file\_path) | Specifies the full path where the private SSH key file is located. | `string` | n/a | yes |
| <a name="input_ssh_password"></a> [ssh\_password](#input\_ssh\_password) | Specifies the password used for SSH login. Default is 'SecretPassword.123'. | `string` | `"SecretPassword.123"` | no |
| <a name="input_ssh_username"></a> [ssh\_username](#input\_ssh\_username) | Specifies the username used for SSH login (Harvester VMs). Default is 'opensuse'. | `string` | `"opensuse"` | no |
| <a name="input_startup_script"></a> [startup\_script](#input\_startup\_script) | Specifies a custom startup script to be executed when the VM is initialized. Default is 'null'. | `string` | `null` | no |
| <a name="input_vm_count"></a> [vm\_count](#input\_vm\_count) | Specifies the number of VM instances to be created. Default is '1'. | `number` | `1` | no |
| <a name="input_vm_namespace"></a> [vm\_namespace](#input\_vm\_namespace) | Specifies the namespace where the VMs will be created. Default is 'default'. | `string` | `"default"` | no |
| <a name="input_vm_prefix"></a> [vm\_prefix](#input\_vm\_prefix) | Specifies the prefix added to the names of all VMs. Default is 'demo-tf'. | `string` | `"demo-tf"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_harvester_ops_status"></a> [harvester\_ops\_status](#output\_harvester\_ops\_status) | n/a |
