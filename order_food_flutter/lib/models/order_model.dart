part of '../main.dart';

class OrderRecord {
  OrderRecord({
    required this.code,
    required this.items,
    required this.total,
    required this.address,
    this.userId = '',
    this.userEmail = '',
    this.status = 'pending',
    this.note = '',
    String? createdAt,
    String? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now().toIso8601String(),
       updatedAt = updatedAt ?? DateTime.now().toIso8601String();

  final String code;
  final List<CartItem> items;
  final int total;
  final String address;
  final String userId;
  final String userEmail;
  String status;
  final String note;
  final String createdAt;
  final String updatedAt;

  factory OrderRecord.fromJson(dynamic json) {
    final data = Map<String, dynamic>.from(json as Map);
    final rawItems = (data['items'] as List?) ?? const [];
    return OrderRecord(
      code: (data['id'] ?? data['orderId'] ?? data['code'] ?? '').toString(),
      items: rawItems
          .map((item) {
            final itemData = Map<String, dynamic>.from(item as Map);
            final foodJson = {
              'id': itemData['id'] ?? itemData['foodId'],
              'name': itemData['name'] ?? itemData['foodName'],
              'price': itemData['price'],
              'originalPrice': itemData['originalPrice'] ?? itemData['price'],
              'image': itemData['image'] ?? '',
              'category': itemData['category'] ?? 'Món ngon',
              'restaurant':
                  itemData['restaurant'] ?? AppConstants.defaultRestaurant,
              'description': itemData['description'] ?? '',
              'rating': itemData['rating'] ?? 4.7,
              'sold': itemData['sold'] ?? 120,
              'discountPercent': itemData['discountPercent'] ?? 0,
              'tags': itemData['tags'] ?? const [],
            };
            return CartItem(
              food: Food.fromJson(foodJson),
              quantity: _asInt(itemData['quantity'], fallback: 1),
            );
          })
          .toList()
          .cast<CartItem>(),
      total: _asInt(data['total'] ?? data['totalAmount']),
      address: (data['address'] ?? '').toString(),
      userId: (data['userId'] ?? '').toString(),
      userEmail: (data['userEmail'] ?? data['email'] ?? '').toString(),
      status: (data['status'] ?? 'pending').toString(),
      note: (data['note'] ?? '').toString(),
      createdAt: (data['createdAt'] ?? '').toString(),
      updatedAt: (data['updatedAt'] ?? '').toString(),
    );
  }
}
