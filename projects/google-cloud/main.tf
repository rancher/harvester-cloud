locals {
  sles_startup_script_template_file      = "../../modules/harvester/deployment-script/sles_startup_script_sh.tpl"
  sles_startup_script_file               = "${path.cwd}/sles_startup_script.sh"
  disk_structure                         = "97"
  data_disk_name                         = "/dev/sd"
  data_disk_mount_point                  = "/mnt/datadisk"
  default_ipxe_script_template_file      = "../../modules/harvester/deployment-script/default_ipxe.tpl"
  default_ipxe_script_file               = "${path.cwd}/default.ipxe"
  ipxe_base_url                          = "http://192.168.122.1"
  create_cloud_config_template_file      = "../../modules/harvester/deployment-script/create_cloud_config_yaml.tpl"
  create_cloud_config_file               = "${path.cwd}/create_cloud_config.yaml"
  join_cloud_config_template_file        = "../../modules/harvester/deployment-script/join_cloud_config_yaml.tpl"
  join_cloud_config_file                 = "${path.cwd}/join_cloud_config.yaml"
  harvester_startup_script_template_file = "../../modules/harvester/deployment-script/harvester_startup_script_sh.tpl"
  harvester_startup_script_file          = "${path.cwd}/harvester_startup_script.sh"
  data_disk_size                         = var.data_disk_size * 0.9
  harvester_cluster_size                 = var.harvester_node_count == 5 ? "small" : var.harvester_cluster_size
  harvester_cpu                          = local.harvester_cluster_size == "small" ? 8 : 16
  harvester_memory                       = local.harvester_cluster_size == "small" ? 32768 : 65536
  ssh_private_key_path                   = var.ssh_private_key_path == null ? "${path.cwd}/${var.prefix}-ssh_private_key.pem" : var.ssh_private_key_path
  ssh_public_key_path                    = var.ssh_public_key_path == null ? "${path.cwd}/${var.prefix}-ssh_public_key.pem" : var.ssh_public_key_path
  create_vpc                             = var.create_vpc == true ? false : var.create_vpc
  vpc                                    = var.vpc == null ? module.harvester_node.vpc[0].name : var.vpc
  subnet                                 = var.subnet == null ? module.harvester_node.subnet[0].name : var.subnet
  create_firewall                        = var.create_firewall == true ? false : var.create_firewall
  ssh_username                           = "opensuse"
  kubeconfig_file                        = "${path.cwd}/${var.prefix}_kube_config.yml"
  instance_type = (
    var.harvester_node_count == 1 ? (local.harvester_cluster_size == "small" ? "n2-standard-16" : "n2-standard-32") :
    var.harvester_node_count == 3 ? (local.harvester_cluster_size == "small" ? "n2-standard-32" : "n2-standard-64") :
    "n2-standard-64"
  )
}

resource "local_file" "sles_startup_script_config" {
  content = templatefile("${local.sles_startup_script_template_file}", {
    version             = var.harvester_version
    count               = var.harvester_node_count * var.data_disk_count
    disk_name           = local.data_disk_name
    mount_point         = local.data_disk_mount_point
    disk_structure      = local.disk_structure
    harvester_airgapped = var.harvester_airgapped
  })
  file_permission = "0644"
  filename        = local.sles_startup_script_file
}

data "local_file" "sles_startup_script" {
  depends_on = [local_file.sles_startup_script_config]
  filename   = local.sles_startup_script_file
}

resource "local_file" "default_ipxe_script_config" {
  content = templatefile("${local.default_ipxe_script_template_file}", {
    version = var.harvester_version
    base    = local.ipxe_base_url
  })
  file_permission = "0644"
  filename        = local.default_ipxe_script_file
}

resource "local_file" "create_cloud_config_yaml" {
  content = templatefile("${local.create_cloud_config_template_file}", {
    version                  = var.harvester_version
    token                    = var.harvester_first_node_token
    hostname                 = var.prefix
    password                 = var.harvester_password
    harvester_airgapped      = var.harvester_airgapped
    cluster_registration_url = var.rancher_api_url != "" ? rancher2_cluster.rancher_cluster[0].cluster_registration_token[0].manifest_url : ""
  })
  file_permission = "0644"
  filename        = local.create_cloud_config_file
}

resource "local_file" "join_cloud_config_yaml" {
  content = templatefile("${local.join_cloud_config_template_file}", {
    version             = var.harvester_version
    token               = var.harvester_first_node_token
    hostname            = var.prefix
    password            = var.harvester_password
    harvester_airgapped = var.harvester_airgapped
  })
  file_permission = "0644"
  filename        = local.join_cloud_config_file
}

