locals {
  private_ssh_key_path = var.ssh_private_key_path == null ? "${path.cwd}/${var.prefix}-ssh_private_key.pem" : var.ssh_private_key_path
  public_ssh_key_path  = var.ssh_public_key_path == null ? "${path.cwd}/${var.prefix}-ssh_public_key.pem" : var.ssh_public_key_path
  instance_count       = 1
  instance_os_type     = "opensuse"
  ssh_username         = local.instance_os_type
  certified_image_url  = var.certified_os_image ? "https://github.com/rancher/harvester-cloud/releases/download/${var.certified_os_image_tag}/opensuse-leap-15-6-harv-cloud-image.x86_64.qcow2.bz2" : null
}

resource "tls_private_key" "ssh_private_key" {
  count     = var.create_ssh_key_pair ? 1 : 0
  algorithm = "ED25519"
}

resource "local_file" "private_key_pem" {
  count           = var.create_ssh_key_pair ? 1 : 0
  filename        = local.private_ssh_key_path
  content         = tls_private_key.ssh_private_key[0].private_key_openssh
  file_permission = "0600"
}

resource "local_file" "public_key_pem" {
  count           = var.create_ssh_key_pair ? 1 : 0
  filename        = local.public_ssh_key_path
  content         = tls_private_key.ssh_private_key[0].public_key_openssh
  file_permission = "0600"
}

resource "digitalocean_ssh_key" "do_pub_created_ssh" {
  name       = "${var.prefix}-pub"
  public_key = var.create_ssh_key_pair ? tls_private_key.ssh_private_key[0].public_key_openssh : file(local.public_ssh_key_path)
}

resource "digitalocean_volume" "data_disk" {
  count  = var.data_disk_count
  name   = "${var.prefix}-data-disk-${count.index + 1}"
  size   = var.data_disk_size
  region = var.region
}

resource "digitalocean_volume_attachment" "data_disk_attachment" {
  count      = var.data_disk_count
  volume_id  = digitalocean_volume.data_disk[count.index].id
  droplet_id = digitalocean_droplet.nodes[0].id
}

resource "digitalocean_custom_image" "upload_certified_image" {
  count   = var.certified_os_image ? 1 : 0
  name    = "${var.prefix}-opensuse-certified-img"
  url     = local.certified_image_url
  regions = ["nyc3", "${var.region}"]
}

resource "digitalocean_droplet" "nodes" {
  count      = local.instance_count
  depends_on = [digitalocean_custom_image.upload_certified_image]
  name       = "node-${var.prefix}-${count.index + 1}"
  tags       = ["user:${var.prefix}"]
  region     = var.region
  size       = var.instance_type
  image      = var.certified_os_image ? digitalocean_custom_image.upload_certified_image[0].id : data.digitalocean_image.opensuse[0].id
  ssh_keys   = [digitalocean_ssh_key.do_pub_created_ssh.id]
}

resource "digitalocean_firewall" "example_firewall" {
  name        = "${var.prefix}-harvester-firewall"
  droplet_ids = [digitalocean_droplet.nodes[0].id]
  dynamic "inbound_rule" {
    for_each = toset([
      "22", "68", "443", "2112-32767"
    ])
    content {
      protocol         = "tcp"
      port_range       = inbound_rule.value
      source_addresses = ["0.0.0.0/0", "::/0"]
    }
  }
  dynamic "inbound_rule" {
    for_each = toset([
      "22", "68", "443", "2112-32767"
    ])
    content {
      protocol         = "udp"
      port_range       = inbound_rule.value
      source_addresses = ["0.0.0.0/0", "::/0"]
    }
  }
  outbound_rule {
    protocol              = "tcp"
    port_range            = "all"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol              = "udp"
    port_range            = "all"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

resource "null_resource" "kernel_configuration" {
  count = var.certified_os_image ? 0 : 1
  connection {
    type        = "ssh"
    host        = digitalocean_droplet.nodes[0].ipv4_address
    user        = local.ssh_username
    private_key = var.create_ssh_key_pair ? tls_private_key.ssh_private_key[0].private_key_openssh : file(local.private_ssh_key_path)
  }
  provisioner "remote-exec" {
    inline = [
      "echo 'Installing required Kernel modules...'",
      "sudo zypper --non-interactive remove kernel-default-base > /dev/null 2>&1",
      "sudo zypper --non-interactive install kernel-default cron > /dev/null 2>&1",
      "sudo reboot > /dev/null 2>&1"
    ]
  }
}

resource "null_resource" "startup_configuration" {
  count      = var.startup_script == null ? 0 : 1
  depends_on = [null_resource.kernel_configuration]
  connection {
    type        = "ssh"
    host        = digitalocean_droplet.nodes[0].ipv4_address
    user        = local.ssh_username
    timeout     = "5m"
    private_key = var.create_ssh_key_pair ? tls_private_key.ssh_private_key[0].private_key_openssh : file(local.private_ssh_key_path)
  }
  provisioner "file" {
    source      = var.startup_script
    destination = "/tmp/startup_script.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "echo 'Executing the OpenSUSE startup_script...'",
      "sudo chmod +x /tmp/startup_script.sh > /dev/null 2>&1",
      "sudo bash /tmp/startup_script.sh > /dev/null 2>&1"
    ]
  }
}
