import 'package:flutter/material.dart';

import '../models/delivery_order_model.dart';

class OrderListScaffold extends StatelessWidget {
  const OrderListScaffold({
    super.key,
    required this.title,
    required this.future,
    required this.emptyText,
    required this.itemBuilder,
    required this.onRefresh,
  });

  final String title;
  final Future<List<DeliveryOrderModel>> future;
  final String emptyText;
  final Widget Function(DeliveryOrderModel order) itemBuilder;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Tải lại',
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<DeliveryOrderModel>>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError) {
                return _Notice(
                  icon: Icons.error_outline,
                  message: snapshot.error.toString(),
                );
              }

              final orders = snapshot.data ?? const [];
              if (orders.isEmpty) {
                return _Notice(icon: Icons.inbox_outlined, message: emptyText);
              }

              return Column(
                children: orders
                    .map(
                      (order) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: itemBuilder(order),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Icon(icon, color: Colors.black45),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}
