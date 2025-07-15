## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_harvester"></a> [harvester](#requirement\_harvester) | 0.6.7 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_harvester_image"></a> [harvester\_image](#module\_harvester\_image) | ../../../modules/harvester/image | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_image"></a> [create\_image](#input\_create\_image) | Specifies whether a Harvester VM image should be created. Default is 'true'. | `bool` | `true` | no |
| <a name="input_harvester_url"></a> [harvester\_url](#input\_harvester\_url) | Specifies the URL of the Harvester cluster API. | `string` | n/a | yes |
| <a name="input_image_name"></a> [image\_name](#input\_image\_name) | Specifies the name of the Harvester image to be created. Default is 'opensuse-leap-15-6'. | `string` | `"opensuse-leap-15-6"` | no |
| <a name="input_image_namespace"></a> [image\_namespace](#input\_image\_namespace) | Specifies the namespace in which the Harvester image will be created. Default is 'default'. | `string` | `"default"` | no |
| <a name="input_image_source_type"></a> [image\_source\_type](#input\_image\_source\_type) | Specifies the source type for the Harvester image. Default is 'download'. | `string` | `"download"` | no |
| <a name="input_image_url"></a> [image\_url](#input\_image\_url) | Specifies the URL used to download the Harvester image. Default is 'https://download.opensuse.org/distribution/leap/15.6/appliances/openSUSE-Leap-15.6-Minimal-VM.x86_64-Cloud.qcow2'. | `string` | `"https://download.opensuse.org/distribution/leap/15.6/appliances/openSUSE-Leap-15.6-Minimal-VM.x86_64-Cloud.qcow2"` | no |
| <a name="input_kubeconfig_file_name"></a> [kubeconfig\_file\_name](#input\_kubeconfig\_file\_name) | Specifies the name of the Kubeconfig file used to access the Harvester cluster. | `string` | n/a | yes |
| <a name="input_kubeconfig_file_path"></a> [kubeconfig\_file\_path](#input\_kubeconfig\_file\_path) | Specifies the full path where the Kubeconfig file is located. | `string` | n/a | yes |

## Outputs

No outputs.
