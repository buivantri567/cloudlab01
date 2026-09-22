# IAM role riêng cho từng VM, chỉ cấp quyền tối thiểu (nguyên tắc least privilege).
# Dùng chung một role cho nhiều VM sẽ khiến quyền của VM này lan sang VM khác.

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "app" {
  name               = "app-vm-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_role" "db" {
  name               = "db-vm-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

# Quyền cơ bản để VM ghi log và metric lên CloudWatch Logs / CloudWatch Metrics
data "aws_iam_policy_document" "vm_logging" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }

  statement {
    actions   = ["cloudwatch:PutMetricData"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "app_logging" {
  name   = "vm-logging"
  role   = aws_iam_role.app.id
  policy = data.aws_iam_policy_document.vm_logging.json
}

resource "aws_iam_role_policy" "db_logging" {
  name   = "vm-logging"
  role   = aws_iam_role.db.id
  policy = data.aws_iam_policy_document.vm_logging.json
}

resource "aws_iam_instance_profile" "app" {
  name = "app-vm-profile"
  role = aws_iam_role.app.name
}

resource "aws_iam_instance_profile" "db" {
  name = "db-vm-profile"
  role = aws_iam_role.db.name
}
