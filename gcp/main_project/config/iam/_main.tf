# GCPのAPIを有効化する
resource "google_project_service" "iamcredentials" {
  project = local.dev.project_id
  service = "iamcredentials.googleapis.com"
}

