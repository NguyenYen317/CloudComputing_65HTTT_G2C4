class DeliveryOrderModel {
  const DeliveryOrderModel({
    required this.orderId,
    required this.userId,
    required this.customerName,
    required this.userEmail,
    required this.phone,
    required this.address,
    required this.status,
    required this.totalAmount,
    required this.items,
    this.note = '',
    this.createdAt = '',
    this.updatedAt = '',
    this.customerAddress = '',
    this.customerLat,
    this.customerLng,
    this.storeAddress = '',
    this.storeLat,
    this.storeLng,
    this.mapsDirectionsUrl = '',
  });

  final String orderId;
  final String userId;
  final String customerName;
  final String userEmail;
  final String phone;
  final String address;
  final String status;
  final int totalAmount;
  final List<dynamic> items;
  final String note;
  final String createdAt;
  final String updatedAt;
  final String customerAddress;
  final double? customerLat;
  final double? customerLng;
  final String storeAddress;
  final double? storeLat;
  final double? storeLng;
  final String mapsDirectionsUrl;

  String get customerAddressOrAddress =>
      customerAddress.trim().isNotEmpty ? customerAddress : address;

  factory DeliveryOrderModel.fromJson(Map<String, dynamic> data) {
    final address =
        (data['customerAddress'] ??
                data['address'] ??
                data['shippingAddress'] ??
                '')
            .toString();

    return DeliveryOrderModel(
      orderId: (data['id'] ?? data['orderId'] ?? data['code'] ?? '').toString(),
      userId: (data['userId'] ?? '').toString(),
      customerName:
          (data['customerName'] ??
                  data['name'] ??
                  data['userName'] ??
                  data['userEmail'] ??
                  'Khách hàng')
              .toString(),
      userEmail: (data['userEmail'] ?? data['email'] ?? '').toString(),
      phone: (data['phone'] ?? data['customerPhone'] ?? '').toString(),
      address: address,
      status: (data['status'] ?? 'waiting_shipper').toString(),
      totalAmount: NumberParser.toInt(data['totalAmount'] ?? data['total']),
      items: List<dynamic>.from(data['items'] as List? ?? const []),
      note: (data['note'] ?? data['notes'] ?? '').toString(),
      createdAt: (data['createdAt'] ?? '').toString(),
      updatedAt: (data['updatedAt'] ?? '').toString(),
      customerAddress: address,
      customerLat: NumberParser.toDouble(data['customerLat']),
      customerLng: NumberParser.toDouble(data['customerLng']),
      storeAddress: (data['storeAddress'] ?? '').toString(),
      storeLat: NumberParser.toDouble(data['storeLat']),
      storeLng: NumberParser.toDouble(data['storeLng']),
      mapsDirectionsUrl: (data['mapsDirectionsUrl'] ?? '').toString(),
    );
  }

  String get itemSummary {
    if (items.isEmpty) return 'Chưa có món';
    return items
        .map((item) {
          if (item is Map) {
            final name = item['name'] ?? item['foodName'] ?? 'Món ăn';
            final quantity = item['quantity'] ?? 1;
            return '$name x$quantity';
          }
          return item.toString();
        })
        .join(', ');
  }
}

class NumberParser {
  const NumberParser._();

  static int toInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double? toDouble(Object? value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }
}
