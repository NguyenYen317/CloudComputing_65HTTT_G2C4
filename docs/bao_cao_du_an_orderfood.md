# Báo Cáo Dự Án: Order Food Cloud System

## 1. Thông Tin Chung

**Tên đề tài:** Xây dựng hệ thống đặt món ăn trực tuyến Order Food triển khai trên nền tảng Cloud.

**Loại hệ thống:** Web/App đặt món ăn, quản trị cửa hàng và giao hàng.

**Phạm vi ứng dụng:** Hệ thống phục vụ mô hình giao đồ ăn trong khu vực thành phố Hà Nội.

**Thành phần chính:**

- Web khách hàng và quản trị: `order_food_flutter`
- Backend API: `order-food-api`
- Web giao hàng dành cho shipper: `orderfood_delivery`
- Tài liệu báo cáo: `docs`

## 2. Lý Do Chọn Đề Tài

Hiện nay các ứng dụng đặt món và giao đồ ăn được sử dụng phổ biến trong đời sống hằng ngày. Một hệ thống đặt món thực tế không chỉ cần giao diện cho khách hàng mà còn cần backend xử lý dữ liệu, cơ sở dữ liệu lưu trữ bền vững, giao diện quản trị, hệ thống giao hàng, phân tích dữ liệu và khả năng triển khai trên internet.

Vì vậy nhóm lựa chọn xây dựng hệ thống Order Food nhằm mô phỏng một hệ thống đặt món hoàn chỉnh trên nền tảng cloud. Đề tài giúp vận dụng nhiều kiến thức như frontend, backend, database, cloud deployment, analytics, machine learning, monitoring và các dịch vụ serverless.

## 3. Mục Tiêu Đề Tài

Mục tiêu của đề tài là xây dựng hệ thống Order Food có khả năng:

- Cho phép khách hàng đăng ký, đăng nhập và đăng nhập bằng Google.
         - Khách hàng xem danh sách món ăn, xem chi tiết món, thêm vào giỏ hàng và đặt món.
         - Khách hàng theo dõi trạng thái đơn hàng.
- Cho phép admin quản lý món ăn, đơn hàng, người dùng, doanh thu và dữ liệu phân tích.
- Cho phép shipper nhận đơn, cập nhật trạng thái giao hàng và hoàn thành đơn.
- Lưu dữ liệu bền vững trên cloud.
- Triển khai frontend và backend để người dùng truy cập qua internet.
- Tích hợp BigQuery để lưu dữ liệu phân tích.
- Tích hợp Machine Learning để dự đoán món bán chạy và doanh thu.
- Tích hợp Google Maps để hỗ trợ shipper mở chỉ đường giao hàng.
- Tích hợp Pub/Sub, FCM và Monitoring để mở rộng hệ thống theo hướng cloud-native.

## 4. Kiến Trúc Tổng Thể

Hệ thống được chia thành ba phần chính:

```text
Customer/Admin Web
        |
Firebase Hosting
        |
Cloud Run Backend API
        |
Datastore / Firestore Datastore Mode
        |
BigQuery / Cloud Storage / Pub/Sub / FCM / Machine Learning

Delivery Web
        |
Firebase Hosting
        |
Cloud Run Backend API
        |
Datastore / BigQuery / Google Maps
```

### 4.1. Frontend Order Food

Frontend chính được xây dựng bằng Flutter Web. Ứng dụng này phục vụ hai nhóm người dùng:

- Khách hàng.
- Admin quản trị hệ thống.

Frontend được deploy bằng Firebase Hosting và có thể truy cập qua domain public.

### 4.2. Delivery Web

Delivery Web là một Flutter Web riêng dành cho shipper. Ứng dụng này dùng chung backend và database với hệ thống Order Food.

Delivery Web cho phép shipper:

- Đăng nhập.
- Xem đơn đang chờ giao.
- Nhận đơn giao hàng.
- Xem chi tiết đơn.
- Mở Google Maps để chỉ đường.
- Cập nhật trạng thái đang giao.
- Xác nhận giao thành công.

### 4.3. Backend API

Backend được viết bằng NodeJS/Express, đóng gói bằng Docker và triển khai lên Google Cloud Run. Backend đóng vai trò trung gian giữa frontend, database và các dịch vụ cloud.

