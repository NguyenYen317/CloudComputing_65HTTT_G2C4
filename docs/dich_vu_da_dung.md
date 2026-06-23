# Danh sách dịch vụ đã sử dụng trong project Order Food

## 1. Google Cloud Run

Dùng để triển khai backend NodeJS/Express dưới dạng Docker container. Backend API chạy public trên internet, có HTTPS mặc định và tự động mở rộng theo lượng request.

## 2. Firebase Hosting

Dùng để deploy web khách hàng/admin và Delivery Web. Firebase Hosting cung cấp domain mặc định, HTTPS và hỗ trợ gắn custom domain.

## 3. Firebase Authentication

Dùng cho chức năng đăng nhập Google. Sau khi người dùng đăng nhập Google, frontend gửi thông tin về backend để đồng bộ tài khoản và kiểm tra role.

## 4. Cloud Datastore / Firestore Datastore Mode

Dùng làm database chính để lưu người dùng, món ăn, giỏ hàng, đơn hàng, trạng thái đơn và dữ liệu dự đoán Machine Learning.

## 5. Cloud Storage

Dùng để lưu ảnh món ăn do admin upload. Backend upload ảnh lên bucket và lưu URL ảnh vào dữ liệu món ăn.

## 6. BigQuery

Dùng để lưu dữ liệu phân tích dạng event như tạo đơn, hủy đơn, cập nhật trạng thái, shipper nhận đơn và giao hàng thành công.

## 7. Cloud Scheduler

Dùng để tự động gọi API Machine Learning theo lịch, giúp cập nhật dự đoán định kỳ mà không cần thao tác thủ công.

## 8. Google Cloud Pub/Sub

Dùng để publish sự kiện đơn hàng, hỗ trợ xử lý bất đồng bộ và mở rộng hệ thống theo hướng event-driven.

## 9. Firebase Cloud Messaging - FCM

Dùng để lưu token và phục vụ hướng mở rộng gửi thông báo cho khách hàng khi trạng thái đơn hàng thay đổi.

## 10. Cloud Monitoring / Cloud Logging

Dùng để theo dõi backend Cloud Run, xem request, latency, lỗi 4xx/5xx, log runtime và trạng thái revision.

## 11. Google Maps Platform

Dùng trong Delivery Web để hỗ trợ shipper mở chỉ đường từ vị trí hiện tại tới địa chỉ giao hàng.

## 12. Cloud Build

Dùng để build Docker image cho backend trước khi deploy lên Cloud Run.

## 13. Artifact Registry

Dùng để lưu Docker image của backend sau khi Cloud Build hoàn tất.

## 14. IAM / Service Account

Dùng để cấp quyền cho Cloud Run truy cập Datastore, BigQuery, Cloud Storage, Pub/Sub và Secret Manager.

## 15. Google Secret Manager

Dùng để quản lý thông tin nhạy cảm như Google Maps API Key, JWT secret, Firebase Admin config, FCM key, Pub/Sub topic và Cloud Storage bucket.

## 16. Zoho SalesIQ

Dùng để tích hợp widget chat/tư vấn khách hàng trên website, giúp mô phỏng chức năng hỗ trợ người dùng của một hệ thống thương mại điện tử thật.

## 17. Machine Learning - Python Random Forest

Dùng Python, pandas, scikit-learn và RandomForestRegressor để dự đoán món bán chạy, doanh thu dự kiến và đề xuất nhập hàng/khuyến mãi.

## 18. Domain / DNS

Dùng để gắn custom domain cho website, ví dụ `orderfood.huydemo.site` và `deli.huydemo.site`. DNS record được cấu hình để trỏ domain về Firebase Hosting.
