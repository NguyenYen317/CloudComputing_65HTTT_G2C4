// ignore_for_file: library_private_types_in_public_api, invalid_use_of_protected_member

part of '../../main.dart';

extension AdminBestSellingScreenBuilder on _HomePageState {
  Widget _buildAdminBestSellers() {
    final predictions = mlPredictions?.bestSellingFoods ?? const [];
    if (predictions.isNotEmpty) {
      return Column(
        children: predictions
            .map(
              (food) => ListTile(
                leading: const Icon(
                  Icons.trending_up_outlined,
                  color: Color(0xffff5a1f),
                ),
                title: Text(food.foodName),
                subtitle: Text('Mức nhu cầu: ${food.level}'),
                trailing: Text('Dự đoán ${food.predictedQuantity}'),
              ),
            )
            .toList(),
      );
    }

    if (mlLoading) {
      return const _AdminNotice(
        message: 'Đang tải dữ liệu Machine Learning...',
      );
    }
    if (mlError != null) return _AdminNotice(message: mlError!);

    final counts = <String, int>{};
    for (final order in orders.where(isActiveOrder)) {
      for (final item in order.items) {
        counts[item.food.name] = (counts[item.food.name] ?? 0) + item.quantity;
      }
    }
    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (entries.isEmpty) return const Text('Chưa có dữ liệu bán hàng.');
    return Column(
      children: entries
          .take(10)
          .map(
            (entry) => ListTile(
              title: Text(entry.key),
              trailing: Text('Đã bán ${entry.value}'),
            ),
          )
          .toList(),
    );
  }
}
