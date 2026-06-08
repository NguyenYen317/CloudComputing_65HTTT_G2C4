// ignore_for_file: library_private_types_in_public_api, invalid_use_of_protected_member

part of '../../main.dart';

extension AdminFoodScreenBuilder on _HomePageState {
  Widget _buildAdminFoods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: () => showFoodEditor(),
            icon: const Icon(Icons.add),
            label: const Text('Thêm món'),
          ),
        ),
        const SizedBox(height: 10),
        ...foods.map(
          (food) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black12),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: _FoodImage(url: food.image, size: 54),
              title: Text(
                food.name,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(
                '${food.category} • ${food.restaurant}\n${food.description}',
              ),
              trailing: Wrap(
                spacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    formatMoney(food.price),
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  IconButton.outlined(
                    tooltip: 'Sửa món',
                    onPressed: () => showFoodEditor(food: food),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton.outlined(
                    tooltip: 'Ẩn món',
                    onPressed: () => deleteFood(food),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
