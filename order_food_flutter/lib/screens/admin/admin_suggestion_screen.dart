// ignore_for_file: library_private_types_in_public_api, invalid_use_of_protected_member

part of '../../main.dart';

extension AdminSuggestionScreenBuilder on _HomePageState {
  Widget _buildAdminSuggestions() {
    final suggestions = mlPredictions?.suggestions ?? const [];
    if (suggestions.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: suggestions
            .map(
              (message) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _SuggestionTile(
                  title: 'Đề xuất từ Machine Learning',
                  message: message,
                ),
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

    final bestSellers = <String, int>{};
    for (final order in orders.where(isActiveOrder)) {
      for (final item in order.items) {
        bestSellers[item.food.name] =
            (bestSellers[item.food.name] ?? 0) + item.quantity;
      }
    }
    final top = bestSellers.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SuggestionTile(
          title: 'Khuyến mãi',
          message: top.isEmpty
              ? 'Chưa đủ dữ liệu. Có thể tạo voucher giảm giá cho đơn đầu tiên.'
              : 'Tạo combo hoặc voucher cho món ${top.first.key} vì đang bán tốt.',
        ),
        const SizedBox(height: 10),
        _SuggestionTile(
          title: 'Nhập hàng',
          message: top.isEmpty
              ? 'Theo dõi thêm đơn hàng để dự đoán nguyên liệu cần nhập.'
              : 'Ưu tiên chuẩn bị nguyên liệu cho ${top.take(3).map((e) => e.key).join(', ')}.',
        ),
      ],
    );
  }
}
