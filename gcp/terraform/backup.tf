# Backup bằng snapshot định kỳ cho boot disk của app-vm và db-vm.
# Snapshot theo kiểu incremental: chỉ lưu phần thay đổi so với lần trước nên chi phí thấp.
resource "google_compute_resource_policy" "daily_snapshot" {
  name        = "daily-snapshot"
  region      = var.region
  description = "Snapshot mỗi ngày, giữ ${var.snapshot_retention_days} ngày"

  snapshot_schedule_policy {
    schedule {
      daily_schedule {
        days_in_cycle = 1
        start_time    = var.snapshot_start_time_utc
      }
    }

    retention_policy {
      max_retention_days = var.snapshot_retention_days

      # Xoá VM hoặc disk thì vẫn giữ các snapshot đã tạo theo lịch, để còn khôi phục
      on_source_disk_delete = "KEEP_AUTO_SNAPSHOTS"
    }

    snapshot_properties {
      storage_locations = [var.region]
      labels = {
        managed_by = "terraform"
      }
    }
  }
}

# Boot disk của instance được tạo tự động và trùng tên với instance
resource "google_compute_disk_resource_policy_attachment" "app" {
  name = google_compute_resource_policy.daily_snapshot.name
  disk = google_compute_instance.app.name
  zone = var.zone

  # VM bị tạo lại thì disk mới cũng phải được gắn lại policy
  lifecycle {
    replace_triggered_by = [google_compute_instance.app.id]
  }
}

resource "google_compute_disk_resource_policy_attachment" "db" {
  name = google_compute_resource_policy.daily_snapshot.name
  disk = google_compute_instance.db.name
  zone = var.zone

  # VM bị tạo lại thì disk mới cũng phải được gắn lại policy
  lifecycle {
    replace_triggered_by = [google_compute_instance.db.id]
  }
}
