// ignore_for_file: library_private_types_in_public_api, invalid_use_of_protected_member

part of '../../main.dart';

extension MyOrdersScreenBuilder on _HomePageState {
  Widget _buildOrdersTab() {
    if (orders.isEmpty) {
      return const _EmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'Chưa có đơn hàng',
        message: 'Các đơn đã đặt trong phiên này sẽ xuất hiện ở đây.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildCustomerOrderCard(order);
      },
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemCount: orders.length,
    );
  }
}
