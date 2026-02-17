terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    ssh = {
      source  = "loafoe/ssh"
      version = "2.7.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.0.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.1.1"
    }
    rancher2 = {
      source  = "rancher/rancher2"
      version = "13.1.4"
    }
  }
}


provider "aws" {
  region = var.region
}