Backend xử lý:

- Auth API.
- Food API.
- Cart API.
- Order API.
- Admin API.
- Shipper API.
- Upload API.
- BigQuery API.
- Machine Learning API.
- Notification API.
- Maps API.

### 4.4. Database Và Dữ Liệu Phân Tích

Hệ thống sử dụng:

- Datastore/Firestore Datastore Mode để lưu dữ liệu nghiệp vụ chính.
- BigQuery để lưu dữ liệu phân tích và event.
- Cloud Storage để lưu ảnh món ăn.

## 5. Công Nghệ Sử Dụng

### 5.1. Frontend

- Flutter Web.
- Dart.
- Firebase Authentication SDK.
- Firebase Hosting.
- Google Sign-In.
- HTTP API call.

### 5.2. Backend

- NodeJS.
- Express.
- Docker.
- Google Cloud Run.
- Google Cloud client libraries.

### 5.3. Machine Learning

- Python.
- pandas.
- scikit-learn.
- joblib.
- RandomForestRegressor.

### 5.4. Cloud Services

- Google Cloud Run.
- Firebase Hosting.
- Firebase Authentication.
- Datastore / Firestore Datastore Mode.
- Cloud Storage.
- BigQuery.
- Cloud Scheduler.
- Pub/Sub.
- Firebase Cloud Messaging.
- Cloud Monitoring / Cloud Logging.
- Google Maps Platform.
- Cloud Build.
- Artifact Registry.
- IAM / Service Account.

## 6. Các Dịch Vụ Cloud Đã Sử Dụng

### 6.1. Google Cloud Run

Google Cloud Run được sử dụng để triển khai backend/API. Backend được đóng gói bằng Docker container, có thể chạy NodeJS và Python trong cùng môi trường.

Vai trò trong đề tài:

- Public backend API lên internet.
- Xử lý request từ Flutter Web.
- Kết nối Datastore, BigQuery, Cloud Storage, Pub/Sub và Firebase Admin.
- Chạy các file Machine Learning.
- Tự động mở rộng theo lượng truy cập.

### 6.2. Firebase Hosting

Firebase Hosting được sử dụng để triển khai frontend.

Frontend gồm:

- Web khách hàng/admin.
- Delivery Web dành cho shipper.

Firebase Hosting cung cấp HTTPS mặc định, domain public và khả năng deploy nhanh bằng Firebase CLI.

### 6.3. Firebase Authentication

Firebase Authentication được sử dụng cho chức năng đăng nhập Google ở frontend Order Food. Sau khi người dùng đăng nhập Google, frontend gửi thông tin người dùng về backend để đồng bộ tài khoản và lấy role.

### 6.4. Datastore / Firestore Datastore Mode

Datastore được sử dụng làm database chính của hệ thống.

Dữ liệu lưu trữ gồm:

- Người dùng.
- Món ăn.
- Giỏ hàng.
- Đơn hàng.
- Trạng thái đơn hàng.
- Dữ liệu dự đoán Machine Learning.

Nhờ lưu trên cloud, dữ liệu không bị mất khi tắt máy cá nhân và có thể đồng bộ giữa nhiều thiết bị.

### 6.5. Cloud Storage

Cloud Storage dùng để lưu ảnh món ăn do admin upload. Khi admin thêm hoặc sửa món ăn, ảnh được upload lên bucket cloud và backend trả về URL ảnh để lưu vào dữ liệu món ăn.

### 6.6. BigQuery

BigQuery được dùng để lưu dữ liệu phân tích dạng event.

Các event gồm:

- Tạo đơn hàng.
- Cập nhật trạng thái đơn.
- Hủy đơn.
- Xóa đơn.
- Shipper nhận đơn.
- Shipper bắt đầu giao.
- Shipper giao thành công.

Admin có thể xem dữ liệu BigQuery trên giao diện của quản trị.

### 6.7. Cloud Scheduler

Cloud Scheduler dùng để gọi API Machine Learning theo lịch. Nhờ đó hệ thống có thể tự động cập nhật dự đoán doanh thu và món bán chạy theo chu kỳ.

### 6.8. Pub/Sub

