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
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Specifies the prefix added to the names of all resources. Default is 'harv-cloud-infra-test'. | `string` | `"harv-cloud-infra-test"` | no |
| <a name="input_certified_os_image"></a> [certified_os_image](#input\_certified_os_image) | Specifies whether to use the Harvester OS image released in the GitHub repository. If set to false, the default OpenSUSE image provided by the cloud provider will be used. Default is 'true'. | `bool` | `true` | yes |
| <a name="input_certified_os_image_tag"></a> [certified_os_image_tag](#input\_certified_os_image_tag) |  Specifies which GitHub release to use for the Harvester OpenSUSE image. Default is 'build-5'. | `string` | `"build-5"` | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_first_instance_private_ip"></a> [first\_instance\_private\_ip](#output\_first\_instance\_private\_ip) | n/a |
| <a name="output_first_instance_public_ip"></a> [first\_instance\_public\_ip](#output\_first\_instance\_public\_ip) | n/a |
