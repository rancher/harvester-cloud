terraform {
  required_providers {
    harvester = {
      source  = "harvester/harvester"
      version = "1.8.1"
    }
  }
}

provider "harvester" {
  kubeconfig = "${var.kubeconfig_file_path}/${var.kubeconfig_file_name}"
}
