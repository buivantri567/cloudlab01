variable "project_id" {
  description = "ID của GCP project"
  type        = string
  default     = "user-cjpobzxpcgar"
}

variable "region" {
  description = "Region mặc định"
  type        = string
  default     = "asia-southeast1"
}

variable "app_subnet_cidr" {
  description = "Dải IP của subnet app"
  type        = string
  default     = "10.10.1.0/24"
}

variable "db_subnet_cidr" {
  description = "Dải IP của subnet db"
  type        = string
  default     = "10.10.2.0/24"
}

variable "ssh_source_ranges" {
  description = "Dải IP được phép SSH. Mặc định là dải của Identity-Aware Proxy (IAP)"
  type        = list(string)
  default     = ["35.235.240.0/20"]
}

variable "db_port" {
  description = "Cổng database (5432 = PostgreSQL, 3306 = MySQL)"
  type        = number
  default     = 5432
}

variable "zone" {
  description = "Zone đặt VM"
  type        = string
  default     = "asia-southeast1-b"
}

variable "machine_type" {
  description = "Loại máy của VM"
  type        = string
  default     = "e2-small"
}

variable "boot_disk_gb" {
  description = "Dung lượng boot disk (GB)"
  type        = number
  default     = 10
}

variable "boot_image" {
  description = "Image cho cả app-vm và db-vm: image của Packer đã cài sẵn Ops Agent (không cần Cloud NAT). Build bằng gcp/packer"
  type        = string
  default     = "projects/user-cjpobzxpcgar/global/images/family/ubuntu-ops-agent"
}

variable "private_domain" {
  description = "Tên miền nội bộ (vùng DNS private), không kèm dấu chấm cuối"
  type        = string
  default     = "lab.internal"
}

variable "public_domain" {
  description = "Tên miền public, ví dụ example.com. Để trống thì không tạo vùng public"
  type        = string
  default     = ""
}

variable "snapshot_start_time_utc" {
  description = "Giờ bắt đầu chụp snapshot hằng ngày (UTC, định dạng HH:MM). 20:00 UTC = 03:00 sáng giờ Việt Nam"
  type        = string
  default     = "20:00"
}

variable "snapshot_retention_days" {
  description = "Số ngày giữ snapshot trước khi tự xoá"
  type        = number
  default     = 7
}

variable "vm_start_schedule" {
  description = "Lịch bật VM, cú pháp cron. Mặc định 08:00 từ thứ Hai đến thứ Sáu"
  type        = string
  default     = "0 8 * * 1-5"
}

variable "vm_stop_schedule" {
  description = "Lịch tắt VM, cú pháp cron. Mặc định 18:00 từ thứ Hai đến thứ Sáu"
  type        = string
  default     = "0 18 * * 1-5"
}

variable "vm_schedule_time_zone" {
  description = "Múi giờ của lịch bật/tắt (tên IANA)"
  type        = string
  default     = "Asia/Ho_Chi_Minh"
}
