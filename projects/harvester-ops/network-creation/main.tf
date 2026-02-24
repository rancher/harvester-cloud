locals {
  harvester_public_ip          = replace(replace(var.harvester_url, "https://", ""), "/$", "")
  qemu_vlanx_xml_template_file = "../../../modules/harvester/deployment-script/qemu_vlanx_xml.tpl"
  nic_base                     = "virbr"
  ip_base                      = "192.168."
  vlan_base                    = "vlan"
  vlanx_network_map = zipmap(
    [for i in range(var.cluster_network_count) : i + 1],
    [for i in range(var.cluster_network_count) : {
      nic     = "${local.nic_base}${2 + i}"
      ip_base = "${local.ip_base}${123 + i}"
  }])
  harvester_network_interface_name = ["ens7"] # Name of the NIC that is automatically created in Harvester nested VMs
  kubeconfig_file                  = "${var.kubeconfig_file_path}/${var.kubeconfig_file_name}"
}

resource "local_file" "qemu_vlanx_config" {
  for_each = local.vlanx_network_map
  content = templatefile("${local.qemu_vlanx_xml_template_file}", {
    name    = "${local.vlan_base}${each.key + 1}",
    nic     = each.value.nic,
    ip_base = each.value.ip_base
  })
  file_permission = "0644"
  filename        = "${path.cwd}/vlanx-${each.key}.xml"
}

resource "null_resource" "copy_qemu_vlanx_xml_file_to_first_node" {
  for_each   = local.vlanx_network_map
  depends_on = [local_file.qemu_vlanx_config]
  connection {
    type        = "ssh"
    host        = local.harvester_public_ip
    user        = var.ssh_username
    private_key = file("${var.private_ssh_key_file_path}/${var.private_ssh_key_file_name}")
  }
  provisioner "file" {
    source      = local_file.qemu_vlanx_config[each.key].filename
    destination = "/tmp/${basename(local_file.qemu_vlanx_config[each.key].filename)}"
  }
}

resource "ssh_resource" "create_vlanx" {
  for_each    = local.vlanx_network_map
  depends_on  = [null_resource.copy_qemu_vlanx_xml_file_to_first_node]
  host        = local.harvester_public_ip
  user        = var.ssh_username
  private_key = file("${var.private_ssh_key_file_path}/${var.private_ssh_key_file_name}")
  commands = [<<EOT
sudo virsh net-define /tmp/${basename(local_file.qemu_vlanx_config[each.key].filename)} || true
sudo virsh net-start ${local.vlan_base}${each.key + 1} || true
sudo virsh net-autostart ${local.vlan_base}${each.key + 1} || true
sudo bash -c 'cat << "EOF" >> /etc/nftables.conf
table inet filter {
  chain forward {
    type filter hook forward priority 0;

    ip daddr 192.168.0.0/16 accept
  }
}
EOF'
sudo nft -f /etc/nftables.conf || true
EOT
  ]
}

resource "ssh_resource" "harvester_airgapped" {
  for_each    = var.harvester_airgapped ? local.vlanx_network_map : {}
  depends_on  = [ssh_resource.create_vlanx]
  host        = local.harvester_public_ip
  user        = var.ssh_username
  private_key = file("${var.private_ssh_key_file_path}/${var.private_ssh_key_file_name}")
  commands = [<<EOT
sudo bash -c 'cat << "EOF" >> /etc/nftables.conf
delete rule inet filter forward iifname "${each.value.nic}" ip saddr ${each.value.ip_base}/24 accept
EOF'
sudo nft -f /etc/nftables.conf || true
EOT
  ]
}

resource "ssh_resource" "attach_network_interface" {
  depends_on  = [ssh_resource.create_vlanx, ssh_resource.harvester_airgapped]
  host        = local.harvester_public_ip
  user        = var.ssh_username
  private_key = file("${var.private_ssh_key_file_path}/${var.private_ssh_key_file_name}")
  commands = [
    <<-EOT
      NODE_COUNT=$(sudo virsh list --all | grep -c "running")
      for i in $(seq 1 $NODE_COUNT); do
          for j in $(seq 1 ${var.cluster_network_count}); do
           sudo virsh attach-interface --domain harvester-node-$i --type bridge --source ${local.nic_base}$(($j + 1)) --model virtio --config --live || true
          done
      done
      for i in $(seq 1 $NODE_COUNT); do
        sudo virsh reboot harvester-node-$i
      done
    EOT
  ]
}

resource "null_resource" "wait_harvester_services_startup" {
  depends_on = [ssh_resource.attach_network_interface]
  provisioner "local-exec" {
    command     = <<-EOF
      count=0
      while [ "$${count}" -lt 15 ]; do
        resp=$(curl -k -s -o /dev/null -w "%%{http_code}" $${HARVESTER_URL}/ping)
        echo "Waiting for $${HARVESTER_URL}/ping - response: $${resp}"
        if [ "$${resp}" = "200" ]; then
          ((count++))
        fi
        sleep 2
      done
      EOF
    interpreter = ["/bin/bash", "-c"]
    environment = {
      HARVESTER_URL = var.harvester_url
    }
  }
}

data "local_file" "load_kubeconfig_file" {
  depends_on = [null_resource.wait_harvester_services_startup]
  filename   = local.kubeconfig_file
}

provider "harvester" {
  kubeconfig = data.local_file.load_kubeconfig_file.filename
}

module "harvester_network" {
  depends_on                      = [null_resource.wait_harvester_services_startup]
  source                          = "../../../modules/harvester/network"
  cluster_network_name            = var.cluster_network_name
  cluster_network_vlanconfig_name = var.cluster_network_vlanconfig_name
  cluster_network_vlan_nics       = local.harvester_network_interface_name
  cluster_network_vlan_bond_mode  = var.cluster_network_vlan_bond_mode
  network_name                    = var.network_name
  network_namespace               = var.network_namespace
  network_vlan_id                 = var.network_vlan_id
  network_route_mode              = var.network_route_mode
  network_route_dhcp_server_ip    = var.network_route_dhcp_server_ip
}