Pub/Sub được sử dụng để publish event bất đồng bộ. Khi có sự kiện quan trọng như tạo đơn, cập nhật trạng thái hoặc cập nhật ML, backend publish event lên topic.

Vai trò:

- Tách xử lý sự kiện khỏi luồng API chính.
- Chuẩn bị cho việc mở rộng gửi thông báo, phân tích dữ liệu hoặc xử lý nền.
- Giúp hệ thống gần với kiến trúc cloud-native.

### 6.9. Firebase Cloud Messaging

FCM được tích hợp ở backend để gửi thông báo khi trạng thái đơn hàng thay đổi. Backend có API lưu FCM token của người dùng và service gửi notification.

### 6.10. Cloud Monitoring Và Cloud Logging

Cloud Monitoring và Cloud Logging dùng để theo dõi backend chạy trên Cloud Run.

Các chỉ số có thể theo dõi:

- Số lượng request.
- Độ trễ request.
- Lỗi 4xx/5xx.
- Log backend.
- CPU/RAM.
- Revision Cloud Run.

### 6.11. Google Maps Platform

Google Maps Platform được tích hợp cho Delivery Web.

Vai trò:

- Hiển thị bản đồ giao hàng nếu có API key.
- Mở Google Maps để shipper xem đường đi.

### 6.12. Cloud Build Và Artifact Registry

Cloud Build dùng để build Docker image của backend. Artifact Registry dùng để lưu image trước khi deploy lên Cloud Run.

### 6.13. IAM / Service Account

IAM được dùng để cấp quyền cho Cloud Run truy cập các dịch vụ như Datastore, BigQuery, Storage và Pub/Sub.

### 6.14. Zoho SalesIQ

Zoho SalesIQ được tích hợp dạng widget script trong frontend để hỗ trợ chat/hỗ trợ khách hàng.

## 7. Chức Năng Hệ Thống

### 7.1. Chức Năng Khách Hàng

Khách hàng có thể:

- Đăng ký tài khoản.
- Đăng nhập bằng email/password.
- Đăng nhập bằng Google.
- Xem danh sách món ăn.
- Tìm kiếm/lọc món ăn.
- Xem chi tiết món ăn.
- Thêm món vào giỏ hàng.
- Cập nhật giỏ hàng.
- Đặt món.
- Nhập địa chỉ giao hàng theo cấu trúc Hà Nội: quận/huyện, phường/xã, số nhà và tên đường.
- Theo dõi trạng thái đơn hàng.
- Hủy đơn nếu đơn còn trong trạng thái cho phép.
- Xóa thông tin đơn khỏi danh sách cá nhân.

### 7.2. Chức Năng Admin

Admin có thể:

- Đăng nhập vào giao diện quản trị.
- Xem dashboard thống kê.
- Quản lý món ăn.
- Thêm, sửa, xóa món ăn.
- Upload ảnh món ăn lên Cloud Storage.
- Quản lý đơn hàng.
- Cập nhật trạng thái đơn hàng.
- Quản lý người dùng.
- Xóa tài khoản khách hàng.
- Xem doanh thu.
- Xem món bán chạy.
- Xem dữ liệu BigQuery.
- Xem dự đoán Machine Learning.
- Huấn luyện lại model ML.
- Cập nhật dự đoán ML.
- Xem đề xuất nhập hàng/khuyến mãi.

### 7.3. Chức Năng Shipper

Shipper có thể:

- Đăng nhập vào Delivery Web.
- Xem danh sách đơn đang chờ giao.
- Nhận đơn hàng.
- Xem chi tiết đơn hàng.
- Mở Google Maps để chỉ đường giao hàng.
- Cập nhật trạng thái đang giao.
- Xác nhận giao hàng thành công.

## 8. Luồng Trạng Thái Đơn Hàng

Luồng chính:

```text
pending
-> confirmed
-> preparing
-> waiting_shipper
-> assigned_shipper
-> delivering
-> completed
```

Ý nghĩa:

| Status | Ý nghĩa |
|---|---|
| pending | Chờ xác nhận |
| confirmed | Đã xác nhận |
| preparing | Đang chuẩn bị |
| waiting_shipper | Chờ shipper lấy hàng |
| assigned_shipper | Shipper đã nhận đơn |
| delivering | Đang giao |
| completed | Giao thành công |
| cancelled | Đã hủy |

