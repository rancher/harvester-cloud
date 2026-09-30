terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.101.1"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}
