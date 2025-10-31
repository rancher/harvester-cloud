terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.50.0"
    }
    ssh = {
      source  = "loafoe/ssh"
      version = "2.7.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.38.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.1.0"
    }
    rancher2 = {
      source  = "rancher/rancher2"
      version = "8.2.1"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

provider "rancher2" {
  api_url    = var.rancher_api_url
  access_key = var.rancher_access_key
  secret_key = var.rancher_secret_key
  insecure   = var.rancher_insecure
}
