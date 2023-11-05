# service accountの作成
resource "google_service_account" "github_actions" {
  account_id   = "github-cicd-workflows"
  display_name = "GitHub CICD Workflows"
}

# github actions用のservice accountにIAMの権限を付与
resource "google_project_iam_member" "github_actions_roles" {
  project = var.dev.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

# workload identity poolの作成
resource "google_iam_workload_identity_pool" "github_actions" {
  workload_identity_pool_id = "github-cicd-workflows-pool"
}

# workload identity pool providerの作成
resource "google_iam_workload_identity_pool_provider" "github_actions" {
  workload_identity_pool_provider_id = "github-cicd-workflows-provider"
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_actions.workload_identity_pool_id

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
    "attribute.actor"      = "assertion.actor"
  }
}

# workload identityを使用した際に借用するservice accountに権限を付与
resource "google_service_account_iam_member" "github_actions_iam_workload_identity_user" {
  service_account_id = google_service_account.github_actions.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/projects/${local.dev.project_num}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.github_actions.workload_identity_pool_id}/attribute.repository/OzamaHiroto/git-app"
}