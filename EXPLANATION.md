
# Explanation of Resources

This document provides a comprehensive explanation of all the resources and concepts used in this Terraform project.

## 1. High-Level Overview

This project provisions a production-ready Google Kubernetes Engine (GKE) cluster on Google Cloud Platform (GCP). The architecture is designed to be secure, scalable, and maintainable, using a modular Terraform structure.

The key components of the architecture are:

*   **A custom Virtual Private Cloud (VPC)** to provide a private and isolated network for the GKE cluster.
*   **A private GKE cluster** to ensure that the cluster nodes and control plane are not exposed to the public internet.
*   **Cloud NAT** to allow the private cluster nodes to access the internet for pulling container images and other external dependencies.
*   **Workload Identity** to provide a secure way for Kubernetes workloads to access GCP services.
*   **GKE Ingress** with an HTTPS Load Balancer to expose applications to the internet securely.
*   **A CI/CD pipeline** using GitHub Actions to automate the deployment of the infrastructure.

## 2. VPC Module

This module is responsible for creating the network infrastructure for the GKE cluster.

*   **`google_compute_network`**: This resource creates a Virtual Private Cloud (VPC) network. A VPC provides a private, isolated network for your GCP resources. We create a custom VPC instead of using the default VPC to have full control over the network configuration.

*   **`google_compute_subnetwork`**: This resource creates a subnetwork within the VPC. Subnetworks are regional resources and are where your GKE cluster nodes will reside. We also define secondary IP ranges for the pods and services, which are required for GKE's VPC-native networking.

*   **`google_compute_firewall`**: These resources create firewall rules to control traffic to and from the GKE cluster. We create rules to allow internal traffic within the VPC and to allow SSH access from the internet (which should be restricted in a production environment).

*   **`google_compute_router`**: This resource creates a Cloud Router. A Cloud Router is required for Cloud NAT.

*   **`google_compute_router_nat`**: This resource creates a Cloud NAT gateway. Cloud NAT allows instances without public IP addresses (like our private GKE nodes) to access the internet.

## 3. IAM Module

This module is responsible for creating the Identity and Access Management (IAM) resources for the GKE cluster.

*   **`google_service_account`**: This resource creates a service account for the GKE nodes. A service account is a special type of Google account that can be used by applications and virtual machines to authenticate with Google Cloud services.

*   **`google_project_iam_member`**: These resources grant the GKE node service account the necessary IAM roles to function correctly. These roles allow the nodes to write logs and metrics, and to pull container images from the Artifact Registry.

## 4. GKE Module

This module is responsible for creating the GKE cluster itself.

*   **`google_container_cluster`**: This is the main resource that creates the GKE cluster. We configure it to be a private cluster, with Workload Identity and logging/monitoring enabled. We also remove the default node pool, as we will create our own managed node pool.

*   **`google_container_node_pool`**: This resource creates a managed node pool for the GKE cluster. A node pool is a group of nodes with the same configuration. We create a separate node pool to have more control over the node configuration and to allow for separate scaling and upgrade strategies.

## 5. GKE Ingress Module

This module is responsible for deploying a sample application to the GKE cluster and exposing it to the internet using GKE Ingress.

*   **`google_compute_global_address`**: This resource creates a static, global IP address. We use this IP address for the Ingress load balancer, so that the application has a stable, well-known IP address.

*   **`kubernetes_manifest`**: These resources are used to deploy Kubernetes objects to the cluster. We use them to deploy:
    *   A **`ManagedCertificate`**: This is a GKE-specific resource that automatically provisions and renews an SSL certificate for the Ingress.
    *   A **`Deployment`**: This defines the desired state for our sample application, including the container image to use and the number of replicas.
    *   A **`Service`**: This provides a stable endpoint for accessing the application within the cluster.
    *   An **`Ingress`**: This is the resource that tells GKE how to route external traffic to the service. It triggers the creation of a Google Cloud HTTPS Load Balancer.

## 6. Other Concepts

*   **Workload Identity**: This is the recommended way for GKE workloads to access GCP services. It allows you to bind a Kubernetes service account to a Google Cloud service account, so that pods can authenticate with GCP services without needing to store service account keys as secrets.

*   **Private GKE Cluster**: In a private cluster, the nodes do not have public IP addresses, which improves security. The control plane is also not exposed to the public internet.

*   **Cloud NAT**: This service allows instances without public IP addresses to connect to the internet. This is essential for private GKE clusters, as the nodes need to be able to pull container images from public registries.

*   **GKE Ingress**: This is a GKE feature that simplifies the process of creating HTTPS load balancers. It uses the `Ingress` Kubernetes resource to automatically provision and configure a Google Cloud Load Balancer.

*   **Helm & ArgoCD**:
    *   **Helm** is a package manager for Kubernetes that simplifies the deployment of applications.
    *   **ArgoCD** is a GitOps continuous delivery tool that allows you to manage your Kubernetes applications by defining their desired state in a Git repository.

*   **Terraform Remote Backend**: This feature of Terraform allows you to store your Terraform state file in a remote, shared location, such as a Google Cloud Storage bucket. This is essential for collaboration and for running Terraform in a CI/CD pipeline.