Admin có thể hủy đơn trước khi đơn hoàn thành. Khi đơn đã hoàn thành hoặc đã hủy thì không tiếp tục cập nhật trạng thái.

## 9. Backend API

### 9.1. Auth API

```http
POST /auth/register
POST /auth/login
POST /auth/google
POST /auth/google-login
GET  /auth/me
```

Nhóm API này xử lý đăng ký, đăng nhập, đăng nhập Google và lấy thông tin người dùng hiện tại.

### 9.2. Food API

```http
GET /foods
GET /foods/search
GET /foods/:id
```

Nhóm API này lấy danh sách món ăn, tìm kiếm món ăn và xem chi tiết món.

### 9.3. Cart API

```http
GET    /cart
PUT    /cart
GET    /cart/:userId
POST   /cart/:userId/items
PATCH  /cart/:userId/items/:foodId
DELETE /cart/:userId/items/:foodId
DELETE /cart/:userId
```

Nhóm API này quản lý giỏ hàng của khách hàng.

### 9.4. Order API

```http
GET    /orders
POST   /orders
GET    /orders/detail/:orderId
GET    /orders/:userId
PATCH  /orders/:id/cancel
DELETE /orders/:id
```

Nhóm API này tạo đơn hàng, xem đơn hàng, hủy đơn và xóa thông tin đơn.

### 9.5. Admin API

```http
GET    /admin/dashboard
GET    /admin/users
DELETE /admin/users/:userId

GET    /admin/foods
POST   /admin/foods
PATCH  /admin/foods/:id
DELETE /admin/foods/:id

GET    /admin/orders
PATCH  /admin/orders/:id/status

GET /admin/revenue
GET /admin/best-selling-foods
GET /admin/suggestions
GET /admin/bigquery-events
GET /admin/ml-predictions
POST /admin/train-ml-model
POST /admin/update-ml-predictions
POST /admin/foods/upload-image
```

Nhóm API này phục vụ quản trị hệ thống.

### 9.6. Shipper API

```http
GET    /shipper/orders/available
GET    /shipper/orders/my-orders/:shipperId
GET    /shipper/orders/detail/:orderId
PATCH  /shipper/orders/:orderId/accept
PATCH  /shipper/orders/:orderId/delivering
PATCH  /shipper/orders/:orderId/completed
```

Nhóm API này phục vụ Delivery Web.

### 9.7. BigQuery API

```http
GET  /bigquery/order-events
POST /bigquery/order-events
GET  /bigquery/revenue-summary
GET  /bigquery/best-selling-foods
```

Nhóm API này đọc và ghi dữ liệu phân tích từ BigQuery.

### 9.8. Upload API

```http
POST /upload/food-image
POST /admin/foods/upload-image
```

Nhóm API này upload ảnh món ăn lên Cloud Storage.

### 9.9. Machine Learning API

```http
POST /ml/train
POST /ml/predict
GET  /ml/predictions
GET  /admin/ml-predictions
POST /admin/train-ml-model
POST /admin/update-ml-predictions
```

Nhóm API này phục vụ huấn luyện model và cập nhật dự đoán.

### 9.10. Notification API

```http
POST /notifications/save-token
```

API này lưu FCM token để backend có thể gửi thông báo cho người dùng.

### 9.11. Maps API

```http
GET /maps/geocode
GET /maps/directions-url
```

Nhóm API này hỗ trợ chuyển địa chỉ thành tọa độ và tạo URL chỉ đường Google Maps.

## 10. Machine Learning

Phần Machine Learning được xây dựng bằng Python và scikit-learn, chạy trong backend container trên Cloud Run.

### 10.1. Dữ Liệu

Dữ liệu đầu vào gồm đơn hàng, món ăn, số lượng, giá tiền, thời gian đặt hàng và tổng tiền.

Các file chính:

- `orders_sample.csv`
- `orders_runtime.csv`
- `train_model.py`
- `predict.py`
- `model_food.pkl`
- `model_revenue.pkl`
- `predictions.json`

### 10.2. Model

Hệ thống sử dụng RandomForestRegressor để dự đoán:

- Số lượng bán của từng món.
- Doanh thu dự kiến.

### 10.3. Kết Quả Dự Đoán

