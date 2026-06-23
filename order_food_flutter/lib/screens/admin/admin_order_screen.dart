// ignore_for_file: library_private_types_in_public_api, invalid_use_of_protected_member

part of '../../main.dart';

extension AdminOrderScreenBuilder on _HomePageState {
  Widget _buildAdminOrders() {
    return _buildAdminOrdersDetailed();
  }

  Widget _buildAdminOrdersDetailed() {
    if (orders.isEmpty) {
      return const _AdminNotice(message: 'Chưa có đơn hàng.');
    }

    return Column(
      children: orders
          .map(
            (order) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildAdminOrderCard(order),
            ),
          )
          .toList(),
    );
  }

  Widget _buildAdminOrderActions(OrderRecord order) {
    final status = normalizeOrderStatus(order.status);
    final actions = <({String label, String status, IconData icon})>[];

    switch (status) {
      case 'pending':
        actions.add((
          label: 'Xác nhận',
          status: 'confirmed',
          icon: Icons.check,
        ));
        actions.add((label: 'Đã hủy', status: 'cancelled', icon: Icons.cancel));
        break;
      case 'confirmed':
        actions.add((
          label: 'Đang chuẩn bị',
          status: 'preparing',
          icon: Icons.soup_kitchen_outlined,
        ));
        actions.add((label: 'Đã hủy', status: 'cancelled', icon: Icons.cancel));
        break;
      case 'preparing':
        actions.add((
          label: 'Chờ shipper lấy hàng',
          status: 'waiting_shipper',
          icon: Icons.inventory_2_outlined,
        ));
        actions.add((label: 'Đã hủy', status: 'cancelled', icon: Icons.cancel));
        break;
      case 'waiting_shipper':
        actions.add((label: 'Đã hủy', status: 'cancelled', icon: Icons.cancel));
        break;
      default:
        break;
    }

    if (actions.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: actions
          .map(
            (action) => OutlinedButton.icon(
              onPressed: () => updateOrderStatus(order, action.status),
              icon: Icon(action.icon),
              label: Text(action.label),
            ),
          )
          .toList(),
    );
  }
}
