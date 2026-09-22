variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "availability_zone" {
  description = "AZ đặt các subnet"
  type        = string
  default     = "us-east-1a"
}

variable "vpc_cidr" {
  description = "Dải IP của VPC"
  type        = string
  default     = "10.20.0.0/16"
}

variable "app_subnet_cidr" {
  description = "Dải IP của subnet app (public)"
  type        = string
  default     = "10.20.1.0/24"
}

variable "db_subnet_cidr" {
  description = "Dải IP của subnet db (private)"
  type        = string
  default     = "10.20.2.0/24"
}

variable "ssh_source_ranges" {
  description = "Dải IP được phép SSH vào app subnet. AWS không có dải quản lý sẵn như IAP bên GCP nên bắt buộc phải tự khai báo (vd. qua terraform.tfvars, đã gitignore) — không đặt mặc định 0.0.0.0/0 để tránh vô tình mở SSH cho cả Internet."
  type        = list(string)
}

variable "db_port" {
  description = "Cổng database (5432 = PostgreSQL, 3306 = MySQL)"
  type        = number
  default     = 5432
}

variable "instance_type" {
  description = "Loại máy của EC2 instance"
  type        = string
  default     = "t3.micro"
}

variable "root_volume_gb" {
  description = "Dung lượng root volume (GB)"
  type        = number
  default     = 10
}

variable "private_domain" {
  description = "Tên miền nội bộ (private hosted zone), không kèm dấu chấm cuối"
  type        = string
  default     = "lab.internal"
}

variable "public_domain" {
  description = "Tên miền public, ví dụ example.com. Để trống thì không tạo zone public"
  type        = string
  default     = ""
}

variable "snapshot_start_time_utc" {
  description = "Giờ bắt đầu chụp snapshot hằng ngày (UTC, định dạng HH:00). 20:00 UTC = 03:00 sáng giờ Việt Nam"
  type        = string
  default     = "20:00"
}

variable "snapshot_retention_days" {
  description = "Số snapshot giữ lại trước khi tự xoá (mỗi ngày 1 snapshot)"
  type        = number
  default     = 7
}

variable "vm_start_cron" {
  description = "Lịch bật VM, cú pháp cron của EventBridge Scheduler (phút giờ ngày tháng ngày-trong-tuần năm). Mặc định 08:00 từ thứ Hai đến thứ Sáu"
  type        = string
  default     = "cron(0 8 ? * MON-FRI *)"
}

variable "vm_stop_cron" {
  description = "Lịch tắt VM, cú pháp cron của EventBridge Scheduler. Mặc định 18:00 từ thứ Hai đến thứ Sáu"
  type        = string
  default     = "cron(0 18 ? * MON-FRI *)"
}

variable "vm_schedule_time_zone" {
  description = "Múi giờ của lịch bật/tắt (tên IANA)"
  type        = string
  default     = "Asia/Ho_Chi_Minh"
}
