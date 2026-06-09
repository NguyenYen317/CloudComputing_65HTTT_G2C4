# Delivery / Shipper Module

## 1. Mục tiêu

Module Delivery được bổ sung để mô phỏng phần giao hàng riêng cho shipper trong hệ thống Order Food.

Trước khi có module này, hệ thống đã có luồng khách hàng đặt món và admin xử lý đơn hàng. Sau khi bổ sung Delivery Web, luồng được mở rộng như sau:

Khách đặt món -> Admin xác nhận -> Admin chuẩn bị món -> Admin chuyển đơn sang chờ shipper -> Shipper nhận đơn -> Shipper bắt đầu giao -> Shipper giao thành công.

## 2. Kiến trúc

Delivery Web là một Flutter Web riêng, nằm trong thư mục:

```text
orderfood_delivery/
```

Delivery Web không dùng backend riêng. Ứng dụng này gọi chung backend NodeJS/Express đang chạy trên Google Cloud Run:

```text
Delivery Web
-> Cloud Run API
-> Datastore/Firestore
-> BigQuery
```

Nhờ dùng chung backend và database, trạng thái đơn hàng được đồng bộ giữa:

- Web khách hàng/admin `orderfood.huydemo.site`
- Delivery Web dành cho shipper
- Datastore/Firestore
- BigQuery

## 3. Role shipper

Hệ thống có thêm role mới:

```text
shipper
```

Tài khoản shipper demo:

```text
Email: shipperdemo@gmail.com
Password: shipper123
Role: shipper
```

Chỉ tài khoản có role `shipper` mới được vào Delivery Web. Nếu tài khoản là `customer` hoặc `admin`, hệ thống không cho truy cập màn hình shipper.

## 4. Trạng thái đơn hàng

Hệ thống bổ sung trạng thái mới:

```text
assigned_shipper
```

Luồng trạng thái đầy đủ:

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

## 5. Shipper API

Backend thêm nhóm API:

```text
/shipper
```

Các API chính:

| Method | Endpoint | Chức năng |
|---|---|---|
| GET | `/shipper/orders/available` | Lấy đơn đang chờ shipper |
| GET | `/shipper/orders/my-orders/:shipperId` | Lấy đơn shipper đã nhận |
| PATCH | `/shipper/orders/:orderId/accept` | Shipper nhận đơn |
| PATCH | `/shipper/orders/:orderId/delivering` | Shipper bắt đầu giao |
| PATCH | `/shipper/orders/:orderId/completed` | Shipper giao thành công |

## 6. Logic xử lý

Khi shipper nhận đơn, backend cập nhật:

```json
{
  "status": "assigned_shipper",
  "shipperId": "shipper_001",
  "shipperEmail": "shipperdemo@gmail.com",
  "shipperName": "Shipper Demo",
  "acceptedAt": "...",
  "updatedAt": "..."
}
```

Khi shipper bắt đầu giao:

```json
{
  "status": "delivering",
  "deliveringAt": "...",
  "updatedAt": "..."
}
```

Khi shipper giao thành công:

```json
{
  "status": "completed",
  "completedAt": "...",
  "updatedAt": "..."
}
```

Các ràng buộc:

- Chỉ đơn `waiting_shipper` mới được shipper nhận.
- Chỉ shipper đã nhận đơn mới được cập nhật đơn đó.
- Chỉ đơn `assigned_shipper` mới chuyển sang `delivering`.
- Chỉ đơn `delivering` mới chuyển sang `completed`.
- Đơn `completed` hoặc `cancelled` không cập nhật tiếp.

## 7. BigQuery

Khi shipper cập nhật đơn, backend ghi thêm event vào BigQuery:

- `shipper_assigned`
- `shipper_delivering`
- `shipper_completed`

Dữ liệu này giúp admin theo dõi lịch sử vận hành đơn hàng và phân tích quy trình giao hàng.

## 8. Delivery Web

Delivery Web có các màn hình:

- Đăng nhập shipper
- Đơn chờ giao
- Đơn của tôi
- Chi tiết đơn hàng

Chức năng:

- Shipper xem danh sách đơn đang chờ giao.
- Shipper bấm `Nhận đơn`.
- Shipper xem đơn đã nhận trong tab `Đơn của tôi`.
- Shipper bấm `Bắt đầu giao`.
- Shipper bấm `Giao thành công`.
- Thời gian trong chi tiết đơn được hiển thị theo giờ Việt Nam.

## 9. Luồng demo

1. Khách đăng nhập Order Food.
2. Khách chọn món và đặt hàng.
3. Admin đăng nhập hệ thống.
4. Admin xác nhận đơn.
5. Admin chuyển đơn sang `Đang chuẩn bị`.
6. Admin chuyển đơn sang `Chờ shipper lấy hàng`.
7. Mở Delivery Web.
8. Shipper đăng nhập bằng tài khoản demo.
9. Shipper thấy đơn trong tab `Đơn chờ giao`.
10. Shipper bấm `Nhận đơn`.
11. Đơn chuyển sang `assigned_shipper`.
12. Shipper bấm `Bắt đầu giao`.
13. Đơn chuyển sang `delivering`.
14. Shipper bấm `Giao thành công`.
15. Đơn chuyển sang `completed`.
16. Khách hàng và admin thấy trạng thái đơn được đồng bộ.

## 10. Kết quả

Sau khi bổ sung module Delivery, project Order Food có đầy đủ ba vai trò:

- Customer: đặt món và theo dõi đơn hàng.
- Admin: quản lý món ăn, đơn hàng, người dùng, dữ liệu và ML.
- Shipper: nhận đơn và cập nhật trạng thái giao hàng.

Module này giúp hệ thống sát với nghiệp vụ thực tế hơn, vì tách riêng phần xử lý đơn hàng của cửa hàng và phần giao hàng của shipper.
