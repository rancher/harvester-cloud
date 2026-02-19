## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_google"></a> [google](#requirement\_google) | 7.17.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | 3.1.1 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 3.0.1 |
| <a name="requirement_rancher2"></a> [rancher2](#requirement\_rancher2) | 13.1.4 |
| <a name="requirement_ssh"></a> [ssh](#requirement\_ssh) | 2.7.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_local"></a> [local](#provider\_local) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |
| <a name="provider_rancher2"></a> [rancher2](#provider\_rancher2) | 13.1.4 |
| <a name="provider_ssh"></a> [ssh](#provider\_ssh) | 2.7.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_harvester_node"></a> [harvester\_node](#module\_harvester\_node) | ../../modules/google-cloud/compute-engine | n/a |

## Resources

| Name | Type |
|------|------|
| [local_file.create_cloud_config_yaml](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.default_ipxe_script_config](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.harvester_startup_script](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.join_cloud_config_yaml](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.kube_config_yaml](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.sles_startup_script_config](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [null_resource.copy_files_to_first_node](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.harvester_iso_download_checking](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.harvester_node_startup](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [rancher2_cluster.rancher_cluster](https://registry.terraform.io/providers/rancher/rancher2/13.1.4/docs/resources/cluster) | resource |
| [ssh_resource.retrieve_kubeconfig](https://registry.terraform.io/providers/loafoe/ssh/2.7.0/docs/resources/resource) | resource |
| [local_file.sles_startup_script](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |
| [local_file.ssh_private_key](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_certified_os_image"></a> [certified\_os\_image](#input\_certified\_os\_image) | Specifies whether to use the Harvester OS image released in the GitHub repository. If set to false, the default OpenSUSE image provided by the cloud provider will be used. Default is 'false'. | `bool` | `false` | no |
| <a name="input_certified_os_image_tag"></a> [certified\_os\_image\_tag](#input\_certified\_os\_image\_tag) | Specifies which GitHub release to use for the Harvester OpenSUSE image. Default is 'build-1'. | `string` | `"build-1"` | no |
| <a name="input_create_firewall"></a> [create\_firewall](#input\_create\_firewall) | Specifies whether a Google Firewall should be created for all resources. Default is 'true'. | `bool` | `true` | no |
| <a name="input_create_ssh_key_pair"></a> [create\_ssh\_key\_pair](#input\_create\_ssh\_key\_pair) | Specifies whether a new SSH key pair needs to be created for the instances. Default is 'true'. | `bool` | `true` | no |
| <a name="input_create_vpc"></a> [create\_vpc](#input\_create\_vpc) | Specifies whether a VPC and Subnet should be created for the instances. Default is 'true'. | `bool` | `true` | no |
| <a name="input_data_disk_count"></a> [data\_disk\_count](#input\_data\_disk\_count) | Specifies the number of additional data disks to attach to each VM instance. Must be at least 1. | `number` | `1` | no |
| <a name="input_data_disk_size"></a> [data\_disk\_size](#input\_data\_disk\_size) | Specifies the size of the additional data disks for each VM instance, in GB. Default is '350'. | `number` | `350` | no |
| <a name="input_data_disk_type"></a> [data\_disk\_type](#input\_data\_disk\_type) | Specifies the type of the disks attached to each node (e.g., 'pd-standard', 'pd-ssd', or 'pd-balanced'). Default is 'pd-ssd'. | `string` | `"pd-ssd"` | no |
| <a name="input_harvester_airgapped"></a> [harvester\_airgapped](#input\_harvester\_airgapped) | Specifies whether the Harvester cluster is deployed in an air-gapped environment without internet access. When set to 'true', internet connectivity is disabled on all nodes. Default is 'false'. | `bool` | `false` | no |
| <a name="input_harvester_cluster_size"></a> [harvester\_cluster\_size](#input\_harvester\_cluster\_size) | Specifies the size of the Harvester cluster. Allowed values are 'small' (8 CPUs, 32 GB RAM) and 'medium' (16 CPUs, 64 GB RAM). Default is 'small'. | `string` | `"small"` | no |
| <a name="input_harvester_first_node_token"></a> [harvester\_first\_node\_token](#input\_harvester\_first\_node\_token) | Specifies the token used to join additional nodes to the Harvester cluster (HA setup). Default is 'SecretToken.123'. | `string` | `"SecretToken.123"` | no |
| <a name="input_harvester_node_count"></a> [harvester\_node\_count](#input\_harvester\_node\_count) | Specifies the number of Harvester nodes to create (1, 3, or 5). Default is '1'. | `number` | `1` | no |
| <a name="input_harvester_password"></a> [harvester\_password](#input\_harvester\_password) | Specifies the password used to access the Harvester nodes. Default is 'SecretPassword.123'. | `string` | `"SecretPassword.123"` | no |
| <a name="input_harvester_version"></a> [harvester\_version](#input\_harvester\_version) | Specifies the Harvester version. Default is 'v1.6.1'. | `string` | `"v1.6.1"` | no |
| <a name="input_ip_cidr_range"></a> [ip\_cidr\_range](#input\_ip\_cidr\_range) | Specifies the range of private IPs available for the Google Subnet. Default is '10.10.0.0/24'. | `string` | `"10.10.0.0/24"` | no |
| <a name="input_os_disk_size"></a> [os\_disk\_size](#input\_os\_disk\_size) | Specifies the size of the disk attached to each node, in GB. Default is '50'. | `number` | `50` | no |
| <a name="input_os_disk_type"></a> [os\_disk\_type](#input\_os\_disk\_type) | Specifies the type of the disk attached to each node (e.g., 'pd-standard', 'pd-ssd', or 'pd-balanced'). Default is 'pd-ssd'. | `string` | `"pd-ssd"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Specifies the prefix added to the names of all resources. Default is 'gcp-tf'. | `string` | `"gcp-tf"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Specifies the Google Project ID that will contain all created resources. Default is 'gcp-tf'. | `string` | `"gcp-tf"` | no |
| <a name="input_rancher_access_key"></a> [rancher\_access\_key](#input\_rancher\_access\_key) | Specifies the Rancher access key for authentication. Default is empty. | `string` | `""` | no |
| <a name="input_rancher_api_url"></a> [rancher\_api\_url](#input\_rancher\_api\_url) | Specifies the Rancher API endpoint used to manage the Harvester cluster. Default is empty. | `string` | `""` | no |
| <a name="input_rancher_insecure"></a> [rancher\_insecure](#input\_rancher\_insecure) | Specifies whether to allow insecure connections to the Rancher API. Default is 'false'. | `bool` | `false` | no |
| <a name="input_rancher_secret_key"></a> [rancher\_secret\_key](#input\_rancher\_secret\_key) | Specifies the Rancher secret key for authentication. Default is empty. | `string` | `""` | no |
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
| <a name="output_first_instance_private_ip"></a> [first\_instance\_private\_ip](#output\_first\_instance\_private\_ip) | n/a |
| <a name="output_first_instance_public_ip"></a> [first\_instance\_public\_ip](#output\_first\_instance\_public\_ip) | n/a |
| <a name="output_harvester_url"></a> [harvester\_url](#output\_harvester\_url) | n/a |
| <a name="output_longhorn_url"></a> [longhorn\_url](#output\_longhorn\_url) | n/a |