Kết quả Machine Learning gồm:

- Món bán chạy.
- Doanh thu dự kiến ngày mai.
- Doanh thu dự kiến 7 ngày.
- Đề xuất nhập nguyên liệu.
- Đề xuất khuyến mãi.

## 11. Google Maps Trong Delivery Web

Delivery Web tích hợp Google Maps để hỗ trợ shipper giao hàng. Khi xem chi tiết đơn, shipper có thể bấm nút mở chỉ đường.

Đặc điểm:

- Điểm xuất phát mặc định là vị trí hiện tại của shipper.
- Điểm đến là địa chỉ khách hàng.

## 12. Triển Khai Hệ Thống

### 12.1. Backend

Backend được deploy lên Cloud Run.

Quy trình:

```text
Source code
-> Dockerfile
-> Cloud Build
-> Artifact Registry
-> Cloud Run
```

### 12.2. Frontend Order Food

Frontend khách hàng/admin được build bằng Flutter Web và deploy lên Firebase Hosting.

### 12.3. Delivery Web

Delivery Web được build bằng Flutter Web và deploy lên một Firebase Hosting site riêng.

### 12.4. Domain

Hệ thống có thể sử dụng domain mặc định của Firebase hoặc domain custom.

- Web Order Food: `orderfood.huydemo.site`
- Web Delivery: `deli.huydemo.site`

## 13. Kiểm Thử

### 13.1. Kiểm Thử Backend

Các API được kiểm thử bằng PowerShell `Invoke-WebRequest`, `Invoke-RestMethod` và `curl`.

Ví dụ:

```powershell
Invoke-WebRequest https://order-food-api-294162583218.asia-southeast1.run.app/health -UseBasicParsing
Invoke-WebRequest https://order-food-api-294162583218.asia-southeast1.run.app/foods -UseBasicParsing
```

### 13.2. Kiểm Thử Frontend

Frontend được kiểm thử bằng:

```powershell
flutter analyze
flutter build web
```

### 13.3. Kiểm Thử Cloud

Các dịch vụ cloud được kiểm tra bằng:

- Google Cloud Console.
- Firebase Console.
- BigQuery Query Editor.
- Cloud Run logs.
- Pub/Sub subscription pull.
- Cloud Monitoring Metrics Explorer.

## 14. Kết Quả Đạt Được

Sau khi hoàn thành, hệ thống đạt được các kết quả:

- Web khách hàng có thể đặt món qua internet.
- Web admin có thể quản lý món ăn, đơn hàng, người dùng và dữ liệu phân tích.
- Delivery Web cho phép shipper nhận và giao đơn.
- Backend chạy ổn định trên Cloud Run.
- Dữ liệu được lưu bền vững trên Datastore.
- Ảnh món ăn được lưu trên Cloud Storage.
- Event đơn hàng được ghi vào BigQuery.
- Machine Learning dự đoán món bán chạy và doanh thu.
- Pub/Sub publish event bất đồng bộ.
- FCM hỗ trợ thông báo trạng thái đơn.
- Cloud Monitoring theo dõi hệ thống.
- Google Maps hỗ trợ shipper mở chỉ đường giao hàng.


## 15. Kết Luận

Đề tài Order Food Cloud System đã xây dựng được một hệ thống đặt món ăn tương đối hoàn chỉnh, có đầy đủ ba vai trò khách hàng, admin và shipper. Hệ thống không chỉ dừng ở chức năng CRUD cơ bản mà còn tích hợp nhiều dịch vụ cloud như Cloud Run, Firebase Hosting, Datastore, BigQuery, Cloud Storage, Scheduler, Pub/Sub, FCM, Monitoring và Google Maps.

Thông qua đề tài, nhóm đã hiểu rõ hơn cách triển khai một ứng dụng thực tế trên môi trường cloud, cách frontend gọi backend public API, cách lưu dữ liệu bền vững, cách phân tích dữ liệu bằng BigQuery, cách tự động hóa bằng Scheduler, cách tích hợp Machine Learning và cách giám sát hệ thống bằng Cloud Monitoring.

Hệ thống có thể tiếp tục phát triển để trở thành một web/app đặt món thực tế với khả năng mở rộng, bảo trì và vận hành tốt hơn.
