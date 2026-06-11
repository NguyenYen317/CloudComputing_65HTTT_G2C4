# Google Maps cho Delivery Web

## 1. Mục đích

Google Maps Platform được tích hợp vào Delivery Web để hỗ trợ shipper trong quá trình giao hàng. Khi shipper xem chi tiết đơn, hệ thống hiển thị thông tin khách hàng, địa chỉ giao hàng, bản đồ giao hàng và nút mở chỉ đường bằng Google Maps.

Chức năng này giúp module giao hàng trực quan hơn, gần với quy trình thực tế của các hệ thống đặt món trực tuyến.

## 2. Dịch vụ Google Maps sử dụng

Các API nên bật trong Google Cloud:

- Maps JavaScript API
- Geocoding API
- Directions API hoặc Routes API

Ý nghĩa:

- Maps JavaScript API dùng để hiển thị bản đồ nhúng trong Delivery Web.
- Geocoding API dùng để chuyển địa chỉ khách hàng từ dạng chữ sang tọa độ lat/lng.
- Directions API hoặc Google Maps directions URL dùng để mở tuyến đường từ cửa hàng đến khách hàng.

## 3. Backend

Backend bổ sung service:

- `order-food-api/services/maps.service.js`

Các chức năng chính:

- `geocodeAddress(address)`: lấy tọa độ từ địa chỉ bằng Google Geocoding API.
- `buildGoogleMapsDirectionsUrl(...)`: tạo URL mở chỉ đường Google Maps.
- `enrichOrderWithMapData(...)`: bổ sung `customerAddress`, `customerLat`, `customerLng`, `storeLat`, `storeLng`, `mapsDirectionsUrl` vào dữ liệu đơn hàng.

Các API mới:

```http
GET /maps/geocode?address=...
GET /maps/directions-url?orderId=...
GET /shipper/orders/detail/:orderId
```

Khi shipper mở chi tiết đơn, backend sẽ kiểm tra đơn hàng. Nếu đơn chỉ có địa chỉ dạng text và backend có `GOOGLE_MAPS_API_KEY`, hệ thống sẽ geocode địa chỉ và lưu lại tọa độ vào order để lần sau không cần gọi Geocoding API lại.

Nếu thiếu API key hoặc Geocoding API lỗi, backend vẫn trả về địa chỉ text và link mở Google Maps bằng địa chỉ.

## 4. Delivery Web

Delivery Web bổ sung:

- `orderfood_delivery/lib/config/maps_config.dart`
- `orderfood_delivery/lib/services/maps_service.dart`
- `orderfood_delivery/lib/widgets/google_map_view.dart`
- Cập nhật `orderfood_delivery/lib/screens/delivery_order_detail_screen.dart`

Màn chi tiết đơn hiển thị:

- Mã đơn
- Thông tin khách hàng
- Số điện thoại
- Địa chỉ giao hàng
- Danh sách món
- Tổng tiền
- Trạng thái đơn
- Bản đồ giao hàng
- Nút **Mở chỉ đường**

Nếu có `GOOGLE_MAPS_API_KEY`, màn hình hiển thị bản đồ nhúng bằng Google Maps. Nếu chưa có API key, màn hình vẫn hiển thị địa chỉ và nút mở Google Maps bằng URL.

## 5. Cấu hình

Backend Cloud Run có thể cấu hình bằng biến môi trường:

```text
GOOGLE_MAPS_API_KEY=...
STORE_LAT=21.028511
STORE_LNG=105.804817
STORE_ADDRESS=Ha Noi, Viet Nam
```

Delivery Web build có thể truyền API key bằng dart-define:

```powershell
flutter build web `
  --dart-define=API_URL=https://order-food-api-294162583218.asia-southeast1.run.app `
  --dart-define=GOOGLE_MAPS_API_KEY=YOUR_GOOGLE_MAPS_API_KEY
```

Không nên commit API key thật lên GitHub. API key nên được giới hạn theo domain Firebase Hosting hoặc domain custom, ví dụ:

```text
https://orderfood-delivery-1b333.web.app/*
https://deli.huydemo.site/*
```

## 6. Luồng demo

```text
Admin chuyển đơn sang waiting_shipper
-> Shipper mở Delivery Web
-> Shipper đăng nhập
-> Shipper xem đơn chờ giao
-> Shipper mở chi tiết đơn
-> Delivery Web hiển thị bản đồ và địa chỉ giao hàng
-> Shipper nhấn "Mở chỉ đường"
-> Google Maps mở tuyến đường từ cửa hàng đến khách
-> Shipper nhận đơn, bắt đầu giao, giao thành công
```

## 7. Đảm bảo ổn định

- Nếu API key sai hoặc thiếu, Delivery Web không bị crash.
- Nếu không có tọa độ khách hàng, hệ thống vẫn mở chỉ đường bằng địa chỉ text.
- Nếu Geocoding API không trả kết quả, backend vẫn trả order như bình thường.
- Chức năng nhận đơn, bắt đầu giao và giao thành công của shipper không bị thay đổi.
