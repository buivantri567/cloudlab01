# VM app: nằm trong subnet app, có IP public để nhận HTTP/HTTPS (tag "app" khớp rule main-allow-web)
resource "google_compute_instance" "app" {
  name         = "app-vm"
  zone         = var.zone
  machine_type = var.machine_type
  tags         = ["app"]

  # Gắn lịch bật/tắt (schedule.tf)
  resource_policies = [google_compute_resource_policy.vm_schedule.self_link]

  boot_disk {
    initialize_params {
      image = var.boot_image
      size  = var.boot_disk_gb
      type  = "pd-balanced"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.app.id

    # Khối rỗng = cấp IP public tạm thời
    access_config {}
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

  # Scope cloud-platform là khuyến nghị của Google: quyền thực tế do IAM role của SA quyết định
  service_account {
    email  = google_service_account.app.email
    scopes = ["cloud-platform"]
  }

  # Đảm bảo SA đã có quyền ghi log trước khi VM khởi động
  depends_on = [google_project_iam_member.vm_sa]
}

# VM db: nằm trong subnet db, không có IP public.
# Chỉ nhận kết nối từ subnet app vào cổng DB (tag "db" khớp rule main-allow-app-to-db).
resource "google_compute_instance" "db" {
  name         = "db-vm"
  zone         = var.zone
  machine_type = var.machine_type
  tags         = ["db"]

  # Gắn lịch bật/tắt (schedule.tf)
  resource_policies = [google_compute_resource_policy.vm_schedule.self_link]

  boot_disk {
    initialize_params {
      image = var.boot_image
      size  = var.boot_disk_gb
      type  = "pd-balanced"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.db.id
  }

  # db-vm sẽ chứa dữ liệu. Không để việc image trong family đổi (build mới) làm Terraform
  # xoá và tạo lại VM. Muốn đổi image chủ động: terraform apply -replace=google_compute_instance.db
  lifecycle {
    ignore_changes = [boot_disk[0].initialize_params[0].image]
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

  service_account {
    email  = google_service_account.db.email
    scopes = ["cloud-platform"]
  }

  depends_on = [google_project_iam_member.vm_sa]
}
