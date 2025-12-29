variable "project_id" {
  description = "The ID of the project in which to create the VPC"
  type        = string
}

variable "network_name" {
  description = "The name of the VPC network"
  type        = string
  default     = "gke-vpc"
}

variable "subnet_name" {
  description = "The name of the subnet"
  type        = string
  default     = "gke-subnet"
}

variable "subnet_cidr" {
  description = "The CIDR block for the subnet"
  type        = string
  default     = "10.0.0.0/24"
}

variable "region" {
  description = "The region in which to create the VPC"
  type        = string
}

variable "enable_cloud_nat" {
  description = "Whether to create a Cloud NAT gateway"
  type        = bool
  default     = false
}