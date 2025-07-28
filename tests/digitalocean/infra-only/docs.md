## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_digitalocean"></a> [digitalocean](#requirement\_digitalocean) | 2.59.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_local"></a> [local](#provider\_local) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_harvester_node"></a> [harvester\_node](#module\_harvester\_node) | ../../../modules/digitalocean/droplet | n/a |

## Resources

| Name | Type |
|------|------|
| [local_file.startup_script_file](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_do_token"></a> [do\_token](#input\_do\_token) | DigitalOcean API token used to deploy the infrastructure. Default is 'harv-cloud-infra-test'. | `string` | `"harv-cloud-infra-test"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Specifies the prefix added to the names of all resources. Default is 'harv-cloud-infra-test'. | `string` | `"harv-cloud-infra-test"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_first_instance_public_ip"></a> [first\_instance\_public\_ip](#output\_first\_instance\_public\_ip) | n/a |
