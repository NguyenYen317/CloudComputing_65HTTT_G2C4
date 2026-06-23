# Google Secret Manager cho Order Food Backend

## 1. Mục tiêu

Google Secret Manager được bổ sung để quản lý các thông tin nhạy cảm của backend thay vì hardcode trong source code hoặc commit lên GitHub.

Secret Manager giúp:

- Bảo vệ API key, token và credentials.
- Không để lộ secret trong repository.
- Dễ thay đổi secret mà không cần sửa code.
- Phù hợp với backend chạy trên Google Cloud Run.
- Tăng mức độ bảo mật khi demo và triển khai hệ thống cloud.

## 2. Các secret nên tạo

Các secret ưu tiên:

```text
GOOGLE_MAPS_API_KEY
FIREBASE_ADMIN_CONFIG
JWT_SECRET
FCM_SERVER_KEY
CLOUD_STORAGE_BUCKET
PUBSUB_ORDER_TOPIC
```

Các secret mở rộng:

```text
BIGQUERY_DATASET_ID
BIGQUERY_TABLE_ID
ADMIN_EMAILS
ML_SECRET_KEY
```

## 3. Mapping secret sang biến môi trường backend

Backend tự đọc secret và nạp vào `process.env` khi khởi động nếu bật:

```text
ENABLE_SECRET_MANAGER=true
```

Mapping mặc định:

| Secret Manager name | Biến môi trường backend |
|---|---|
| GOOGLE_MAPS_API_KEY | GOOGLE_MAPS_API_KEY |
| FIREBASE_ADMIN_CONFIG | FIREBASE_ADMIN_CONFIG |
| JWT_SECRET | JWT_SECRET |
| FCM_SERVER_KEY | FCM_SERVER_KEY |
| BIGQUERY_DATASET_ID | BIGQUERY_DATASET |
| BIGQUERY_TABLE_ID | BIGQUERY_ORDER_EVENTS_TABLE |
| PUBSUB_ORDER_TOPIC | PUBSUB_ORDER_EVENTS_TOPIC |
| CLOUD_STORAGE_BUCKET | FOOD_IMAGE_BUCKET |
| ADMIN_EMAILS | ADMIN_EMAILS |
| ML_SECRET_KEY | ML_SECRET_KEY |

Nếu biến môi trường đã tồn tại, mặc định backend sẽ không ghi đè. Muốn secret ghi đè env hiện có, bật:

```text
SECRET_MANAGER_OVERRIDE_ENV=true
```

## 4. Lệnh bật API

```powershell
gcloud config set project flutter-orderfood-497814
gcloud services enable secretmanager.googleapis.com
```

## 5. Tạo secret

Ví dụ tạo Google Maps API key:

```powershell
echo "YOUR_GOOGLE_MAPS_API_KEY" | gcloud secrets create GOOGLE_MAPS_API_KEY --data-file=-
```

Ví dụ tạo Cloud Storage bucket:

```powershell
echo "orderfood-menu-images-497814" | gcloud secrets create CLOUD_STORAGE_BUCKET --data-file=-
```

Ví dụ tạo Pub/Sub topic:

```powershell
echo "order-events-topic" | gcloud secrets create PUBSUB_ORDER_TOPIC --data-file=-
```

Ví dụ tạo admin emails:

```powershell
echo "phuy08463@gmail.com,admin123@gmail.com" | gcloud secrets create ADMIN_EMAILS --data-file=-
```

Nếu secret đã tồn tại và muốn cập nhật giá trị mới:

```powershell
echo "NEW_SECRET_VALUE" | gcloud secrets versions add GOOGLE_MAPS_API_KEY --data-file=-
```

## 6. FIREBASE_ADMIN_CONFIG

`FIREBASE_ADMIN_CONFIG` có thể lưu JSON service account dạng raw JSON hoặc base64.

Khuyến nghị dùng base64 để tránh lỗi xuống dòng:

```powershell
$json = Get-Content "D:\path\service-account.json" -Raw
$base64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($json))
$base64 | gcloud secrets create FIREBASE_ADMIN_CONFIG --data-file=-
```

Nếu secret đã có:

```powershell
$base64 | gcloud secrets versions add FIREBASE_ADMIN_CONFIG --data-file=-
```

## 7. Cấp quyền cho Cloud Run đọc secret

Cloud Run hiện dùng service account:

```text
flutter-orderfood-497814@appspot.gserviceaccount.com
```

Cấp quyền đọc secret:

```powershell
$PROJECT_ID="flutter-orderfood-497814"
$RUN_SA="flutter-orderfood-497814@appspot.gserviceaccount.com"

gcloud projects add-iam-policy-binding $PROJECT_ID `
  --member="serviceAccount:$RUN_SA" `
  --role="roles/secretmanager.secretAccessor"
```

## 8. Deploy Cloud Run với Secret Manager

```powershell
gcloud run deploy order-food-api `
  --image asia-southeast1-docker.pkg.dev/flutter-orderfood-497814/orderfood-repo/order-food-api:latest `
  --region asia-southeast1 `
  --allow-unauthenticated `
  --update-env-vars ENABLE_SECRET_MANAGER=true,SECRET_MANAGER_PROJECT_ID=flutter-orderfood-497814
```

Nếu muốn Secret Manager ghi đè các env đã có:

```powershell
gcloud run services update order-food-api `
  --region asia-southeast1 `
  --update-env-vars SECRET_MANAGER_OVERRIDE_ENV=true
```

## 9. Kiểm tra log

```powershell
gcloud run services logs read order-food-api `
  --region asia-southeast1 `
  --limit 100
```

Nếu thành công, log có event:

```text
secret_manager_loaded
```

Nếu secret nào chưa tạo, backend chỉ warning và vẫn tiếp tục chạy.

## 10. Lưu ý bảo mật

- Không commit API key, service account JSON, token hoặc private key lên GitHub.
- Nên giới hạn Google Maps API key theo domain.
- Nên cấp quyền `secretAccessor` cho đúng service account Cloud Run, không cấp rộng cho mọi user.
- Khi lộ secret, tạo version mới hoặc rotate key.
- Không in giá trị secret ra log.
