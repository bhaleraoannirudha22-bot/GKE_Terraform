
output "service_account_email" {
  description = "The email of the GKE node service account"
  value       = google_service_account.gke_node_sa.email
}
