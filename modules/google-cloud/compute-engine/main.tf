locals {
  private_ssh_key_path = var.ssh_private_key_path == null ? "${path.cwd}/${var.prefix}-ssh_private_key.pem" : var.ssh_private_key_path
  public_ssh_key_path  = var.ssh_public_key_path == null ? "${path.cwd}/${var.prefix}-ssh_public_key.pem" : var.ssh_public_key_path
  instance_count       = 1
  instance_os_type     = "opensuse"
  os_image_family      = "opensuse-leap"
  os_image_project     = "opensuse-cloud"
  ssh_username         = local.instance_os_type
  certified_image_name = "opensuse-leap-15-6-harv-cloud-image.x86_64.raw.tar.gz"
  certified_image_url  = var.certified_os_image ? "https://github.com/rancher/harvester-cloud/releases/download/${var.certified_os_image_tag}/${local.certified_image_name}" : null
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

data "google_compute_image" "os_image" {
  family  = local.os_image_family
  project = local.os_image_project
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
    ports    = ["2379", "2381", "2380", "10010", "6443", "9345", "10252", "10257", "10251", "10259", "10250", "10256", "10258", "9091", "9099", "2112", "6444", "10246-10249", "8181", "8444", "10245", "9796", "30000-32767", "22", "3260", "5900", "6080"]
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
  count = var.certified_os_image ? 1 : 0
  provisioner "local-exec" {
    command = <<EOT
      curl -fL -o ${path.cwd}/${var.prefix}-image.tar.gz ${local.certified_image_url}
    EOT
  }
}

resource "google_storage_bucket" "images_bucket" {
  count         = var.certified_os_image ? 1 : 0
  name          = "${var.prefix}-certified-img-bucket"
  location      = var.region
  force_destroy = true
}

resource "google_storage_bucket_object" "certified_image" {
  depends_on = [null_resource.download_image]
  count      = var.certified_os_image ? 1 : 0
  name       = "${var.prefix}-image-raw.tar.gz"
  bucket     = google_storage_bucket.images_bucket[0].name
  source     = "${path.cwd}/${var.prefix}-image.tar.gz"
}

resource "google_compute_image" "upload_certified_image" {
  depends_on = [google_storage_bucket_object.certified_image]
  count      = var.certified_os_image ? 1 : 0
  name       = "${var.prefix}-opensuse-certified-img"
  raw_disk {
    source = "https://storage.googleapis.com/${google_storage_bucket.images_bucket[0].name}/${google_storage_bucket_object.certified_image[0].name}"
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
      image = var.certified_os_image ? google_compute_image.upload_certified_image[0].self_link : data.google_compute_image.os_image.self_link
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
