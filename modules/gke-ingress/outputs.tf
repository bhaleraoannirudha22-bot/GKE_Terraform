
output "ingress_ip" {
  description = "The IP address of the Ingress load balancer"
  value       = google_compute_global_address.hello_world_ip.address
}
