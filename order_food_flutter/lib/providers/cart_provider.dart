part of '../main.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> items = [];
  bool loading = false;
  String? error;

  int get totalItems => items.fold(0, (total, item) => total + item.quantity);
  int get subtotal =>
      items.fold(0, (total, item) => total + item.food.price * item.quantity);
  int get shippingFee => items.isEmpty ? 0 : (subtotal >= 200000 ? 0 : 15000);
  int get voucherDiscount => subtotal >= 150000 ? 20000 : 0;
  int get totalPrice => subtotal + shippingFee - voucherDiscount;

  Future<void> loadLocalCart(List<Food> foods) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('cartItems');
    if (raw == null || foods.isEmpty) return;

    try {
      restoreFromItems(_providerJsonList(raw), foods);
    } catch (_) {
      await prefs.remove('cartItems');
    }
  }

  Future<void> fetchCart({
    required String userKey,
    required List<Food> foods,
    String? token,
  }) async {
    if (userKey.isEmpty || foods.isEmpty) return;

    loading = true;
    error = null;
    notifyListeners();

    try {
      final uri = ApiEndpoints.uri(
        '${ApiEndpoints.cart}?userId=${Uri.encodeComponent(userKey)}',
      );
      final response = await http.get(
        uri,
        headers: _providerAuthHeaders(token),
      );
      if (response.statusCode == 200) {
        final data = _providerJsonMap(response.body);
        restoreFromItems((data['items'] as List?) ?? const [], foods);
      }
    } catch (err) {
      error = 'Không tải được giỏ hàng: $err';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void restoreFromItems(List data, List<Food> foods) {
    final restored = <CartItem>[];
    for (final item in data) {
      final itemData = Map<String, dynamic>.from(item as Map);
      final foodId = _asInt(itemData['foodId']);
      final matches = foods.where((food) => food.id == foodId);
      if (matches.isNotEmpty) {
        restored.add(
          CartItem(
            food: matches.first,
            quantity: _asInt(itemData['quantity'], fallback: 1),
          ),
        );
      }
    }
    items = restored;
    notifyListeners();
  }

  Future<void> saveCart({required String? userKey, String? token}) async {
    final prefs = await SharedPreferences.getInstance();
    final serializedItems = items.map((item) => item.toJson()).toList();
    await prefs.setString('cartItems', jsonEncode(serializedItems));

    if (userKey == null || userKey.isEmpty) return;

    try {
      await http.put(
        ApiEndpoints.uri(ApiEndpoints.cart),
        headers: _providerJsonHeaders(token),
        body: jsonEncode({'userId': userKey, 'items': serializedItems}),
      );
    } catch (_) {}
  }

  Future<void> addToCart(Food food, {String? userKey, String? token}) async {
    final index = items.indexWhere((item) => item.food.id == food.id);
    if (index >= 0) {
      items[index].quantity++;
    } else {
      items.add(CartItem(food: food));
    }
    notifyListeners();
    await saveCart(userKey: userKey, token: token);
  }

  Future<void> changeQuantity(
    Food food,
    int delta, {
    String? userKey,
    String? token,
  }) async {
    final index = items.indexWhere((item) => item.food.id == food.id);
    if (index < 0) return;

    items[index].quantity += delta;
    if (items[index].quantity <= 0) items.removeAt(index);
    notifyListeners();
    await saveCart(userKey: userKey, token: token);
  }

  Future<void> clear({String? userKey, String? token}) async {
    items = [];
    notifyListeners();
    await saveCart(userKey: userKey, token: token);
  }
}
