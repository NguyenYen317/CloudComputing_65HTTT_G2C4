part of '../main.dart';

class OrderProvider extends ChangeNotifier {
  List<OrderRecord> orders = [];
  bool loading = false;
  bool actionLoading = false;
  String? error;

  Future<void> fetchOrders({
    required String? userKey,
    String? token,
    bool all = false,
  }) async {
    if (!all && (userKey == null || userKey.isEmpty)) return;

    loading = true;
    error = null;
    notifyListeners();

    try {
      final uri = all
          ? ApiEndpoints.uri(ApiEndpoints.orders)
          : ApiEndpoints.uri(
              '${ApiEndpoints.orders}?userId=${Uri.encodeComponent(userKey!)}',
            );
      final response = await http.get(
        uri,
        headers: _providerAuthHeaders(token),
      );

      if (response.statusCode == 200) {
        orders = _providerJsonList(response.body)
            .map(
              (item) => OrderRecord.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList();
      } else {
        error = 'Không tải được danh sách đơn hàng';
      }
    } catch (err) {
      error = 'Không kết nối được API đơn hàng: $err';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<OrderRecord?> createOrder({
    required AppUser user,
    required List<CartItem> cart,
    required int subtotal,
    required int shippingFee,
    required int voucherDiscount,
    required int totalPrice,
    required String address,
    String note = '',
    String? token,
  }) async {
    final userKey = user.email.trim().toLowerCase();
    final payload = {
      'userId': userKey,
      'userEmail': user.email,
      'items': cart
          .map(
            (item) => {
              'id': item.food.id,
              'name': item.food.name,
              'quantity': item.quantity,
              'price': item.food.price,
            },
          )
          .toList(),
      'subtotal': subtotal,
      'shippingFee': shippingFee,
      'voucherDiscount': voucherDiscount,
      'total': totalPrice,
      'address': address,
      'note': note,
    };

    return _runOrderAction<OrderRecord?>(() async {
      final response = await http.post(
        ApiEndpoints.uri(ApiEndpoints.orders),
        headers: _providerJsonHeaders(token),
        body: jsonEncode(payload),
      );
      final data = _providerJsonMap(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final order = OrderRecord.fromJson(
          Map<String, dynamic>.from(data['order']),
        );
        orders.insert(0, order);
        return order;
      }

      error = _providerMessage(data, 'Đặt món thất bại');
      return null;
    });
  }

  Future<bool> cancelOrder(OrderRecord order, String? token) async {
    return _runOrderAction<bool>(() async {
      await http.patch(
        ApiEndpoints.uri('${ApiEndpoints.orders}/${order.code}/cancel'),
        headers: _providerJsonHeaders(token),
      );
      order.status = 'cancelled';
      return true;
    });
  }

  Future<bool> updateOrderStatus(
    OrderRecord order,
    String status,
    String? token,
  ) async {
    return _runOrderAction<bool>(() async {
      final response = await http.patch(
        ApiEndpoints.uri('${ApiEndpoints.adminOrders}/${order.code}/status'),
        headers: _providerJsonHeaders(token),
        body: jsonEncode({'status': status}),
      );
      final data = _providerJsonMap(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final updated = OrderRecord.fromJson(
          Map<String, dynamic>.from(data['order']),
        );
        final index = orders.indexWhere((item) => item.code == order.code);
        if (index >= 0) orders[index] = updated;
        return true;
      }

      error = _providerMessage(data, 'Cập nhật trạng thái thất bại');
      return false;
    });
  }

  Future<bool> deleteOrder(OrderRecord order, String? token) async {
    return _runOrderAction<bool>(() async {
      await http.delete(
        ApiEndpoints.uri('${ApiEndpoints.orders}/${order.code}'),
        headers: _providerAuthHeaders(token),
      );
      orders.removeWhere((item) => item.code == order.code);
      return true;
    });
  }

  Future<T> _runOrderAction<T>(Future<T> Function() action) async {
    actionLoading = true;
    error = null;
    notifyListeners();

    try {
      return await action();
    } catch (err) {
      error = 'Không gọi được API đơn hàng: $err';
      if (T == bool) return false as T;
      return null as T;
    } finally {
      actionLoading = false;
      notifyListeners();
    }
  }
}
