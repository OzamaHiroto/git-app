# GCPのAPIを有効化する
resource "google_project_service" "iamcredentials" {
  for_each = toset(local.roles)
  project = local.GOOGLE_CLOUD_PLATFORM.warehouse.project_id
  service = each.value
}

# service accountの作成
resource "google_service_account" "github_actions" {
  project      = local.GOOGLE_CLOUD_PLATFORM.warehouse.project_id
  account_id   = "github-cicd-workflows"
  display_name = "GitHub CICD Workflows"
}

# github actions用のservice accountにIAMの権限を付与
resource "google_project_iam_member" "github_actions_roles" {
  project = local.GOOGLE_CLOUD_PLATFORM.warehouse.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

# workload identity poolの作成
resource "google_iam_workload_identity_pool" "github_actions" {
  provider                  = google
  project                   = local.GOOGLE_CLOUD_PLATFORM.warehouse.project_id
  workload_identity_pool_id = "github-cicd-workflows-pool"
  display_name              = "github"
}

# workload identity pool providerの作成
resource "google_iam_workload_identity_pool_provider" "github_actions" {
  provider                           = google
  project                            = local.GOOGLE_CLOUD_PLATFORM.warehouse.project_id
  workload_identity_pool_provider_id = "github-cicd-workflows-provider"
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_actions.workload_identity_pool_id
  display_name                       = "github actions provider"
  description                        = "OIDC identity pool provider for execute github actions"

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
  member             = "principalSet://iam.googleapis.com/projects/${local.GOOGLE_CLOUD_PLATFORM.warehouse.project_id}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.github_actions.workload_identity_pool_id}/attribute.repository/OzamaHiroto/git-app"
  # member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/${REPO_NAME}"
}

# あとで使うID
output "service_account_github_actions_email" {
  description = "Actionsで使用するサービスアカウント"
  value       = google_service_account.github_actions.email
}

output "google_iam_workload_identity_pool_provider_github_name" {
  description = "Workload Identity Pood Provider ID"
  value       = google_iam_workload_identity_pool_provider.github_actions.name
}