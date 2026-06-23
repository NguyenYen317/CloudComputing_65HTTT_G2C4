// ignore_for_file: library_private_types_in_public_api, invalid_use_of_protected_member

part of '../main.dart';

extension CartServiceMethods on _HomePageState {
  Future<void> saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final items = cart.map((item) => item.toJson()).toList();
    await prefs.setString('cartItems', jsonEncode(items));

    final userKey = syncUserKey;
    if (userKey == null || userKey.isEmpty) return;

    try {
      await http.put(
        Uri.parse('$apiBaseUrl/cart'),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({'userId': userKey, 'items': items}),
      );
    } catch (_) {}
  }

  void restoreCartFromStorage() {
    final cartRaw = storedCartRaw;
    if (foods.isEmpty || cartRaw == null) return;

    try {
      final List data = jsonDecode(cartRaw);
      restoreCartFromItems(data);
    } catch (_) {
      storedCartRaw = null;
    }
  }

  Future<void> fetchCart() async {
    final userKey = syncUserKey;
    if (userKey == null || userKey.isEmpty || foods.isEmpty) return;

    try {
      final uri = Uri.parse(
        '$apiBaseUrl/cart?userId=${Uri.encodeComponent(userKey)}',
      );
      final response = await http.get(
        uri,
        headers: {if (authToken != null) 'Authorization': 'Bearer $authToken'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        restoreCartFromItems((data['items'] as List?) ?? const []);
      }
    } catch (_) {}
  }

  void restoreCartFromItems(List data) {
    final restored = <CartItem>[];
    for (final item in data) {
      final foodId = _asInt(item['foodId']);
      final matches = foods.where((food) => food.id == foodId);
      if (matches.isNotEmpty) {
        restored.add(
          CartItem(
            food: matches.first,
            quantity: _asInt(item['quantity'], fallback: 1),
          ),
        );
      }
    }
    setState(() => cart = restored);
  }

  int get totalItems => cart.fold(0, (total, item) => total + item.quantity);
  int get subtotal =>
      cart.fold(0, (total, item) => total + item.food.price * item.quantity);
  int get shippingFee => cart.isEmpty ? 0 : (subtotal >= 200000 ? 0 : 15000);
  int get voucherDiscount => subtotal >= 150000 ? 20000 : 0;
  int get totalPrice => subtotal + shippingFee - voucherDiscount;
  String? get syncUserKey => currentUser?.email.trim().toLowerCase();

  void addToCart(Food food) {
    setState(() {
      final index = cart.indexWhere((item) => item.food.id == food.id);
      if (index >= 0) {
        cart[index].quantity++;
      } else {
        cart.add(CartItem(food: food));
      }
    });
    saveCart();
    showMessage('${food.name} đã thêm vào giỏ hàng');
  }

  void changeQuantity(Food food, int delta) {
    setState(() {
      final index = cart.indexWhere((item) => item.food.id == food.id);
      if (index < 0) return;
      cart[index].quantity += delta;
      if (cart[index].quantity <= 0) cart.removeAt(index);
    });
    saveCart();
  }

  void openCustomerTab(int index) {
    setState(() => tabIndex = index);
    if (index == 1 && currentUser != null) {
      fetchCart();
    }
  }
}
