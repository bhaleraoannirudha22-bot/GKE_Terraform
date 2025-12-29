
variable "project_id" {
  description = "The ID of the project in which to create the IAM resources"
  type        = string
}

variable "service_account_name" {
  description = "The name of the service account"
  type        = string
  default     = "gke-node-sa"
}
