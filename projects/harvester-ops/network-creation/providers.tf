terraform {
  required_providers {
    harvester = {
      source  = "harvester/harvester"
      version = "0.6.7"
    }
    ssh = {
      source  = "loafoe/ssh"
      version = "2.7.0"
    }
  }
}
