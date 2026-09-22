output "cluster_name" {
  description = "Tên cluster"
  value       = google_container_cluster.main.name
}

output "cluster_endpoint" {
  description = "Địa chỉ Kubernetes API"
  value       = google_container_cluster.main.endpoint
}

output "get_credentials" {
  description = "Lệnh lấy kubeconfig (cần cài gke-gcloud-auth-plugin)"
  value       = "gcloud container clusters get-credentials ${google_container_cluster.main.name} --region ${var.region} --project ${var.project_id}"
}
