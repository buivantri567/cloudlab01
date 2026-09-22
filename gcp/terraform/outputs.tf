output "vpc_name" {
  description = "Tên VPC"
  value       = google_compute_network.main.name
}

output "app_subnet" {
  description = "Subnet app (tên và dải IP)"
  value       = "${google_compute_subnetwork.app.name} ${google_compute_subnetwork.app.ip_cidr_range}"
}

output "db_subnet" {
  description = "Subnet db (tên và dải IP)"
  value       = "${google_compute_subnetwork.db.name} ${google_compute_subnetwork.db.ip_cidr_range}"
}

output "app_vm_external_ip" {
  description = "IP public của app-vm"
  value       = google_compute_instance.app.network_interface[0].access_config[0].nat_ip
}

output "app_vm_internal_ip" {
  description = "IP nội bộ của app-vm"
  value       = google_compute_instance.app.network_interface[0].network_ip
}

output "db_vm_internal_ip" {
  description = "IP nội bộ của db-vm (không có IP public)"
  value       = google_compute_instance.db.network_interface[0].network_ip
}

output "app_vm_service_account" {
  description = "Email service account của app-vm"
  value       = google_service_account.app.email
}

output "db_vm_service_account" {
  description = "Email service account của db-vm"
  value       = google_service_account.db.email
}

output "private_dns_names" {
  description = "Tên nội bộ, chỉ phân giải được trong main-vpc"
  value = [
    google_dns_record_set.app_private.name,
    google_dns_record_set.db_private.name,
  ]
}

output "public_zone_name_servers" {
  description = "Name server cần trỏ tên miền về (rỗng nếu chưa đặt public_domain)"
  value       = one(google_dns_managed_zone.public[*].name_servers)
}

output "snapshot_policy" {
  description = "Tên snapshot schedule đang gắn vào disk của các VM"
  value       = google_compute_resource_policy.daily_snapshot.name
}

output "vm_schedule_policy" {
  description = "Tên lịch bật/tắt đang gắn vào các VM"
  value       = google_compute_resource_policy.vm_schedule.name
}
