import 'package:flutter/material.dart';

import '../models/delivery_order_model.dart';
import '../models/shipper_user.dart';
import '../services/shipper_service.dart';
import '../widgets/delivery_order_card.dart';
import '../widgets/order_list_scaffold.dart';
import 'delivery_order_detail_screen.dart';

class MyDeliveryOrdersScreen extends StatefulWidget {
  const MyDeliveryOrdersScreen({super.key, required this.shipper});

  final ShipperUser shipper;

  @override
  State<MyDeliveryOrdersScreen> createState() => _MyDeliveryOrdersScreenState();
}

class _MyDeliveryOrdersScreenState extends State<MyDeliveryOrdersScreen> {
  final service = ShipperService();
  late Future<List<DeliveryOrderModel>> ordersFuture;
  String? actionOrderId;

  @override
  void initState() {
    super.initState();
    ordersFuture = service.getMyOrders(widget.shipper.id);
  }

  void _refresh() {
    setState(() {
      ordersFuture = service.getMyOrders(widget.shipper.id);
    });
  }

  Future<void> _startDelivering(DeliveryOrderModel order) async {
    await _runAction(
      order,
      () => service.startDelivering(
        orderId: order.orderId,
        shipperId: widget.shipper.id,
      ),
      'Đã bắt đầu giao',
    );
  }

  Future<void> _complete(DeliveryOrderModel order) async {
    await _runAction(
      order,
      () => service.completeOrder(
        orderId: order.orderId,
        shipperId: widget.shipper.id,
      ),
      'Đã giao thành công',
    );
  }

  Future<void> _runAction(
    DeliveryOrderModel order,
    Future<DeliveryOrderModel> Function() action,
    String message,
  ) async {
    setState(() => actionOrderId = order.orderId);
    try {
      await action();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      _refresh();
    } catch (err) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(err.toString())));
    } finally {
      if (mounted) setState(() => actionOrderId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OrderListScaffold(
      title: 'Đơn giao của tôi',
      onRefresh: _refresh,
      future: ordersFuture,
      emptyText: 'Bạn chưa nhận đơn nào.',
      itemBuilder: (order) {
        final action = _actionFor(order);
        return DeliveryOrderCard(
          order: order,
          primaryLabel: action?.label,
          primaryIcon: action?.icon,
          loading: actionOrderId == order.orderId,
          onPrimary: action?.onTap,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => DeliveryOrderDetailScreen(order: order),
              ),
            );
          },
        );
      },
    );
  }

  ({String label, IconData icon, VoidCallback onTap})? _actionFor(
    DeliveryOrderModel order,
  ) {
    if (order.status == 'assigned_shipper') {
      return (
        label: 'Bắt đầu giao',
        icon: Icons.local_shipping_outlined,
        onTap: () => _startDelivering(order),
      );
    }

    if (order.status == 'delivering') {
      return (
        label: 'Giao thành công',
        icon: Icons.task_alt,
        onTap: () => _complete(order),
      );
    }

    return null;
  }
}
