locals {
  iam_to_primitive = {
    "roles/bigquery.dataOwner" : "OWNER"
    "roles/bigquery.dataEditor" : "WRITER"
    "roles/bigquery.dataViewer" : "READER"
  }
  authorized_datasets = { for dataset in var.authorized_datasets : "${dataset["project_id"]}_${dataset["dataset_id"]}" => dataset }
}

resource  "google_bigquery_dataset" "main" {
  dataset_id                  = var.dataset_id
  friendly_name               = var.dataset_name
  description                 = var.description
  location                    = var.location
  delete_contents_on_destroy  = var.delete_contents_on_destroy
  default_table_expiration_ms = var.default_table_expiration_ms
  max_time_travel_hours       = var.max_time_travel_hours
  project                     = var.project_id
  labels                      = var.dataset_labels
  storage_billing_model       = var.storage_billing_model

  dynamic "default_encryption_configuration" {
    for_each = var.encryption_key == null ? [] : [var.encryption_key]
    content {
      kms_key_name = var.encryption_key
    }
  }

  dynamic "access" {
    for_each = concat(var.access, var.special_group_access)
    content {
      role           = lookup(local.iam_to_primitive, access.value.role, access.value.role)
      domain         = lookup(access.value, "domain", "")
      group_by_email = lookup(access.value, "group_by_email", "")
      user_by_email  = lookup(access.value, "user_by_email", "")
      special_group  = lookup(access.value, "special_group", "")
    }
  }

  dynamic "access" {
    for_each = var.authorized_views
    content {
      view {
        project_id = access.value["project_id"]
        dataset_id = access.value["dataset_id"]
        table_id   = access.value["table_id"]
      }
    }
  }
}

resource "google_bigquery_dataset_access" "authorized_dataset" {
  for_each   = local.authorized_datasets
  dataset_id = var.dataset_id
  project    = var.project_id
  dataset {
    dataset {
      project_id = each.value.project_id
      dataset_id = each.value.dataset_id
    }
    target_types = ["VIEWS"]
  }
}