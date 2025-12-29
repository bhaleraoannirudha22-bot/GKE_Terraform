
variable "cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
}

variable "region" {
  description = "The region of the GKE cluster"
  type        = string
}

variable "project_id" {
  description = "The ID of the project"
  type        = string
}

variable "cluster_endpoint" {
  description = "The endpoint of the GKE cluster"
  type        = string
}

variable "cluster_ca_certificate" {
  description = "The CA certificate of the GKE cluster"
  type        = string
  sensitive   = true
}
