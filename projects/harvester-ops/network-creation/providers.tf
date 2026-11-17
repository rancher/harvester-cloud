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
  }
}
