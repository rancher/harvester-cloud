## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_harvester"></a> [harvester](#requirement\_harvester) | 0.6.7 |
| <a name="requirement_ssh"></a> [ssh](#requirement\_ssh) | 2.7.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_harvester_vm"></a> [harvester\_vm](#module\_harvester\_vm) | ../../../modules/harvester/virtual-machine | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cpu"></a> [cpu](#input\_cpu) | Specifies the number of CPU cores allocated to each VM. Default is '2'. | `number` | `2` | no |
| <a name="input_data_disk_size"></a> [data\_disk\_size](#input\_data\_disk\_size) | Specifies the size of the data disk attached to each VM, in GB. Default is '25'. | `number` | `25` | no |
| <a name="input_harvester_url"></a> [harvester\_url](#input\_harvester\_url) | Specifies the URL of the Harvester cluster API. | `string` | n/a | yes |
| <a name="input_image_name"></a> [image\_name](#input\_image\_name) | Specifies the OS image name. Default is 'opensuse-leap-15-6'. | `string` | `"opensuse-leap-15-6"` | no |
| <a name="input_image_namespace"></a> [image\_namespace](#input\_image\_namespace) | Specifies the namespace in which the Harvester image was created. Default is 'default'. | `string` | `"default"` | no |
| <a name="input_kubeconfig_file_name"></a> [kubeconfig\_file\_name](#input\_kubeconfig\_file\_name) | Specifies the name of the Kubeconfig file used to access the Harvester cluster. | `string` | n/a | yes |
| <a name="input_kubeconfig_file_path"></a> [kubeconfig\_file\_path](#input\_kubeconfig\_file\_path) | Specifies the full path where the Kubeconfig file is located. | `string` | n/a | yes |
| <a name="input_memory"></a> [memory](#input\_memory) | Specifies the amount of memory allocated to each VM, in GB. Default is '4'. | `number` | `4` | no |
| <a name="input_network_name"></a> [network\_name](#input\_network\_name) | Specifies the name of the Harvester VM network that was created. Default is an empty string (''). | `string` | `""` | no |
| <a name="input_os_disk_size"></a> [os\_disk\_size](#input\_os\_disk\_size) | Specifies the size of the root disk attached to each VM, in GB. Default is '25'. | `number` | `25` | no |
| <a name="input_ssh_password"></a> [ssh\_password](#input\_ssh\_password) | Specifies the password used for SSH login. Default is 'SecretPassword.123'. | `string` | `"SecretPassword.123"` | no |
| <a name="input_ssh_username"></a> [ssh\_username](#input\_ssh\_username) | Specifies the username used for SSH login (Harvester VMs). Default is 'opensuse'. | `string` | `"opensuse"` | no |
| <a name="input_startup_script"></a> [startup\_script](#input\_startup\_script) | Specifies a custom startup script to be executed when the VM is initialized. Default is 'null'. | `string` | `null` | no |
| <a name="input_vm_count"></a> [vm\_count](#input\_vm\_count) | Specifies the number of VM instances to be created. Default is '1'. | `number` | `1` | no |
| <a name="input_vm_namespace"></a> [vm\_namespace](#input\_vm\_namespace) | Specifies the namespace where the VMs will be created. Default is 'default'. | `string` | `"default"` | no |
| <a name="input_vm_prefix"></a> [vm\_prefix](#input\_vm\_prefix) | Specifies the prefix added to the names of all VMs. Default is 'demo-tf'. | `string` | `"demo-tf"` | no |

## Outputs

No outputs.
