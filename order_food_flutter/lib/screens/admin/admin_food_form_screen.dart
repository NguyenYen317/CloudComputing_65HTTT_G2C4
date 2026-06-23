// ignore_for_file: library_private_types_in_public_api, invalid_use_of_protected_member

part of '../../main.dart';

extension AdminFoodFormScreenBuilder on _HomePageState {
  Future<void> showFoodEditor({Food? food}) async {
    final nameController = TextEditingController(text: food?.name ?? '');
    final priceController = TextEditingController(
      text: food == null ? '' : food.price.toString(),
    );
    final originalPriceController = TextEditingController(
      text: food == null ? '' : food.originalPrice.toString(),
    );
    final categoryController = TextEditingController(
      text: food?.category ?? 'Món ngon',
    );
    final restaurantController = TextEditingController(
      text: food?.restaurant ?? 'Order Food Kitchen',
    );
    final descriptionController = TextEditingController(
      text: food?.description ?? '',
    );
    final imageController = TextEditingController(text: food?.image ?? '');
    final discountController = TextEditingController(
      text: food == null ? '0' : food.discountPercent.toString(),
    );
    final tagsController = TextEditingController(
      text: food?.tags.join(', ') ?? 'Giao nhanh',
    );

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(food == null ? 'Thêm món ăn' : 'Sửa món ăn'),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _AuthField(
                    controller: nameController,
                    label: 'Tên món',
                    icon: Icons.restaurant_menu_outlined,
                  ),
                  const SizedBox(height: 10),
                  _AuthField(
                    controller: priceController,
                    label: 'Giá bán',
                    icon: Icons.payments_outlined,
                  ),
                  const SizedBox(height: 10),
                  _AuthField(
                    controller: originalPriceController,
                    label: 'Giá gốc',
                    icon: Icons.sell_outlined,
                  ),
                  const SizedBox(height: 10),
                  _AuthField(
                    controller: categoryController,
                    label: 'Danh mục',
                    icon: Icons.category_outlined,
                  ),
                  const SizedBox(height: 10),
                  _AuthField(
                    controller: restaurantController,
                    label: 'Tên quán',
                    icon: Icons.storefront_outlined,
                  ),
                  const SizedBox(height: 10),
                  _AuthField(
                    controller: descriptionController,
                    label: 'Mô tả',
                    icon: Icons.notes_outlined,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _AuthField(
                          controller: imageController,
                          label: 'URL ảnh',
                          icon: Icons.image_outlined,
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final url = await uploadFoodImage();
                          if (url != null) {
                            setDialogState(() => imageController.text = url);
                          }
                        },
                        icon: const Icon(Icons.cloud_upload_outlined),
                        label: const Text('Upload'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _AuthField(
                    controller: discountController,
                    label: 'Giảm giá %',
                    icon: Icons.percent_outlined,
                  ),
                  const SizedBox(height: 10),
                  _AuthField(
                    controller: tagsController,
                    label: 'Tags, cách nhau bởi dấu phẩy',
                    icon: Icons.local_offer_outlined,
                  ),
                  if (imageController.text.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _FoodImage(url: imageController.text, size: 96),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () async {
                final body = {
                  'name': nameController.text.trim(),
                  'price': _asInt(priceController.text),
                  'originalPrice': _asInt(
                    originalPriceController.text,
                    fallback: _asInt(priceController.text),
                  ),
                  'category': categoryController.text.trim(),
                  'restaurant': restaurantController.text.trim(),
                  'description': descriptionController.text.trim(),
                  'image': imageController.text.trim(),
                  'discountPercent': _asInt(discountController.text),
                  'tags': tagsController.text
                      .split(',')
                      .map((tag) => tag.trim())
                      .where((tag) => tag.isNotEmpty)
                      .toList(),
                };
                final uri = food == null
                    ? Uri.parse('$apiBaseUrl/admin/foods')
                    : Uri.parse('$apiBaseUrl/admin/foods/${food.id}');
                final response = food == null
                    ? await http.post(  // Add food: Nếu food là null, tức là đang tạo mới, thì dùng POST
                        uri,
                        headers: {
                          'Content-Type': 'application/json',
                          if (authToken != null)
                            'Authorization': 'Bearer $authToken',
                        },
                        body: jsonEncode(body),
                      )
                    : await http.patch(  // Edit food: Nếu food không null, tức là đang chỉnh sửa, thì dùng PATCH
                        uri,
                        headers: {
                          'Content-Type': 'application/json',
                          if (authToken != null)
                            'Authorization': 'Bearer $authToken',
                        },
                        body: jsonEncode(body),
                      );
                final data = jsonDecode(response.body) as Map<String, dynamic>;
                showMessage(
                  data['message']?.toString() ??
                      (food == null ? 'Đã thêm món' : 'Đã cập nhật món'),
                );
                if (context.mounted) {
                  Navigator.pop( 
                    context,
                    response.statusCode >= 200 && response.statusCode < 300,
                  );
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );

    nameController.dispose();
    priceController.dispose();
    originalPriceController.dispose();
    categoryController.dispose();
    restaurantController.dispose();
    descriptionController.dispose();
    imageController.dispose();
    discountController.dispose();
    tagsController.dispose();

    if (saved == true) await fetchFoods();
  }
}
