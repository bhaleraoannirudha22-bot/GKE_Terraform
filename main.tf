
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

module "vpc" {
  source           = "./modules/vpc"
  project_id       = var.project_id
  region           = var.region
  network_name     = "gke-vpc"
  subnet_name      = "gke-subnet"
  subnet_cidr      = "10.0.0.0/24"
  enable_cloud_nat = var.enable_cloud_nat
}

module "iam" {
  source             = "./modules/iam"
  project_id         = var.project_id
  service_account_name = "gke-node-sa"
}

module "gke" {
  source                 = "./modules/gke"
  project_id             = var.project_id
  cluster_name           = "gke-cluster"
  region                 = var.region
  network_self_link      = module.vpc.network_self_link
  subnet_self_link       = module.vpc.subnet_self_link
  pods_range_name        = module.vpc.pods_range_name
  services_range_name    = module.vpc.services_range_name
  gke_node_sa_email      = module.iam.service_account_email
  enable_private_cluster = var.enable_private_cluster
}

module "gke_ingress" {
  source                 = "./modules/gke-ingress"
  project_id             = var.project_id
  cluster_name           = module.gke.cluster_name
  region                 = var.region
  cluster_endpoint       = module.gke.cluster_endpoint
  cluster_ca_certificate = module.gke.cluster_ca_certificate
}
