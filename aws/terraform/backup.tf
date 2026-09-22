# Backup bằng snapshot định kỳ cho root volume của app-vm và db-vm.
# Snapshot theo kiểu incremental: chỉ lưu phần thay đổi so với lần trước nên chi phí thấp.

data "aws_iam_policy_document" "dlm_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["dlm.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "dlm" {
  name               = "dlm-lifecycle-role"
  assume_role_policy = data.aws_iam_policy_document.dlm_assume_role.json
}

resource "aws_iam_role_policy_attachment" "dlm" {
  role       = aws_iam_role.dlm.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSDataLifecycleManagerServiceRole"
}

resource "aws_dlm_lifecycle_policy" "daily_snapshot" {
  description        = "Daily snapshot for app-vm and db-vm root volume retain ${var.snapshot_retention_days}"
  execution_role_arn = aws_iam_role.dlm.arn
  state              = "ENABLED"

  policy_details {
    resource_types = ["VOLUME"]

    target_tags = {
      Backup = "daily"
    }

    schedule {
      name = "daily-snapshot"

      create_rule {
        interval      = 24
        interval_unit = "HOURS"
        times         = [var.snapshot_start_time_utc]
      }

      retain_rule {
        count = var.snapshot_retention_days
      }

      tags_to_add = {
        managed_by = "terraform"
      }

      copy_tags = true
    }
  }
}
