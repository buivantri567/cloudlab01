#!/usr/bin/env bash
# Bootstrap AWS: tạo S3 bucket + DynamoDB table để lưu và khoá Terraform state
# (chạy lại nhiều lần vẫn an toàn).
#
# Dùng:
#   AWS_ACCOUNT_ID=735234585484 ./create-state-bucket.sh
#   BUCKET=my-tfstate REGION=us-east-1 ./create-state-bucket.sh
#   DRY_RUN=1 ./create-state-bucket.sh   # chỉ in lệnh, không tạo
set -euo pipefail

REGION="${REGION:-$(aws configure get region 2>/dev/null || echo us-east-1)}"
ACCOUNT_ID="${AWS_ACCOUNT_ID:-$(aws sts get-caller-identity --query Account --output text)}"

if [[ -z "$ACCOUNT_ID" ]]; then
  echo "Không lấy được AWS Account ID. Kiểm tra lại credentials." >&2
  exit 1
fi

BUCKET="${BUCKET:-tfstate-${ACCOUNT_ID}}"
DYNAMODB_TABLE="${DYNAMODB_TABLE:-terraform-locks}"

echo "Account:    $ACCOUNT_ID"
echo "Region:     $REGION"
echo "Bucket:     s3://$BUCKET"
echo "Lock table: $DYNAMODB_TABLE"

if [[ "${DRY_RUN:-0}" == "1" ]]; then
  echo
  echo "[dry-run] aws s3api create-bucket --bucket $BUCKET --region $REGION ..."
  echo "[dry-run] aws s3api put-bucket-versioning --bucket $BUCKET --versioning-configuration Status=Enabled"
  echo "[dry-run] aws s3api put-bucket-encryption --bucket $BUCKET ..."
  echo "[dry-run] aws s3api put-public-access-block --bucket $BUCKET ..."
  echo "[dry-run] aws dynamodb create-table --table-name $DYNAMODB_TABLE ..."
  exit 0
fi

if aws s3api head-bucket --bucket "$BUCKET" 2>/dev/null; then
  echo "Bucket đã tồn tại, bỏ qua bước tạo."
else
  if [[ "$REGION" == "us-east-1" ]]; then
    aws s3api create-bucket --bucket "$BUCKET" --region "$REGION"
  else
    aws s3api create-bucket --bucket "$BUCKET" --region "$REGION" \
      --create-bucket-configuration LocationConstraint="$REGION"
  fi
fi

# Bật versioning để khôi phục được state cũ nếu bị ghi đè hoặc hỏng.
aws s3api put-bucket-versioning --bucket "$BUCKET" \
  --versioning-configuration Status=Enabled

# Mã hoá mặc định (SSE-S3) cho toàn bộ object trong bucket.
aws s3api put-bucket-encryption --bucket "$BUCKET" \
  --server-side-encryption-configuration '{
    "Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]
  }'

# Chặn mọi truy cập public.
aws s3api put-public-access-block --bucket "$BUCKET" \
  --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

if aws dynamodb describe-table --table-name "$DYNAMODB_TABLE" --region "$REGION" >/dev/null 2>&1; then
  echo "DynamoDB table đã tồn tại, bỏ qua bước tạo."
else
  aws dynamodb create-table \
    --table-name "$DYNAMODB_TABLE" \
    --region "$REGION" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST

  aws dynamodb wait table-exists --table-name "$DYNAMODB_TABLE" --region "$REGION"
fi

echo
echo "Dùng trong Terraform:"
echo "  terraform {"
echo "    backend \"s3\" {"
echo "      bucket         = \"$BUCKET\""
echo "      key            = \"terraform/state/terraform.tfstate\""
echo "      region         = \"$REGION\""
echo "      dynamodb_table = \"$DYNAMODB_TABLE\""
echo "      encrypt        = true"
echo "    }"
echo "  }"
