#!/usr/bin/env bash
# Xoá image do Packer tạo (mặc định: mọi image trong family "packer-test").
#
# Dùng:
#   PROJECT_ID=user-cjpobzxpcgar ./delete-images.sh                 # xoá cả family, hỏi xác nhận
#   PROJECT_ID=... KEEP=1 ./delete-images.sh                        # giữ lại 1 image mới nhất
#   PROJECT_ID=... ./delete-images.sh packer-test-20260921-034437   # xoá đúng image chỉ định
#   PROJECT_ID=... DRY_RUN=1 ./delete-images.sh                     # chỉ liệt kê, không xoá
#   PROJECT_ID=... YES=1 ./delete-images.sh                         # bỏ qua bước hỏi xác nhận
#
# FAMILY=<tên> để đổi family (mặc định packer-test, khớp với image_family trong template).
# Xoá image không thể hoàn tác.
set -euo pipefail

PROJECT_ID="${PROJECT_ID:-$(gcloud config get-value project 2>/dev/null || true)}"
if [[ -z "$PROJECT_ID" ]]; then
  echo "Thiếu PROJECT_ID. Chạy: PROJECT_ID=<id> $0" >&2
  exit 1
fi

FAMILY="${FAMILY:-packer-test}"
KEEP="${KEEP:-0}"

if [[ $# -gt 0 ]]; then
  # Image chỉ định thẳng trên dòng lệnh; KEEP không áp dụng
  IMAGES=("$@")
else
  # Mới nhất trước, bỏ qua KEEP image đầu tiên
  mapfile -t IMAGES < <(
    gcloud compute images list \
      --project="$PROJECT_ID" \
      --filter="family=$FAMILY" \
      --sort-by="~creationTimestamp" \
      --format="value(name)" | tail -n +"$((KEEP + 1))"
  )
fi

if [[ ${#IMAGES[@]} -eq 0 ]]; then
  echo "Không có image nào cần xoá (project=$PROJECT_ID, family=$FAMILY, giữ lại=$KEEP)."
  exit 0
fi

echo "Project: $PROJECT_ID"
echo "Sẽ xoá ${#IMAGES[@]} image:"
printf '  - %s\n' "${IMAGES[@]}"

if [[ "${DRY_RUN:-0}" == "1" ]]; then
  echo
  echo "[dry-run] gcloud compute images delete ${IMAGES[*]} --project=$PROJECT_ID --quiet"
  exit 0
fi

if [[ "${YES:-0}" != "1" ]]; then
  read -r -p "Xoá vĩnh viễn các image trên? [y/N] " answer
  if [[ ! "$answer" =~ ^[Yy]$ ]]; then
    echo "Đã huỷ."
    exit 1
  fi
fi

gcloud compute images delete "${IMAGES[@]}" --project="$PROJECT_ID" --quiet

echo
echo "Image còn lại trong family $FAMILY:"
gcloud compute images list --project="$PROJECT_ID" --filter="family=$FAMILY" \
  --format="table(name,creationTimestamp.date())" || true
