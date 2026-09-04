terraform {
  required_providers {
    harvester = {
      source  = "harvester/harvester"
      version = "1.8.2"
    }
    ssh = {
      source  = "loafoe/ssh"
      version = "2.7.0"
    }
  }
}
