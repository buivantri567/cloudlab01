packer {
  required_plugins {
    googlecompute = {
      source  = "github.com/hashicorp/googlecompute"
      version = ">= 1.1.0"
    }
  }
}

variable "project_id" {
  type    = string
  default = "user-cjpobzxpcgar"
}

variable "zone" {
  type    = string
  default = "asia-southeast1-b"
}

locals {
  # Tên image chỉ cho phép chữ thường, số và dấu gạch ngang
  timestamp = formatdate("YYYYMMDD-hhmmss", timestamp())
}

source "googlecompute" "ubuntu" {
  project_id          = var.project_id
  zone                = var.zone
  source_image_family = "ubuntu-2404-lts-amd64"
  machine_type        = "e2-small"
  ssh_username        = "packer"

  image_name        = "ubuntu-ops-agent-${local.timestamp}"
  image_family      = "ubuntu-ops-agent"
  image_description = "Ubuntu 24.04 cài sẵn Ops Agent, build bằng Packer"
  disk_size         = 10
}

build {
  sources = ["source.googlecompute.ubuntu"]

  # Cài Ops Agent bằng script chính thức của Google (bản đã được đọc và lưu trong repo).
  # VM build có IP public nên tải được từ internet. VM chạy từ image này không cần Cloud NAT.
  provisioner "file" {
    source      = "${path.root}/scripts/install-ops-agent.sh"
    destination = "/tmp/install-ops-agent.sh"
  }

  provisioner "shell" {
    inline = [
      "sudo bash /tmp/install-ops-agent.sh --also-install",
      "rm -f /tmp/install-ops-agent.sh",
      "systemctl is-enabled google-cloud-ops-agent",
      "dpkg -s google-cloud-ops-agent | grep -E '^(Package|Version)'",
    ]
  }
}
