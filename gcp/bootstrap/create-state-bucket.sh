#!/usr/bin/env bash
# Bootstrap GCP: tạo bucket lưu Terraform state (chạy lại nhiều lần vẫn an toàn).
#
# Dùng:
#   PROJECT_ID=user-cjpobzxpcgar ./create-state-bucket.sh
#   BUCKET=my-tfstate LOCATION=us-central1 PROJECT_ID=... ./create-state-bucket.sh
#   DRY_RUN=1 PROJECT_ID=... ./create-state-bucket.sh   # chỉ in lệnh, không tạo
#
# Cần bật storage.googleapis.com trước (xem enable-apis.sh).
set -euo pipefail

PROJECT_ID="${PROJECT_ID:-$(gcloud config get-value project 2>/dev/null || true)}"
if [[ -z "$PROJECT_ID" ]]; then
  echo "Thiếu PROJECT_ID. Chạy: PROJECT_ID=<id> $0" >&2
  exit 1
fi

# Tên bucket phải là duy nhất toàn cầu và không đổi được sau khi tạo.
BUCKET="${BUCKET:-${PROJECT_ID}-tfstate}"
LOCATION="${LOCATION:-asia-southeast1}"

echo "Project:  $PROJECT_ID"
echo "Bucket:   gs://$BUCKET"
echo "Location: $LOCATION"

if [[ "${DRY_RUN:-0}" == "1" ]]; then
  echo
  echo "[dry-run] gcloud storage buckets create gs://$BUCKET --project=$PROJECT_ID --location=$LOCATION --uniform-bucket-level-access --public-access-prevention"
  echo "[dry-run] gcloud storage buckets update gs://$BUCKET --project=$PROJECT_ID --versioning"
  exit 0
fi

if gcloud storage buckets describe "gs://$BUCKET" --project="$PROJECT_ID" >/dev/null 2>&1; then
  echo "Bucket đã tồn tại, bỏ qua bước tạo."
else
  gcloud storage buckets create "gs://$BUCKET" \
    --project="$PROJECT_ID" \
    --location="$LOCATION" \
    --uniform-bucket-level-access \
    --public-access-prevention
fi

# Bật versioning để khôi phục được state cũ nếu bị ghi đè hoặc hỏng.
gcloud storage buckets update "gs://$BUCKET" --project="$PROJECT_ID" --versioning

echo
gcloud storage buckets describe "gs://$BUCKET" --project="$PROJECT_ID" \
  --format="yaml(name,location,versioning_enabled,uniform_bucket_level_access,public_access_prevention)"

echo
echo "Dùng trong Terraform:"
echo "  terraform {"
echo "    backend \"gcs\" {"
echo "      bucket = \"$BUCKET\""
echo "      prefix = \"terraform/state\""
echo "    }"
echo "  }"
