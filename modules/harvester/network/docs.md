## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_harvester"></a> [harvester](#requirement\_harvester) | 0.6.7 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_harvester"></a> [harvester](#provider\_harvester) | 0.6.7 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [harvester_clusternetwork.vlan](https://registry.terraform.io/providers/harvester/harvester/0.6.7/docs/resources/clusternetwork) | resource |
| [harvester_network.cluster_vlan](https://registry.terraform.io/providers/harvester/harvester/0.6.7/docs/resources/network) | resource |
| [harvester_vlanconfig.cluster_vlan_allnodes](https://registry.terraform.io/providers/harvester/harvester/0.6.7/docs/resources/vlanconfig) | resource |
| [harvester_clusternetwork.vlan](https://registry.terraform.io/providers/harvester/harvester/0.6.7/docs/data-sources/clusternetwork) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_network_name"></a> [cluster\_network\_name](#input\_cluster\_network\_name) | Specifies the name of the Harvester Cluster Network. Default is 'cluster-vlan'. | `string` | `"cluster-vlan"` | no |
| <a name="input_cluster_network_vlan_bond_mode"></a> [cluster\_network\_vlan\_bond\_mode](#input\_cluster\_network\_vlan\_bond\_mode) | Specifies the bond mode for the Harvester Cluster Network VLAN. Default is 'active-backup'. | `string` | `"active-backup"` | no |
| <a name="input_cluster_network_vlan_nics"></a> [cluster\_network\_vlan\_nics](#input\_cluster\_network\_vlan\_nics) | Specifies the list of NICs used for the Harvester Cluster Network VLAN. Default is '["virbr2"]'. | `list(any)` | <pre>[<br>  "virbr2"<br>]</pre> | no |
| <a name="input_cluster_network_vlanconfig_name"></a> [cluster\_network\_vlanconfig\_name](#input\_cluster\_network\_vlanconfig\_name) | Specifies the name of the VLAN configuration for the Harvester Cluster Network. Default is 'cluster-vlan-all-nodes'. | `string` | `"cluster-vlan-all-nodes"` | no |
| <a name="input_create_cluster_network"></a> [create\_cluster\_network](#input\_create\_cluster\_network) | Specifies whether a Harvester Cluster Network should be created. Default is 'true'. | `bool` | `true` | no |
| <a name="input_network_name"></a> [network\_name](#input\_network\_name) | Specifies the name of the Harvester VM network. Default is 'vlan2'. | `string` | `"vlan2"` | no |
| <a name="input_network_namespace"></a> [network\_namespace](#input\_network\_namespace) | Specifies the namespace where the Harvester VM network is created. Default is 'default'. | `string` | `"default"` | no |
| <a name="input_network_route_dhcp_server_ip"></a> [network\_route\_dhcp\_server\_ip](#input\_network\_route\_dhcp\_server\_ip) | Specifies the DHCP server IP address for the network route. Default is an empty string (''). | `string` | `""` | no |
| <a name="input_network_route_mode"></a> [network\_route\_mode](#input\_network\_route\_mode) | Specifies the routing mode for the Harvester VM network. Default is 'auto'. | `string` | `"auto"` | no |
| <a name="input_network_vlan_id"></a> [network\_vlan\_id](#input\_network\_vlan\_id) | Specifies the VLAN ID for the Harvester VM network. Default is '1'. | `number` | `1` | no |

## Outputs

No outputs.
