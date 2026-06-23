# Chia chức năng theo dịch vụ cloud trong project Order Food

Tài liệu này chia các chức năng của project theo từng dịch vụ cloud/dịch vụ tích hợp đã sử dụng. Cách chia này phù hợp để đưa vào báo cáo môn Điện toán đám mây hoặc chia việc nhóm.

## 1. Google Cloud Run - Hiếu

**Vai trò:** Triển khai backend/API của hệ thống.

**Chức năng liên quan:**

- Public backend NodeJS/Express lên internet.
- Xử lý API cho web khách hàng, admin và delivery.
- Chạy backend trong Docker container.
- Chạy các script Python Machine Learning trong môi trường backend.
- Tự động mở rộng khi có nhiều request.
- Cung cấp HTTPS mặc định cho API.

**Minh chứng trong project:**

- Backend: `order-food-api`
- Dockerfile: `order-food-api/Dockerfile`
- API public: `https://order-food-api-294162583218.asia-southeast1.run.app`

---

## 2. Firebase Hosting - Hiếu

**Vai trò:** Triển khai frontend web.

**Chức năng liên quan:**

- Deploy web khách hàng/admin.
- Deploy Delivery Web riêng cho shipper.
- Cung cấp HTTPS mặc định.
- Hỗ trợ custom domain.
- Cho phép người dùng truy cập web qua internet.

**Minh chứng trong project:**

- Web chính: `order_food_flutter`
- Delivery Web: `orderfood_delivery`
- Domain Firebase:
  - `https://flutter-orderfood-1b333.web.app`
  - `https://orderfood-delivery-1b333.web.app`

---

## 3. Firebase Authentication - Hiếu

**Vai trò:** Xác thực người dùng bằng Google.

**Chức năng liên quan:**

- Đăng nhập bằng Google.
- Lấy thông tin email, tên, avatar từ tài khoản Google.
- Đồng bộ tài khoản Google với backend.
- Backend kiểm tra email để phân quyền customer/admin/shipper.
- Cấu hình authorized domains để đăng nhập trên Firebase Hosting và custom domain.

**Minh chứng trong project:**

- Flutter Google Sign-In.
- Firebase config: `order_food_flutter/lib/firebase_options.dart`
- API đồng bộ Google login trong backend.

---

## 4. Cloud Datastore / Firestore Datastore - Yên

**Vai trò:** Database chính của hệ thống.

**Chức năng liên quan:**

- Lưu tài khoản người dùng.
- Lưu danh sách món ăn.
- Lưu giỏ hàng theo người dùng.
- Lưu đơn hàng.
- Lưu trạng thái đơn hàng.
- Lưu dữ liệu dự đoán Machine Learning.
- Đồng bộ dữ liệu khi đăng nhập cùng tài khoản trên thiết bị khác.

**Minh chứng trong project:**

- Repositories backend:
  - `order-food-api/repositories/user.repository.js`
  - `order-food-api/repositories/food.repository.js`
  - `order-food-api/repositories/cart.repository.js`
  - `order-food-api/repositories/order.repository.js`

---

## 5. Cloud Storage - Yên

**Vai trò:** Lưu ảnh món ăn.

**Chức năng liên quan:**

- Admin upload ảnh món ăn.
- Backend nhận ảnh từ frontend.
- Backend lưu ảnh lên Cloud Storage bucket.
- Trả về URL ảnh để lưu vào món ăn.
- Frontend hiển thị ảnh món ăn từ URL.

**Minh chứng trong project:**

- API upload ảnh:
  - `POST /admin/foods/upload-image`
  - `POST /upload/food-image`
- Service upload/storage trong backend.

---

## 6. BigQuery - Tân

**Vai trò:** Phân tích dữ liệu đơn hàng.

**Chức năng liên quan:**

