import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      'waiting_shipper' => 'Chờ shipper',
      'assigned_shipper' => 'Đã nhận đơn',
      'delivering' => 'Đang giao',
      'completed' => 'Hoàn thành',
      'cancelled' => 'Đã hủy',
      _ => status,
    };

    final color = switch (status) {
      'waiting_shipper' => Colors.orange.shade700,
      'assigned_shipper' => Colors.indigo.shade700,
      'delivering' => Colors.blue.shade700,
      'completed' => Colors.green.shade700,
      'cancelled' => Colors.grey.shade700,
      _ => Colors.teal.shade700,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}
