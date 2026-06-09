import 'package:flutter/material.dart';

import '../models/delivery_order_model.dart';
import '../widgets/status_badge.dart';

class DeliveryOrderDetailScreen extends StatelessWidget {
  const DeliveryOrderDetailScreen({super.key, required this.order});

  final DeliveryOrderModel order;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Đơn ${order.orderId}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Đơn ${order.orderId}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      StatusBadge(status: order.status),
                    ],
                  ),
                  const Divider(height: 28),
                  _DetailLine(label: 'Khách hàng', value: order.customerName),
                  _DetailLine(label: 'Email', value: order.userEmail),
                  _DetailLine(label: 'Số điện thoại', value: order.phone),
                  _DetailLine(label: 'Địa chỉ', value: order.address),
                  _DetailLine(label: 'Ghi chú', value: order.note),
                  _DetailLine(
                    label: 'Tạo lúc',
                    value: _formatVietnamTime(order.createdAt),
                  ),
                  _DetailLine(
                    label: 'Cập nhật',
                    value: _formatVietnamTime(order.updatedAt),
                  ),
                  const Divider(height: 28),
                  const Text(
                    'Món ăn',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  ...order.items.map(_buildItem),
                  const Divider(height: 28),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Tổng tiền',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Text(
                        _formatMoney(order.totalAmount),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Color(0xff0f766e),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(dynamic item) {
    if (item is! Map) return Text(item.toString());

    final name = item['name'] ?? item['foodName'] ?? 'Món ăn';
    final quantity = item['quantity'] ?? 1;
    final price = NumberParser.toInt(item['price']);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text('$name x$quantity')),
          if (price > 0) Text(_formatMoney(price)),
        ],
      ),
    );
  }

  String _formatMoney(int value) {
    final text = value.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
    return '$textđ';
  }

  String _formatVietnamTime(String value) {
    if (value.trim().isEmpty) return '';

    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;

    final vietnamTime = parsed.toUtc().add(const Duration(hours: 7));
    return '${_twoDigits(vietnamTime.day)}/'
        '${_twoDigits(vietnamTime.month)}/'
        '${vietnamTime.year} '
        '${_twoDigits(vietnamTime.hour)}:'
        '${_twoDigits(vietnamTime.minute)}:'
        '${_twoDigits(vietnamTime.second)}';
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    if (value.trim().isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