- Ghi event khi khách tạo đơn.
- Ghi event khi admin cập nhật trạng thái đơn.
- Ghi event khi khách hủy đơn.
- Ghi event khi shipper nhận đơn.
- Ghi event khi shipper đang giao.
- Ghi event khi shipper giao thành công.
- Admin xem dữ liệu BigQuery trên dashboard.
- Hỗ trợ thống kê doanh thu và món bán chạy.

**Minh chứng trong project:**

- Bảng dữ liệu event:
  - `orderfood_analytics.order_events`
- API:
  - `GET /admin/bigquery-events`
  - `GET /bigquery/order-events`
  - `GET /bigquery/revenue-summary`
  - `GET /bigquery/best-selling-foods`

---

## 7. Cloud Scheduler - Tân

**Vai trò:** Tự động hóa tác vụ định kỳ.

**Chức năng liên quan:**

- Tự động gọi API Machine Learning theo lịch.
- Tự động cập nhật dự đoán doanh thu/món bán chạy.
- Giảm thao tác thủ công của admin.
- Mô phỏng tác vụ tự động trong hệ thống cloud thực tế.

**Minh chứng trong project:**

- API được gọi theo lịch:
  - `POST /admin/train-ml-model`
  - `POST /admin/update-ml-predictions`

---

## 8. Google Cloud Pub/Sub - Tân

**Vai trò:** Xử lý sự kiện bất đồng bộ.

**Chức năng liên quan:**

- Publish event khi có thay đổi đơn hàng.
- Tách xử lý sự kiện khỏi luồng API chính.
- Hỗ trợ mở rộng sang notification, analytics hoặc data pipeline.
- Kiểm tra message bằng subscription debug.

**Minh chứng trong project:**

- Topic: `order-events-topic`
- Subscription debug: `order-events-debug-sub`
- Event ví dụ:
  - `ML_PREDICTION_UPDATED`
  - `ORDER_CREATED`
  - `ORDER_STATUS_UPDATED`

---

## 9. Firebase Cloud Messaging - FCM - Huy

**Vai trò:** Hỗ trợ thông báo.

**Chức năng liên quan:**

- Lưu FCM token của người dùng.
- Chuẩn bị khả năng gửi thông báo khi trạng thái đơn thay đổi.
- Hỗ trợ mở rộng thông báo cho khách hàng, admin hoặc shipper.

**Minh chứng trong project:**

- API:
  - `POST /notifications/save-token`
- Frontend service:
  - `order_food_flutter/lib/services/fcm_service.dart`

---

## 10. Cloud Monitoring / Cloud Logging - Yên

**Vai trò:** Giám sát và debug hệ thống.

**Chức năng liên quan:**

- Xem log backend Cloud Run.
- Theo dõi request count.
- Theo dõi request latency.
- Theo dõi lỗi 4xx/5xx.
- Kiểm tra revision Cloud Run.
- Hỗ trợ debug khi deploy lỗi.

**Minh chứng trong project:**

- Cloud Run logs.
- Metrics Explorer trong Google Cloud Console.
- API health check:
  - `GET /health`

---

## 11. Google Maps Platform - Huy

**Vai trò:** Hỗ trợ giao hàng.

**Chức năng liên quan:**

- Delivery Web hiển thị khu vực bản đồ nếu có API key.
- Shipper mở Google Maps để chỉ đường.
- Chỉ đường từ vị trí hiện tại của shipper tới địa chỉ khách.
- Ưu tiên chế độ xe máy.
- Có thể dùng Geocoding API để chuyển địa chỉ thành tọa độ.

**Minh chứng trong project:**

- Delivery Web: `orderfood_delivery`
- File cấu hình map: `orderfood_delivery/lib/config/maps_config.dart`
- Màn hình chi tiết đơn giao: `orderfood_delivery/lib/screens/delivery_order_detail_screen.dart`

---

## 12. Cloud Build - Thịnh

**Vai trò:** Build backend container image.

**Chức năng liên quan:**

- Build Docker image từ source backend.
- Đóng gói NodeJS, Python và thư viện ML vào container.
- Tạo image để deploy lên Cloud Run.

**Minh chứng trong project:**

