# Cloud Services: Pub/Sub, Firebase Cloud Messaging, Cloud Monitoring

## 1. Google Cloud Pub/Sub

Google Cloud Pub/Sub được sử dụng để xử lý sự kiện đơn hàng theo cơ chế bất đồng bộ. Khi khách hàng tạo đơn, admin cập nhật trạng thái, shipper nhận đơn hoặc hoàn thành giao hàng, backend Cloud Run sẽ publish event lên topic `order-events-topic`.

Các event chính gồm:

- `ORDER_CREATED`
- `ORDER_STATUS_UPDATED`
- `ORDER_CANCELLED`
- `ORDER_COMPLETED`
- `ORDER_DELETED`
- `SHIPPER_ACCEPTED_ORDER`
- `SHIPPER_STARTED_DELIVERY`
- `SHIPPER_COMPLETED_DELIVERY`
- `ML_PREDICTION_UPDATED`

Pub/Sub giúp tách phần xử lý sự kiện ra khỏi luồng API chính. Nhờ vậy hệ thống có thể mở rộng thêm các tác vụ như ghi BigQuery, gửi thông báo FCM hoặc cập nhật Machine Learning mà không làm chậm request đặt món/giao hàng.

Trong code, Pub/Sub được triển khai tại:

- `order-food-api/services/pubsub.service.js`
- `order-food-api/constants/pubsubEventTypes.js`

Nếu Pub/Sub lỗi hoặc chưa cấu hình, backend chỉ ghi log lỗi và vẫn trả kết quả cho API chính.

## 2. Firebase Cloud Messaging

Firebase Cloud Messaging được dùng để gửi thông báo cho người dùng khi trạng thái đơn hàng thay đổi.

Các nội dung thông báo theo trạng thái:

- `pending`: Đơn hàng của bạn đã được tạo thành công.
- `confirmed`: Đơn hàng của bạn đã được xác nhận.
- `preparing`: Nhà hàng đang chuẩn bị món ăn của bạn.
- `waiting_shipper`: Đơn hàng đã sẵn sàng và đang chờ shipper lấy hàng.
- `assigned_shipper`: Shipper đã nhận đơn hàng của bạn.
- `delivering`: Đơn hàng của bạn đang được giao.
- `completed`: Đơn hàng đã được giao thành công.
- `cancelled`: Đơn hàng đã được hủy.

Backend có API lưu FCM token:

```http
POST /notifications/save-token
Content-Type: application/json

{
  "userId": "USER_001",
  "fcmToken": "FCM_DEVICE_TOKEN"
}
```

Các file chính:

- `order-food-api/config/firebaseAdmin.js`
- `order-food-api/routes/notification.routes.js`
- `order-food-api/controllers/notification.controller.js`
- `order-food-api/services/notification.service.js`

Nếu user chưa có FCM token hoặc Firebase Admin SDK chưa cấu hình, backend sẽ bỏ qua bước gửi thông báo và ghi log để theo dõi.

## 3. Google Cloud Monitoring

Google Cloud Monitoring dùng để giám sát backend chạy trên Cloud Run. Hệ thống có thể theo dõi request, latency, lỗi 4xx/5xx, log backend, CPU/RAM và trạng thái revision Cloud Run.

Backend đã bổ sung request logging middleware:

- `order-food-api/middlewares/requestLogger.middleware.js`

Middleware log các thông tin:

- HTTP method
- path
- status code
- response time
- timestamp
- userId nếu có
- role nếu có

Backend cũng có health check endpoint:

```http
GET /health
```

Response:

```json
{
  "success": true,
  "message": "Order Food API is healthy",
  "timestamp": "2026-06-10T10:00:00.000Z"
}
```

Các chỉ số nên theo dõi trên Cloud Monitoring:

- Cloud Run request count
- Cloud Run request latency
- Cloud Run 4xx errors
- Cloud Run 5xx errors
- Container CPU utilization
- Container memory utilization
- Cloud Run instance count

Alert đề xuất:

- Backend 5xx errors > 5 trong 5 phút
- Request latency > 2 giây
- Cloud Run service không phản hồi

## 4. Kiến trúc sau khi bổ sung

```text
Customer Web / Admin Web / Delivery Web
        |
Firebase Hosting
        |
Cloud Run Backend API
        |
Datastore / Firestore
        |
Cloud Pub/Sub
        |
BigQuery / Firebase Cloud Messaging / Machine Learning
        |
Cloud Monitoring theo dõi request, log, metrics và lỗi
```

Luồng đặt món:

```text
Khách đặt món
-> Flutter gọi Cloud Run API
-> Backend lưu order vào Datastore/Firestore
-> Backend publish ORDER_CREATED lên Pub/Sub
-> Backend ghi event vào BigQuery
-> Backend gửi FCM nếu user có token
-> Cloud Monitoring ghi nhận request, latency và log
```

Luồng giao hàng:

```text
Admin chuyển đơn sang waiting_shipper
-> Delivery Web thấy đơn chờ giao
-> Shipper nhận đơn
-> Backend publish SHIPPER_ACCEPTED_ORDER
-> Shipper bắt đầu giao
-> Backend publish SHIPPER_STARTED_DELIVERY
-> Shipper giao thành công
-> Backend publish SHIPPER_COMPLETED_DELIVERY
-> BigQuery lưu event và FCM thông báo cho khách
```
