## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |
| <a name="provider_local"></a> [local](#provider\_local) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_disk.data_disk](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_disk) | resource |
| [google_compute_firewall.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_image.upload_certified_image](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_image) | resource |
| [google_compute_instance.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_compute_network.vpc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) | resource |
| [google_compute_subnetwork.subnet](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [google_storage_bucket.images_bucket](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket_object.certified_image](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_object) | resource |
| [local_file.private_key_pem](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.public_key_pem](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [null_resource.download_image](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_shuffle.random_zone](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/shuffle) | resource |
| [random_string.random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [tls_private_key.ssh_private_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [google_compute_image.os_image](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_image) | data source |
| [google_compute_zones.available](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_certified_os_image"></a> [certified\_os\_image](#input\_certified\_os\_image) | Specifies whether to use the Harvester OS image released in the GitHub repository. If set to false, the default OpenSUSE image provided by the cloud provider will be used. Default is 'false'. | `bool` | `false` | no |
| <a name="input_certified_os_image_tag"></a> [certified\_os\_image\_tag](#input\_certified\_os\_image\_tag) | Specifies which GitHub release to use for the Harvester OpenSUSE image. Default is 'build-1'. | `string` | `"build-1"` | no |
| <a name="input_create_firewall"></a> [create\_firewall](#input\_create\_firewall) | Specifies whether a Google Firewall should be created for all resources. Default is 'true'. | `bool` | `true` | no |
| <a name="input_create_ssh_key_pair"></a> [create\_ssh\_key\_pair](#input\_create\_ssh\_key\_pair) | Specifies whether a new SSH key pair needs to be created for the instances. Default is 'true'. | `bool` | `true` | no |
| <a name="input_create_vpc"></a> [create\_vpc](#input\_create\_vpc) | Specifies whether a VPC and Subnet should be created for the instances. Default is 'true'. | `bool` | `true` | no |
| <a name="input_data_disk_count"></a> [data\_disk\_count](#input\_data\_disk\_count) | Specifies the number of additional data disks to attach to each VM instance. Default is 1. | `number` | `1` | no |
| <a name="input_data_disk_size"></a> [data\_disk\_size](#input\_data\_disk\_size) | Specifies the size of the additional data disks for each VM instance, in GB. Default is '350'. | `number` | `350` | no |
| <a name="input_data_disk_type"></a> [data\_disk\_type](#input\_data\_disk\_type) | Specifies the type of the disks attached to each node (e.g., 'pd-standard', 'pd-ssd', or 'pd-balanced'). Default is 'pd-ssd'. | `string` | `"pd-ssd"` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Specifies the name of a Google Compute Engine machine type. Default is 'n2-standard-16'. | `string` | `"n2-standard-16"` | no |
| <a name="input_ip_cidr_range"></a> [ip\_cidr\_range](#input\_ip\_cidr\_range) | Specifies the range of private IPs available for the Google Subnet. Default is '10.10.0.0/24'. | `string` | `"10.10.0.0/24"` | no |
| <a name="input_os_disk_size"></a> [os\_disk\_size](#input\_os\_disk\_size) | Specifies the size of the disk attached to each node, in GB. Default is '50'. | `number` | `50` | no |
| <a name="input_os_disk_type"></a> [os\_disk\_type](#input\_os\_disk\_type) | Specifies the type of the disk attached to each node (e.g., 'pd-standard', 'pd-ssd', or 'pd-balanced'). Default is 'pd-ssd'. | `string` | `"pd-ssd"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Specifies the prefix added to the names of all resources. Default is 'gcp-tf'. | `string` | `"gcp-tf"` | no |
| <a name="input_region"></a> [region](#input\_region) | Specifies the Google region used for all resources. Default is 'us-west2'. | `string` | `"us-west2"` | no |
| <a name="input_spot_instance"></a> [spot\_instance](#input\_spot\_instance) | Specifies whether the instances should be Spot (preemptible) VMs. Default is 'true'. | `bool` | `true` | no |
| <a name="input_ssh_private_key_path"></a> [ssh\_private\_key\_path](#input\_ssh\_private\_key\_path) | Specifies the full path where the pre-generated SSH PRIVATE key is located (not generated by Terraform). Default is 'null'. | `string` | `null` | no |
| <a name="input_ssh_public_key_path"></a> [ssh\_public\_key\_path](#input\_ssh\_public\_key\_path) | Specifies the full path where the pre-generated SSH PUBLIC key is located (not generated by Terraform). Default is 'null'. | `string` | `null` | no |
| <a name="input_startup_script"></a> [startup\_script](#input\_startup\_script) | Specifies a custom startup script to run when the VMs start. Default is 'null'. | `string` | `null` | no |
| <a name="input_subnet"></a> [subnet](#input\_subnet) | Specifies the Google Subnet used for all resources. Default is 'null'. | `string` | `null` | no |
| <a name="input_vpc"></a> [vpc](#input\_vpc) | Specifies the Google VPC used for all resources. Default is 'null'. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_firewall"></a> [firewall](#output\_firewall) | n/a |
| <a name="output_instance_ips"></a> [instance\_ips](#output\_instance\_ips) | n/a |
| <a name="output_instances_private_ip"></a> [instances\_private\_ip](#output\_instances\_private\_ip) | Google Compute Engine Intances Private IPs |
| <a name="output_instances_public_ip"></a> [instances\_public\_ip](#output\_instances\_public\_ip) | Google Compute Engine Intances Public IPs |
| <a name="output_public_ssh_key"></a> [public\_ssh\_key](#output\_public\_ssh\_key) | n/a |
| <a name="output_subnet"></a> [subnet](#output\_subnet) | n/a |
| <a name="output_vpc"></a> [vpc](#output\_vpc) | n/a |
