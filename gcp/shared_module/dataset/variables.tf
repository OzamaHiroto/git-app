variable "dataset_id" {
  description = "Unique ID for dataset being provisioned"
  type        = string
}

variable "dataset_name" {
  description = "Friendly name for dataset being provisioned"
  type        = string
  default     = null
}

variable "description" {
  description = "Dataset description"
  type        = string
  default     = null
}

variable "location" {
  description = "The regional location for the dataset only ASIA are allowed in module"
  type        = string
  default     = "ASIA"
}

variable "delete_contents_on_destroy" {
  description = "(Optional) If set to true, delete all the tables in the dataset when destroying the resource; otherwise, destroying will fail if tables are present"
  type        = bool
  default     = null
}

variable "deletion_protection" {
  description = "Whether or not to allow Terraform to destroy the instance. Unless this field is set to false in Terraform state, a terraform destroy or terraform apply that would delete the instance will fail"
  type        = bool
  default     = false
}

variable "default_table_expiration_ms" {
  description = "TTL of tables using the dataset in MS"
  type        = number
  default     = null
}

variable "max_time_travel_hours" {
  description = "Defines the time travel window in hours"
  type        = number
  default     = null
}

variable "project_id" {
  description = "Project where the dataset and table are created"
  type        = string
}

variable "encryption_key" {
  description = "Default encryption key to apply to the dataset. Defaults to null (Google-managed)"
  type        = string
  default     = null
}

variable "dataset_labels" {
  description = "Key value pairs in a map for dataset labels"
  type        = map(string)
  default     = {}
}

variable "storage_billing_model" {
  type        = string
  default     = "PHYSICAL"
}

variable "access" {
  description = "An array of objects that define dataset access for one or more entities"
  type        = any
  default     = []
}

variable "special_group_access" {
  description = "プロジェクトの権限をデータアクセスに継承する場合に設定"
  type        = any
  default     = [
    {
      role          = "roles/bigquery.dataOwner"
      special_group = "projectOwners"
    },
    {
      role          = "roles/bigquery.dataEditor"
      special_group = "projectWriters"
    },
    {
      role          = "roles/bigquery.dataViewer"
      special_group = "projectReaders"
    }
  ]
}

variable "authorized_views" {
  description  = "An array of objects that define authorized views."
  type         = list(object({
    project_id = string
    dataset_id = string
    table_id   = string
  }))
  default      = []
}

variable "authorized_datasets" {
  description  = "An array of objects that define authorized datasets."
  type         = list(object({
    project_id = string
    dataset_id = string
  }))
  default      = []
}