terraform {
  required_providers {
    harvester = {
      source  = "harvester/harvester"
      version = "1.9.1"
    }
    ssh = {
      source  = "loafoe/ssh"
      version = "2.9.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "2.3.5"
    }
  }
}

provider "harvester" {
  kubeconfig = data.local_file.load_kubeconfig_file.filename
}
