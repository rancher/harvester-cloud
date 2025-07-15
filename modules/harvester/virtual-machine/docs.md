## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_harvester"></a> [harvester](#requirement\_harvester) | 0.6.7 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_harvester"></a> [harvester](#provider\_harvester) | 0.6.7 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [harvester_cloudinit_secret.cloud-config](https://registry.terraform.io/providers/harvester/harvester/0.6.7/docs/resources/cloudinit_secret) | resource |
| [harvester_virtualmachine.default](https://registry.terraform.io/providers/harvester/harvester/0.6.7/docs/resources/virtualmachine) | resource |
| [random_string.random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cpu"></a> [cpu](#input\_cpu) | Specifies the number of CPU cores allocated to each VM. Default is '2'. | `number` | `2` | no |
| <a name="input_data_disk_size"></a> [data\_disk\_size](#input\_data\_disk\_size) | Specifies the size of the data disk attached to each VM, in GB. Default is '25'. | `number` | `25` | no |
| <a name="input_image_name"></a> [image\_name](#input\_image\_name) | Specifies the OS image name. Default is 'opensuse-leap-15-6'. | `string` | `"opensuse-leap-15-6"` | no |
| <a name="input_image_namespace"></a> [image\_namespace](#input\_image\_namespace) | Specifies the namespace in which the Harvester image was created. Default is 'default'. | `string` | `"default"` | no |
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
