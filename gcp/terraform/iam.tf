# Service account riêng cho từng VM, chỉ cấp quyền tối thiểu (nguyên tắc least privilege).
# Dùng chung một tài khoản cho nhiều VM sẽ khiến quyền của VM này lan sang VM khác.
resource "google_service_account" "app" {
  account_id   = "app-vm-sa"
  display_name = "Service account cho app-vm"
}

resource "google_service_account" "db" {
  account_id   = "db-vm-sa"
  display_name = "Service account cho db-vm"
}

locals {
  # Quyền cơ bản để VM ghi log và metric lên Cloud Logging / Cloud Monitoring
  vm_sa_roles = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
  ]

  vm_sa_bindings = {
    for pair in setproduct(["app", "db"], local.vm_sa_roles) :
    "${pair[0]}-${pair[1]}" => {
      sa   = pair[0]
      role = pair[1]
    }
  }

  vm_sa_emails = {
    app = google_service_account.app.email
    db  = google_service_account.db.email
  }
}

resource "google_project_iam_member" "vm_sa" {
  for_each = local.vm_sa_bindings

  project = var.project_id
  role    = each.value.role
  member  = "serviceAccount:${local.vm_sa_emails[each.value.sa]}"
}
