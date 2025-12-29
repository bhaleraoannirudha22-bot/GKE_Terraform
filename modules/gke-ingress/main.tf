provider "kubernetes" {
  host                   = "https://iam.${var.cluster_endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
}

data "google_client_config" "default" {}

resource "google_compute_global_address" "hello_world_ip" {
  project = var.project_id
  name    = "hello-world-ip"
}

resource "kubernetes_manifest" "managed_certificate" {
  manifest = {
    "apiVersion" = "networking.gke.io/v1"
    "kind"       = "ManagedCertificate"
    "metadata" = {
      "name" = "hello-world-cert"
    }
    "spec" = {
      "domains" = [
        "hello-world.your-domain.com" # Replace with your domain
      ]
    }
  }
}

resource "kubernetes_manifest" "deployment" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind"       = "Deployment"
    "metadata" = {
      "name" = "hello-world"
    }
    "spec" = {
      "replicas" = 2
      "selector" = {
        "matchLabels" = {
          "app" = "hello-world"
        }
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "app" = "hello-world"
          }
        }
        "spec" = {
          "containers" = [
            {
              "name"  = "hello-world"
              "image" = "gcr.io/google-samples/hello-app:1.0"
              "ports" = [
                {
                  "containerPort" = 8080
                }
              ]
            }
          ]
        }
      }
    }
  }
}

resource "kubernetes_manifest" "service" {
  manifest = {
    "apiVersion" = "v1"
    "kind"       = "Service"
    "metadata" = {
      "name" = "hello-world-service"
    }
    "spec" = {
      "type" = "NodePort"
      "selector" = {
        "app" = "hello-world"
      }
      "ports" = [
        {
          "port"       = 80
          "targetPort" = 8080
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "ingress" {
  manifest = {
    "apiVersion" = "networking.k8s.io/v1"
    "kind"       = "Ingress"
    "metadata" = {
      "name" = "hello-world-ingress"
      "annotations" = {
        "networking.gke.io/managed-certificates" = kubernetes_manifest.managed_certificate.manifest.metadata.name
        "kubernetes.io/ingress.global-static-ip-name" = google_compute_global_address.hello_world_ip.name
      }
    }
    "spec" = {
      "defaultBackend" = {
        "service" = {
          "name" = kubernetes_manifest.service.manifest.metadata.name
          "port" = {
            "number" = 80
          }
        }
      }
    }
  }
}