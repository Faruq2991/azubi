output "gke_cluster_name" {
  description = "The name of the GKE cluster."
  value       = google_container_cluster.primary.name
}

output "gke_cluster_endpoint" {
  description = "The endpoint for the GKE cluster's control plane."
  value       = google_container_cluster.primary.endpoint
  sensitive   = true
}

output "get_credentials_command" {
  description = "Command to configure kubectl for the new GKE cluster."
  value       = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --zone ${var.zone}"
}

# output "frontend_external_ip" {
#   description = "The external IP address of the frontend load balancer. It may take a few minutes to become available."
#   value       = kubernetes_service.azubi_frontend_service.status[0].load_balancer[0].ingress[0].ip
# }
