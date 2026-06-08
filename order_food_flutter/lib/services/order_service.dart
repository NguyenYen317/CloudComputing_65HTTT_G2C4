// ignore_for_file: library_private_types_in_public_api, invalid_use_of_protected_member

part of '../main.dart';

extension OrderServiceMethods on _HomePageState {
  Future<void> fetchOrders({bool all = false}) async {
    final userKey = syncUserKey;
    if (!all && (userKey == null || userKey.isEmpty)) return;

    try {
      final uri = all
          ? Uri.parse('$apiBaseUrl/orders')
          : Uri.parse(
              '$apiBaseUrl/orders?userId=${Uri.encodeComponent(userKey!)}',
            );
      final response = await http.get(
        uri,
        headers: {if (authToken != null) 'Authorization': 'Bearer $authToken'},
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          orders = data
              .map(
                (item) => OrderRecord.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList();
        });
      }
    } catch (_) {}
  }

  Future<void> orderFood() async {
    final user = currentUser;
    final userKey = syncUserKey;
    if (user == null || userKey == null || userKey.isEmpty || cart.isEmpty) {
      return;
    }

    final address = _addressController.text.trim();
    if (address.isEmpty) {
      showMessage('Vui lòng nhập địa chỉ giao hàng');
      return;
    }

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
      'note': _noteController.text.trim(),
    };

    OrderRecord? serverOrder;
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/orders'),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(payload),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        serverOrder = OrderRecord.fromJson(
          Map<String, dynamic>.from(data['order']),
        );
      }
    } catch (_) {}

    setState(() {
      orders.insert(
        0,
        serverOrder ??
            OrderRecord(
              code:
                  'OD${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
              items: cart
                  .map(
                    (item) =>
                        CartItem(food: item.food, quantity: item.quantity),
                  )
                  .toList(),
              total: totalPrice,
              address: address,
              userId: userKey,
              userEmail: user.email,
              createdAt: DateTime.now().toIso8601String(),
              updatedAt: DateTime.now().toIso8601String(),
            ),
      );
      cart.clear();
      _noteController.clear();
      tabIndex = 2;
    });
    saveCart();
    showMessage('Đặt món thành công');
  }

  Future<void> cancelOrder(OrderRecord order) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy đơn hàng?'),
        content: Text('Bạn muốn hủy đơn ${order.code}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Không'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hủy đơn'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await http.patch(
        Uri.parse('$apiBaseUrl/orders/${order.code}/cancel'),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
      );
    } catch (_) {}

    setState(() => order.status = 'cancelled');
    showMessage('Đã hủy đơn ${order.code}');
  }

  Future<void> updateOrderStatus(OrderRecord order, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('$apiBaseUrl/admin/orders/${order.code}/status'),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({'status': status}),
      );
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final updated = OrderRecord.fromJson(
          Map<String, dynamic>.from(data['order']),
        );
        setState(() {
          final index = orders.indexWhere((item) => item.code == order.code);
          if (index >= 0) orders[index] = updated;
        });
        showMessage(
          data['message']?.toString() ?? 'Cập nhật trạng thái thành công',
        );
      } else {
        showMessage(
          data['message']?.toString() ?? 'Cập nhật trạng thái thất bại',
        );
      }
    } catch (error) {
      showMessage('Không cập nhật được trạng thái đơn hàng: $error');
    }
  }

  Future<void> deleteOrder(OrderRecord order) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa đơn hàng?'),
        content: Text('Thông tin đơn ${order.code} sẽ bị xóa khỏi danh sách.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Không'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await http.delete(
        Uri.parse('$apiBaseUrl/orders/${order.code}'),
        headers: {if (authToken != null) 'Authorization': 'Bearer $authToken'},
      );
    } catch (_) {}

    setState(() => orders.remove(order));
    showMessage('Đã xóa đơn ${order.code}');
  }
}
