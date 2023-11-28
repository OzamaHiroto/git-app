module "test_dataset" {
  source = "../../../../shared_module/dataset"

  project_id       = local.GOOGLE_CLOUD_PLATFORM.warehouse.project_id
  dataset_id       = "test_dataset"
  authorized_views = local.authorized_views
}