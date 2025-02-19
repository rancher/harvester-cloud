## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |
| <a name="provider_local"></a> [local](#provider\_local) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_linux_virtual_machine.vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) | resource |
| [azurerm_managed_disk.data_disk](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_disk) | resource |
| [azurerm_network_interface.nic](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_interface_security_group_association.nsg_assoc](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association) | resource |
| [azurerm_network_security_group.nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_rule.allow_inbound](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.allow_outbound](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_public_ip.vm_ip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_subnet.subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_virtual_machine_data_disk_attachment.data_disk_attachment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_data_disk_attachment) | resource |
| [azurerm_virtual_network.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [local_file.private_key_pem](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.public_key_pem](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [tls_private_key.ssh_private_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_data_disk"></a> [create\_data\_disk](#input\_create\_data\_disk) | Specifies whether to create an additional data disk for each VM instance. Default is 'true'. | `bool` | `true` | no |
| <a name="input_create_ssh_key_pair"></a> [create\_ssh\_key\_pair](#input\_create\_ssh\_key\_pair) | Specifies whether a new SSH key pair needs to be created for the instances. Default is 'true'. | `bool` | `true` | no |
| <a name="input_create_vnet"></a> [create\_vnet](#input\_create\_vnet) | Specifies whether a VPC and Subnet should be created for the instances. Default is 'true'. | `bool` | `true` | no |
| <a name="input_data_disk_count"></a> [data\_disk\_count](#input\_data\_disk\_count) | Specifies the number of data disks to create (1 or 3). Default is '1'. | `number` | `1` | no |
| <a name="input_data_disk_size"></a> [data\_disk\_size](#input\_data\_disk\_size) | Specifies the size of the additional data disk for each VM instance, in GB. Default is '350'. | `number` | `350` | no |
| <a name="input_data_disk_type"></a> [data\_disk\_type](#input\_data\_disk\_type) | Specifies the type of the disk attached to each node (e.g., 'Premium\_LRS', 'Standard\_LRS'). Default is 'Premium\_LRS'. | `string` | `"Premium_LRS"` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Specifies the name of a Azure Virtual Machine size. Default is 'Standard\_D16as\_v5'. | `string` | `"Standard_D16as_v5"` | no |
| <a name="input_ip_cidr_range"></a> [ip\_cidr\_range](#input\_ip\_cidr\_range) | Specifies the range of private IPs available for the Google Subnet. Default is '10.10.0.0/24'. | `string` | `"10.10.0.0/24"` | no |
| <a name="input_os_disk_size"></a> [os\_disk\_size](#input\_os\_disk\_size) | Specifies the size of the disk attached to each node, in GB. Default is '50'. | `number` | `50` | no |
| <a name="input_os_disk_type"></a> [os\_disk\_type](#input\_os\_disk\_type) | Specifies the type of the disk attached to each node (e.g., 'Premium\_LRS', 'Standard\_LRS'). Default is 'Premium\_LRS'. | `string` | `"Premium_LRS"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Specifies the prefix added to the names of all resources. Default is 'azure-tf'. | `string` | `"azure-tf"` | no |
| <a name="input_region"></a> [region](#input\_region) | Specifies the Azure region used for all resources. Default is 'eastus'. | `string` | `"spaincentral"` | no |
| <a name="input_spot_instance"></a> [spot\_instance](#input\_spot\_instance) | Specifies whether the instances should be Spot (preemptible) VMs. Default is 'true'. | `bool` | `false` | no |
| <a name="input_ssh_private_key_path"></a> [ssh\_private\_key\_path](#input\_ssh\_private\_key\_path) | Specifies the full path where the pre-generated SSH PRIVATE key is located (not generated by Terraform). Default is 'null'. | `string` | `null` | no |
| <a name="input_ssh_public_key_path"></a> [ssh\_public\_key\_path](#input\_ssh\_public\_key\_path) | Specifies the full path where the pre-generated SSH PUBLIC key is located (not generated by Terraform). Default is 'null'. | `string` | `null` | no |
| <a name="input_startup_script"></a> [startup\_script](#input\_startup\_script) | Specifies a custom startup script to run when the VMs start. Default is 'null'. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instances_private_ip"></a> [instances\_private\_ip](#output\_instances\_private\_ip) | Azure Virtual Machines Private IPs |
| <a name="output_instances_public_ip"></a> [instances\_public\_ip](#output\_instances\_public\_ip) | Azure Virtual Machines Public IPs |
| <a name="output_network_security_group"></a> [network\_security\_group](#output\_network\_security\_group) | n/a |
| <a name="output_public_ssh_key"></a> [public\_ssh\_key](#output\_public\_ssh\_key) | n/a |
| <a name="output_vnet"></a> [vnet](#output\_vnet) | n/a |
