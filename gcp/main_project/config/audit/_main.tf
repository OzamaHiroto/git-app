terraform {
  required_version = "1.1.7"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.13.0"
    }
  }
  backend "gcs" {
    bucket = "project_tfstate"
    prefix = "project_01"
  }
}

provider "google" {
  project = local.dev.project_id
  region  = "asia-northeast1"
}