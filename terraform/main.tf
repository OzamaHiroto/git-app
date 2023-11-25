variable "branch" {
  type = string
}

locals {
  GOOGLE_CLOUD_PLATFORM = {
    warehouse = {
      project = lookup({
        master  = "production"
        develop = "develop"
      }, var.branch)
      project_id = lookup({
        master  = "131485906652"
        develop = "184536460022"
      }, var.branch)
    }
  }
}

provider "google" {
  region = "us-central1"
  zone   = "us-central1-c"
}

provider "google" {
  alias   = "warehouse"
  project = local.GOOGLE_CLOUD_PLATFORM.warehouse.project_id
  region  = "us-central1"
  zone    = "us-central1-c"
}