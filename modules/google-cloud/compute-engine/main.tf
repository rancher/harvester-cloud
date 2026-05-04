locals {
  private_ssh_key_path = var.ssh_private_key_path == null ? "${path.cwd}/${var.prefix}-ssh_private_key.pem" : var.ssh_private_key_path
  public_ssh_key_path  = var.ssh_public_key_path == null ? "${path.cwd}/${var.prefix}-ssh_public_key.pem" : var.ssh_public_key_path
  instance_count       = 1
  ssh_username         = "opensuse"
  certified_image_name = "opensuse-leap-16-0-harv-cloud-image.x86_64.raw.tar.gz"
  certified_image_url  = "https://github.com/rancher/harvester-cloud/releases/download/latest/${local.certified_image_name}"
  certified_image_sum  = "54884a2bbf9fa320975bf8513d51ce2f1ebe99e0c1d1dc673ded9ed4c34a006726552fc5d37c2cedd96f2123efba559843988c932fef73405fb46aac20e8048d"
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


resource "google_compute_network" "vpc" {
  count                   = var.create_vpc == true ? 1 : 0
  name                    = "${var.prefix}-vpc"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "subnet" {
  depends_on    = [resource.google_compute_firewall.default[0]]
  count         = var.create_vpc == true ? 1 : 0
  name          = "${var.prefix}-subnet"
  region        = var.region
  network       = var.vpc == null ? resource.google_compute_network.vpc[0].name : var.vpc
  ip_cidr_range = var.ip_cidr_range
}

resource "google_compute_firewall" "default" {
  count   = var.create_firewall ? 1 : 0
  name    = "${var.prefix}-firewall"
  network = var.vpc == null ? resource.google_compute_network.vpc[0].name : var.vpc
  allow {
    protocol = "icmp"
  }
  #https://docs.harvesterhci.io/v1.3/install/requirements#port-requirements-for-harvester-nodes
  allow {
    protocol = "tcp"
    ports    = ["2379", "2381", "2380", "10010", "9345", "10252", "10257", "10251", "10259", "10250", "10256", "10258", "9091", "9099", "2112", "6444", "10246-10249", "8181", "8444", "10245", "9796", "30000-32767", "3260", "5900", "6080"]
  }
  allow {
    protocol = "udp"
    ports    = ["8472", "68"]
  }
  allow {
    protocol = "tcp"
    ports    = ["8443", "443"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${var.prefix}"]
}

resource "google_compute_firewall" "ssh" {
  count   = var.create_firewall ? 1 : 0
  name    = "${var.prefix}-firewall-ssh-6443"
  network = var.vpc == null ? resource.google_compute_network.vpc[0].name : var.vpc
  allow {
    protocol = "tcp"
    ports    = ["22", "6443"]
  }
  source_ranges = var.public_ip_source_addresses
  target_tags   = ["${var.prefix}"]
}

data "google_compute_zones" "available" {
  region = var.region
}

resource "random_string" "random" {
  length  = 4
  lower   = true
  numeric = false
  special = false
  upper   = false
}

resource "random_shuffle" "random_zone" {
  input        = ["${var.region}-a", "${var.region}-b", "${var.region}-c"]
  result_count = 1
}

resource "google_compute_disk" "data_disk" {
  count = var.data_disk_count
  name  = "${var.prefix}-data-disk-${count.index + 1}-${random_string.random.result}"
  type  = var.data_disk_type
  size  = var.data_disk_size
  zone  = random_shuffle.random_zone.result[0]
}

resource "null_resource" "download_image" {
  provisioner "local-exec" {
    command = <<-EOT
      set -e
      FILE="${path.cwd}/${local.certified_image_name}"
      EXPECTED_SUM="${local.certified_image_sum}"
      if [ -f "$FILE" ]; then
        echo "File already exists, verifying SHA512..."
        ACTUAL_SUM=$(sha512sum "$FILE" | awk '{print $1}')
        if [ "$ACTUAL_SUM" = "$EXPECTED_SUM" ]; then
          echo "Checksum matches, skipping download"
          exit 0
        else
          echo "Checksum mismatch, re-downloading file"
          rm -f "$FILE"
        fi
      fi
      echo "Downloading certified VHD..."
      curl -L -o "$FILE" "${local.certified_image_url}"
      echo "Verifying SHA512..."
      ACTUAL_SUM=$(sha512sum "$FILE" | awk '{print $1}')
      if [ "$ACTUAL_SUM" != "$EXPECTED_SUM" ]; then
        echo "ERROR: SHA512 checksum mismatch!"
        exit 1
      fi
    EOT
  }
}

resource "google_storage_bucket" "images_bucket" {
  name          = "${var.prefix}-certified-img-bucket"
  location      = var.region
  force_destroy = true
}

resource "google_storage_bucket_object" "certified_image" {
  depends_on = [null_resource.download_image]
  name       = "${var.prefix}-image-raw.tar.gz"
  bucket     = google_storage_bucket.images_bucket.name
  source     = "${path.cwd}/${local.certified_image_name}"
}

resource "google_compute_image" "upload_certified_image" {
  depends_on = [google_storage_bucket_object.certified_image]
  name       = "${var.prefix}-opensuse-certified-img"
  raw_disk {
    source = "https://storage.googleapis.com/${google_storage_bucket.images_bucket.name}/${google_storage_bucket_object.certified_image.name}"
  }
}

resource "google_compute_instance" "default" {
  count        = local.instance_count
  name         = "${var.prefix}-vm-${count.index + 1}-${random_string.random.result}"
  machine_type = var.instance_type
  zone         = random_shuffle.random_zone.result[0]
  tags         = ["${var.prefix}"]
  scheduling {
    preemptible        = var.spot_instance
    provisioning_model = var.spot_instance ? "SPOT" : "STANDARD"
    automatic_restart  = var.spot_instance ? false : true
  }
  boot_disk {
    initialize_params {
      type  = var.os_disk_type
      size  = var.os_disk_size
      image = google_compute_image.upload_certified_image.self_link
    }
  }
  dynamic "scratch_disk" {
    for_each = []
    content {
      interface = "SCSI"
    }
  }
  dynamic "attached_disk" {
    for_each = google_compute_disk.data_disk
    content {
      source = attached_disk.value.self_link
    }
  }
  network_interface {
    network    = var.vpc == null ? resource.google_compute_network.vpc[0].name : var.vpc
    subnetwork = var.subnet == null ? resource.google_compute_subnetwork.subnet[0].name : var.subnet
    access_config {}
  }
  metadata = {
    serial-port-logging-enable = "TRUE"
    serial-port-enable         = "TRUE"
    ssh-keys                   = var.create_ssh_key_pair ? "${local.ssh_username}:${tls_private_key.ssh_private_key[0].public_key_openssh}" : "${local.ssh_username}:${file(local.public_ssh_key_path)}"
    startup-script             = var.startup_script
  }
  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      boot_disk[0].initialize_params[0].image
    ]
  }
  advanced_machine_features {
    enable_nested_virtualization = true
  }
}

resource "null_resource" "cleanup_certified_vhd" {
  depends_on = [google_compute_instance.default]
  provisioner "local-exec" {
    command = "rm ${path.cwd}/${local.certified_image_name}"
  }
}
