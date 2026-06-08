// ignore_for_file: library_private_types_in_public_api, invalid_use_of_protected_member

part of '../main.dart';

extension FoodServiceMethods on _HomePageState {
  Future<void> fetchFoods() async {
    try {
      final response = await http.get(Uri.parse('$apiBaseUrl/foods'));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          foods = data.map((item) => Food.fromJson(item)).toList();
          loading = false;
        });
        restoreCartFromStorage();
        await fetchCart();
        return;
      }
    } catch (_) {}

    setState(() {
      foods = demoFoods;
      loading = false;
    });
    restoreCartFromStorage();
    await fetchCart();
  }

  Future<String?> uploadFoodImage() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      withData: true,
    );
    final file = result?.files.single;
    final bytes = file?.bytes;
    if (file == null || bytes == null) return null;

    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/admin/foods/upload-image'),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'fileName': file.name,
          'contentType': _contentTypeForFileName(file.name),
          'dataBase64': base64Encode(bytes),
        }),
      );
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data['imageUrl']?.toString();
      }
      showMessage(data['message']?.toString() ?? 'Upload ảnh thất bại');
    } catch (error) {
      showMessage('Không upload được ảnh: $error');
    }
    return null;
  }

  Future<void> deleteFood(Food food) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ẩn món ăn?'),
        content: Text('Món ${food.name} sẽ không còn hiển thị với khách.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Không'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ẩn món'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      final response = await http.delete(
        Uri.parse('$apiBaseUrl/admin/foods/${food.id}'),
        headers: {if (authToken != null) 'Authorization': 'Bearer $authToken'},
      );
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      showMessage(data['message']?.toString() ?? 'Đã ẩn món ăn');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        await fetchFoods();
      }
    } catch (error) {
      showMessage('Không ẩn được món ăn: $error');
    }
  }

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
}
