import 'package:flutter/material.dart';

import '../models/delivery_order_model.dart';
import 'status_badge.dart';

class DeliveryOrderCard extends StatelessWidget {
  const DeliveryOrderCard({
    super.key,
    required this.order,
    required this.onTap,
    this.primaryLabel,
    this.primaryIcon,
    this.onPrimary,
    this.loading = false,
  });

  final DeliveryOrderModel order;
  final VoidCallback onTap;
  final String? primaryLabel;
  final IconData? primaryIcon;
  final VoidCallback? onPrimary;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Đơn ${order.orderId}',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  StatusBadge(status: order.status),
                ],
              ),
              const SizedBox(height: 10),
              _InfoLine(icon: Icons.person_outline, text: order.customerName),
              _InfoLine(icon: Icons.location_on_outlined, text: order.address),
              if (order.phone.isNotEmpty)
                _InfoLine(icon: Icons.phone_outlined, text: order.phone),
              const SizedBox(height: 10),
              Text(
                order.itemSummary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _formatMoney(order.totalAmount),
                      style: const TextStyle(
                        color: Color(0xff0f766e),
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  if (primaryLabel != null && onPrimary != null)
                    FilledButton.icon(
                      onPressed: loading ? null : onPrimary,
                      icon: loading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(primaryIcon ?? Icons.check),
                      label: Text(primaryLabel!),
                    ),
                ],
              ),
            ],
          ),
        ),
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
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 17, color: Colors.black54),
          const SizedBox(width: 6),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
