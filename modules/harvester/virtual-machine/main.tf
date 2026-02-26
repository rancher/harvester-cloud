locals {
  base_packages = ["qemu-guest-agent"]
  all_packages  = concat(local.base_packages, var.extra_packages)

  base_runcmd = [
    "systemctl enable --now qemu-guest-agent",
    "sed -i 's/#PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config",
    "sed -i 's@Include /etc/ssh/sshd_config.d/\\*.conf@#Include /etc/ssh/sshd_config.d/*.conf@g' /etc/ssh/sshd_config",
    "systemctl restart sshd",
  ]
  startup_runcmd = var.startup_script != null ? [var.startup_script] : []
  all_runcmd     = concat(local.base_runcmd, local.startup_runcmd, var.extra_runcmd)

  cloud_config = merge(
    {
      username       = var.ssh_username
      password       = var.ssh_password
      chpasswd       = { expire = false }
      ssh_pwauth     = true
      package_update = true
      packages       = local.all_packages
      runcmd         = local.all_runcmd
    },
    length(var.extra_write_files) > 0 ? {
      write_files = [
        for f in var.extra_write_files : {
          path        = f.path
          permissions = f.permissions
          encoding    = f.encoding
          content     = f.content
        }
      ]
    } : {}
  )
}

resource "harvester_cloudinit_secret" "cloud-config" {
  name         = "${var.vm_prefix}-cloud-config"
  namespace    = var.vm_namespace
  user_data    = format("%s\n%s", "#cloud-config", yamlencode(local.cloud_config))
  network_data = ""
}

resource "random_string" "random" {
  length  = 4
  lower   = true
  numeric = false
  special = false
  upper   = false
}

resource "harvester_virtualmachine" "default" {
  count                = var.vm_count
  name                 = "${var.vm_prefix}-vm-${count.index + 1}-${random_string.random.result}"
  namespace            = var.vm_namespace
  restart_after_update = true
  tags = {
    ssh-user = var.ssh_username
  }
  cpu             = var.cpu
  memory          = "${var.memory}Gi"
  efi             = true
  secure_boot     = true
  run_strategy    = "RerunOnFailure"
  hostname        = "${var.vm_prefix}-vm-${count.index + 1}-${random_string.random.result}"
  reserved_memory = "256Mi"
  machine_type    = "q35"
  network_interface {
    name           = "nic-1"
    network_name   = var.network_name
    type           = "bridge"
    wait_for_lease = true
  }
  disk {
    name       = "rootdisk"
    type       = "disk"
    size       = "${var.os_disk_size}Gi"
    bus        = "virtio"
    boot_order = 1

    image       = "${var.image_namespace}/${var.image_name}"
    auto_delete = true
  }
  disk {
    name        = "emptydisk"
    type        = "disk"
    size        = "${var.data_disk_size}Gi"
    bus         = "virtio"
    auto_delete = true
  }
  cloudinit {
    user_data_secret_name = harvester_cloudinit_secret.cloud-config.name
  }
  timeouts {
    create = "15m"
  }
}
