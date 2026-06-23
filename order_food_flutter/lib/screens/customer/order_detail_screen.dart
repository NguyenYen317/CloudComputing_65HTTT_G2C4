// ignore_for_file: library_private_types_in_public_api, invalid_use_of_protected_member

part of '../../main.dart';

extension OrderDetailScreenBuilder on _HomePageState {
  Widget _buildCustomerOrderCard(OrderRecord order) {
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
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              _StatusPill(
                text: orderStatusLabel(order.status),
                color: orderStatusColor(order.status),
              ),
              const SizedBox(width: 6),
              IconButton(
                tooltip: 'Xóa đơn',
                onPressed: () => deleteOrder(order),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            order.items
                .map((item) => '${item.food.name} x${item.quantity}')
                .join(', '),
          ),
          const SizedBox(height: 8),
          Text(order.address, style: TextStyle(color: Colors.grey.shade700)),
          const SizedBox(height: 8),
          Text(
            formatMoney(order.total),
            style: const TextStyle(
              color: Color(0xffff5a1f),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Trạng thái đơn hàng được cập nhật bởi cửa hàng.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          if (normalizeOrderStatus(order.status) ==
                  OrderStatusModel.completed &&
              !ratedOrders.contains(order.code)) ...[
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        FeedbackPage(order: order, user: currentUser!),
                  ),
                );
              },
              icon: const Icon(Icons.star_border),
              label: const Text('Đánh giá'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.blueAccent.shade700),
                foregroundColor: Colors.blueAccent.shade700,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
