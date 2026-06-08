part of '../main.dart';

class FoodProvider extends ChangeNotifier {
  List<Food> foods = [];
  bool loading = false;
  String? error;
  String selectedCategory = 'Tất cả';
  String query = '';

  List<String> get categories {
    final values = foods.map((food) => food.category).toSet().toList()..sort();
    return ['Tất cả', ...values];
  }

  List<Food> get filteredFoods {
    final normalizedQuery = query.trim().toLowerCase();
    return foods.where((food) {
      final matchCategory =
          selectedCategory == 'Tất cả' || food.category == selectedCategory;
      final matchQuery =
          normalizedQuery.isEmpty ||
          food.name.toLowerCase().contains(normalizedQuery) ||
          food.restaurant.toLowerCase().contains(normalizedQuery) ||
          food.category.toLowerCase().contains(normalizedQuery);
      return matchCategory && matchQuery;
    }).toList();
  }

  Future<void> fetchFoods({bool includeInactive = false}) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final uri = includeInactive
          ? ApiEndpoints.uri('${ApiEndpoints.foods}?includeInactive=true')
          : ApiEndpoints.uri(ApiEndpoints.foods);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        foods = _providerJsonList(response.body).map(Food.fromJson).toList();
      } else {
        error = 'Không tải được danh sách món ăn';
      }
    } catch (err) {
      foods = demoFoods;
      error = 'Không kết nối được API món ăn: $err';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void setQuery(String value) {
    query = value;
    notifyListeners();
  }

  void setCategory(String value) {
    selectedCategory = value;
    notifyListeners();
  }

  Future<bool> saveFood({
    required Map<String, dynamic> payload,
    required String? token,
    int? foodId,
  }) async {
    final isEdit = foodId != null;
    final response = isEdit
        ? await http.patch(
            ApiEndpoints.uri('${ApiEndpoints.adminFoods}/$foodId'),
            headers: _providerJsonHeaders(token),
            body: jsonEncode(payload),
          )
        : await http.post(
            ApiEndpoints.uri(ApiEndpoints.adminFoods),
            headers: _providerJsonHeaders(token),
            body: jsonEncode(payload),
          );

    final data = _providerJsonMap(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      await fetchFoods(includeInactive: true);
      return true;
    }

    error = _providerMessage(data, 'Lưu món ăn thất bại');
    notifyListeners();
    return false;
  }

  Future<bool> hideFood(Food food, String? token) async {
    final response = await http.delete(
      ApiEndpoints.uri('${ApiEndpoints.adminFoods}/${food.id}'),
      headers: _providerAuthHeaders(token),
    );
    final data = _providerJsonMap(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      await fetchFoods(includeInactive: true);
      return true;
    }

    error = _providerMessage(data, 'Ẩn món ăn thất bại');
    notifyListeners();
    return false;
  }
}
