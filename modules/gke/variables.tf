variable "project_id" {
  description = "The ID of the project in which to create the GKE cluster"
  type        = string
}

variable "cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
  default     = "gke-cluster"
}

variable "region" {
  description = "The region in which to create the GKE cluster"
  type        = string
}

variable "network_self_link" {
  description = "The self-link of the VPC network"
  type        = string
}

variable "subnet_self_link" {
  description = "The self-link of the subnet"
  type        = string
}

variable "pods_range_name" {
  description = "The name of the secondary range for pods"
  type        = string
}

variable "services_range_name" {
  description = "The name of the secondary range for services"
  type        = string
}

variable "node_pool_name" {
  description = "The name of the node pool"
  type        = string
  default     = "default-node-pool"
}

variable "node_count" {
  description = "The number of nodes in the node pool"
  type        = number
  default     = 1
}

variable "machine_type" {
  description = "The machine type of the nodes"
  type        = string
  default     = "e2-medium"
}

variable "gke_node_sa_email" {
  description = "The email of the GKE node service account"
  type        = string
}

variable "enable_private_cluster" {
  description = "Whether to create a private GKE cluster"
  type        = bool
  default     = false
}

variable "master_ipv4_cidr_block" {
  description = "The master CIDR block for the private GKE cluster"
  type        = string
  default     = "172.16.0.0/28"
}