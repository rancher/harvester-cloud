terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.100.1"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}