resource "local_file" "harvester_startup_script" {
  content = templatefile("${local.harvester_startup_script_template_file}", {
    hostname                    = var.prefix
    public_ip                   = module.harvester_node.instances_public_ip[0]
    count                       = var.harvester_node_count
    disk_structure              = local.disk_structure
    data_disk_count             = var.data_disk_count
    cpu                         = local.harvester_cpu
    memory                      = local.harvester_memory
    password                    = var.harvester_password
    harvester_default_disk_size = local.data_disk_size
    harvester_airgapped         = var.harvester_airgapped
  })
  file_permission = "0644"
  filename        = local.harvester_startup_script_file
}

module "harvester_node" {
  depends_on             = [local_file.sles_startup_script_config]
  source                 = "../../modules/google-cloud/compute-engine"
  prefix                 = var.prefix
  region                 = var.region
  create_ssh_key_pair    = var.create_ssh_key_pair
  ssh_private_key_path   = local.ssh_private_key_path
  ssh_public_key_path    = local.ssh_public_key_path
  ip_cidr_range          = var.ip_cidr_range
  create_vpc             = var.create_vpc
  vpc                    = var.vpc
  subnet                 = var.subnet
  create_firewall        = var.create_firewall
  spot_instance          = var.spot_instance
  os_disk_type           = var.os_disk_type
  os_disk_size           = var.os_disk_size
  instance_type          = local.instance_type
  data_disk_count        = var.harvester_node_count * var.data_disk_count
  data_disk_type         = var.data_disk_type
  data_disk_size         = var.data_disk_size
  startup_script         = data.local_file.sles_startup_script.content
  certified_os_image     = var.certified_os_image
  certified_os_image_tag = var.certified_os_image_tag
}

data "local_file" "ssh_private_key" {
  depends_on = [module.harvester_node]
  filename   = local.ssh_private_key_path
}

resource "null_resource" "harvester_iso_download_checking" {
  depends_on = [data.local_file.ssh_private_key]
  provisioner "remote-exec" {
    inline = [
      "while true; do [ -f '/tmp/harvester_download_done' ] && break || echo 'The download of the Harvester ISO is not yet complete. Checking again in 30 seconds...' && sleep 30; done"
    ]
    connection {
      type        = "ssh"
      host        = module.harvester_node.instances_public_ip[0]
      user        = local.ssh_username
      private_key = data.local_file.ssh_private_key.content
    }
  }
}

resource "null_resource" "copy_files_to_first_node" {
  depends_on = [null_resource.harvester_iso_download_checking]
  for_each = {
    "default.ipxe"                    = local.default_ipxe_script_file
    "create_cloud_config_yaml.tpl"    = local.create_cloud_config_file
    "join_cloud_config_yaml.tpl"      = local.join_cloud_config_file
    "harvester_startup_script_sh.tpl" = local.harvester_startup_script_file
  }
  connection {
    type        = "ssh"
    host        = module.harvester_node.instances_public_ip[0]
    user        = local.ssh_username
    private_key = data.local_file.ssh_private_key.content
  }
  provisioner "file" {
    source      = each.value
    destination = "/tmp/${basename(each.value)}"
  }
}

resource "null_resource" "harvester_node_startup" {
  depends_on = [null_resource.copy_files_to_first_node]
  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/${basename(local.default_ipxe_script_file)} /tmp/${basename(local.create_cloud_config_file)} /tmp/${basename(local.join_cloud_config_file)} /tmp/${basename(local.harvester_startup_script_file)} /srv/www/harvester/",
      "bash /srv/www/harvester/${basename(local.harvester_startup_script_file)}"
    ]
    connection {
      type        = "ssh"
      host        = module.harvester_node.instances_public_ip[0]
      user        = local.ssh_username
      private_key = data.local_file.ssh_private_key.content
    }
  }
}

resource "ssh_resource" "retrieve_kubeconfig" {
  depends_on = [null_resource.harvester_node_startup]
  host       = module.harvester_node.instances_public_ip[0]
  commands = [
    "sudo sed 's/127.0.0.1/${module.harvester_node.instances_public_ip[0]}/g' /tmp/rke2.yaml"
  ]
  user        = local.ssh_username
  private_key = data.local_file.ssh_private_key.content
}

resource "local_file" "kube_config_yaml" {
  filename        = pathexpand(local.kubeconfig_file)
  content         = ssh_resource.retrieve_kubeconfig.result
  file_permission = "0600"
}

resource "rancher2_cluster" "rancher_cluster" {
  name  = var.prefix
  count = var.rancher_api_url != "" ? 1 : 0
}
