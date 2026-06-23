// ignore_for_file: library_private_types_in_public_api, invalid_use_of_protected_member

part of '../../main.dart';

extension AdminOrderDetailScreenBuilder on _HomePageState {
  Widget _buildAdminOrderCard(OrderRecord order) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Đơn ${order.code}',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              const Spacer(),
              _StatusPill(
                text: orderStatusLabel(order.status),
                color: orderStatusColor(order.status),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            order.userEmail.isEmpty
                ? 'Khách: ${order.userId}'
                : 'Khách: ${order.userEmail}',
          ),
          const SizedBox(height: 6),
          Text(
            order.items
                .map((item) => '${item.food.name} x${item.quantity}')
                .join(', '),
          ),
          const SizedBox(height: 6),
          Text('Địa chỉ: ${order.address}'),
          const SizedBox(height: 6),
          Text(
            'Tạo lúc: ${formatLocalDateTime(_parseBigQueryTimestamp(order.createdAt))}',
          ),
          const SizedBox(height: 8),
          Text(
            formatMoney(order.total),
            style: const TextStyle(
              color: Color(0xffff5a1f),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          _buildAdminOrderActions(order),
        ],
      ),
    );
  }
}
