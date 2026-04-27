## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 6.37.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_harvester_node"></a> [harvester\_node](#module\_harvester\_node) | ../../../modules/aws/ec2 | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Specifies the prefix added to the names of all resources. Default is 'harvcloudinfratest'. | `string` | `"harvcloudinfratest"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_first_instance_private_ip"></a> [first\_instance\_private\_ip](#output\_first\_instance\_private\_ip) | n/a |
| <a name="output_first_instance_public_ip"></a> [first\_instance\_public\_ip](#output\_first\_instance\_public\_ip) | n/a |