- Lệnh:
  - `gcloud builds submit --tag ...`

---

## 13. Artifact Registry - Thịnh

**Vai trò:** Lưu trữ Docker image.

**Chức năng liên quan:**

- Lưu Docker image của backend sau khi build.
- Cloud Run lấy image từ Artifact Registry để deploy revision mới.
- Quản lý phiên bản image backend.

**Minh chứng trong project:**

- Repository:
  - `orderfood-repo`
- Image:
  - `asia-southeast1-docker.pkg.dev/flutter-orderfood-497814/orderfood-repo/order-food-api:latest`

---

## 14. IAM / Service Account - Thịnh

**Vai trò:** Phân quyền truy cập dịch vụ cloud.

**Chức năng liên quan:**

- Cấp quyền Cloud Run đọc/ghi Datastore.
- Cấp quyền ghi BigQuery.
- Cấp quyền upload Cloud Storage.
- Cấp quyền publish Pub/Sub.
- Cấp quyền đọc Secret Manager.
- Quản lý service account backend.

**Minh chứng trong project:**

- Các role thường dùng:
  - `roles/datastore.user`
  - `roles/bigquery.dataEditor`
  - `roles/bigquery.jobUser`
  - `roles/storage.objectAdmin`
  - `roles/pubsub.publisher`
  - `roles/secretmanager.secretAccessor`

---

## 15. Google Secret Manager - Huy

**Vai trò:** Quản lý thông tin nhạy cảm.

**Chức năng liên quan:**

- Lưu Google Maps API Key.
- Lưu Firebase Admin config.
- Lưu JWT secret.
- Lưu FCM key.
- Lưu Pub/Sub topic.
- Lưu Cloud Storage bucket.
- Lưu admin emails hoặc ML secret nếu cần.
- Tránh hardcode key trong source code.

**Minh chứng trong project:**

- Config backend:
  - `order-food-api/config/secretManager.js`
- Tài liệu:
  - `docs/secret_manager.md`

---

## 16. Zoho SalesIQ - Huy

**Vai trò:** Hỗ trợ tư vấn/chat khách hàng.

**Chức năng liên quan:**

- Nhúng widget Zoho SalesIQ vào website.
- Hỗ trợ khách liên hệ nhanh khi cần tư vấn.
- Mô phỏng kênh chăm sóc khách hàng cho website thương mại điện tử.
- Có thể bật/tắt bằng cách thêm hoặc bỏ script trong frontend.

**Minh chứng trong project:**

- File nhúng script:
  - `order_food_flutter/web/index.html`

---

## 17. Machine Learning - Python Random Forest - Huy

**Vai trò:** Dự đoán và hỗ trợ ra quyết định kinh doanh.

**Chức năng liên quan:**

- Train model dự đoán số lượng bán.
- Train model dự đoán doanh thu.
- Dự đoán món bán chạy.
- Dự đoán doanh thu ngày mai và 7 ngày tới.
- Đề xuất nhập thêm nguyên liệu.
- Đề xuất khuyến mãi.
- Admin có thể bấm train/predict thủ công.
- Cloud Scheduler có thể gọi tự động theo lịch.

**Minh chứng trong project:**

- File ML:
  - `order-food-api/ml/train_model.py`
  - `order-food-api/ml/predict.py`
  - `order-food-api/ml/orders_sample.csv`
  - `order-food-api/ml/predictions.json`

---

## 18. Domain / DNS - Huy

**Vai trò:** Gắn tên miền riêng cho website.

**Chức năng liên quan:**

- Gắn domain chính cho web khách hàng/admin.
- Gắn domain riêng cho Delivery Web.
- Cấu hình DNS record tại nhà cung cấp domain.
- Firebase xác minh domain và cấp SSL certificate.
- Người dùng truy cập website bằng tên miền dễ nhớ.

**Minh chứng trong project:**

- Domain chính:
  - `orderfood.huydemo.site`
- Domain delivery:
  - `deli.huydemo.site`

