terraform {
  required_providers {
    harvester = {
      source  = "harvester/harvester"
      version = "1.8.0"
    }
    ssh = {
      source  = "loafoe/ssh"
      version = "2.7.0"
    }
  }
}

provider "harvester" {
  kubeconfig = "${var.kubeconfig_file_path}/${var.kubeconfig_file_name}"
}
