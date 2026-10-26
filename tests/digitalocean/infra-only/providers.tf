terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.105.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}
