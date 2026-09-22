# Lịch tự động bật/tắt VM để tiết kiệm chi phí ngoài giờ làm việc.
# Dùng EventBridge Scheduler gọi thẳng EC2 API (universal target), không cần Lambda.
data "aws_iam_policy_document" "scheduler_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["scheduler.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "vm_schedule" {
  name               = "vm-schedule-role"
  assume_role_policy = data.aws_iam_policy_document.scheduler_assume_role.json
}

resource "aws_iam_role_policy" "vm_schedule" {
  name = "vm-start-stop"
  role = aws_iam_role.vm_schedule.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["ec2:StartInstances", "ec2:StopInstances"]
      Resource = [aws_instance.app.arn, aws_instance.db.arn]
    }]
  })
}

resource "aws_scheduler_schedule" "vm_start" {
  name                         = "vm-start"
  schedule_expression          = var.vm_start_cron
  schedule_expression_timezone = var.vm_schedule_time_zone

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ec2:startInstances"
    role_arn = aws_iam_role.vm_schedule.arn

    input = jsonencode({
      InstanceIds = [aws_instance.app.id, aws_instance.db.id]
    })
  }
}

resource "aws_scheduler_schedule" "vm_stop" {
  name                         = "vm-stop"
  schedule_expression          = var.vm_stop_cron
  schedule_expression_timezone = var.vm_schedule_time_zone

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ec2:stopInstances"
    role_arn = aws_iam_role.vm_schedule.arn

    input = jsonencode({
      InstanceIds = [aws_instance.app.id, aws_instance.db.id]
    })
  }
}
