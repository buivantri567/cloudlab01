output "cluster_name" {
  description = "Tên cluster"
  value       = google_container_cluster.main.name
}

output "cluster_endpoint" {
  description = "Địa chỉ Kubernetes API"
  value       = google_container_cluster.main.endpoint
}

output "node_service_account" {
  description = "Service account của node"
  value       = google_service_account.nodes.email
}

output "get_credentials" {
  description = "Lệnh lấy kubeconfig (cần cài gke-gcloud-auth-plugin)"
  value       = "gcloud container clusters get-credentials ${google_container_cluster.main.name} --zone ${var.zone} --project ${var.project_id}"
}
