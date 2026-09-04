terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.46.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = local.region
}
