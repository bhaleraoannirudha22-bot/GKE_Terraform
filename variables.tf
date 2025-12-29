variable "project_id" {
  description = "The ID of the project in which to create the resources"
  type        = string
}

variable "region" {
  description = "The region in which to create the resources"
  type        = string
}

variable "enable_cloud_nat" {
  description = "Whether to create a Cloud NAT gateway"
  type        = bool
  default     = false
}

variable "enable_private_cluster" {
  description = "Whether to create a private GKE cluster"
  type        = bool
  default     = false
}