## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 4.36.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_harvester_node"></a> [harvester\_node](#module\_harvester\_node) | ../../../modules/azure/virtual-machine | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Specifies the prefix added to the names of all resources. Default is 'harvcloudinfratest'. | `string` | `"harvcloudinfratest"` | no |
| <a name="input_public_ip_source_addresses"></a> [public\_ip\_source\_addresses](#input\_public\_ip\_source\_addresses) | Specifies a list of CIDR blocks allowed to access port 22 (SSH). Default is an empty list (no restrictions defined at variable level). | `list(string)` | `[]` | no |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Specifies the Azure Subscription ID that will contain all created resources. Default is 'harvcloudinfratest'. | `string` | `"harvcloudinfratest"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_first_instance_private_ip"></a> [first\_instance\_private\_ip](#output\_first\_instance\_private\_ip) | n/a |
| <a name="output_first_instance_public_ip"></a> [first\_instance\_public\_ip](#output\_first\_instance\_public\_ip) | n/a |
