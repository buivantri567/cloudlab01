# Lịch tự động bật/tắt VM để tiết kiệm chi phí ngoài giờ làm việc.
# Việc bật/tắt do Compute Engine service agent thực hiện (đã có sẵn quyền compute.instances.start/stop).
resource "google_compute_resource_policy" "vm_schedule" {
  name        = "vm-start-stop"
  region      = var.region
  description = "Bật VM lúc ${var.vm_start_schedule}, tắt lúc ${var.vm_stop_schedule} (${var.vm_schedule_time_zone})"

  instance_schedule_policy {
    vm_start_schedule {
      schedule = var.vm_start_schedule
    }

    vm_stop_schedule {
      schedule = var.vm_stop_schedule
    }

    time_zone = var.vm_schedule_time_zone
  }
}
