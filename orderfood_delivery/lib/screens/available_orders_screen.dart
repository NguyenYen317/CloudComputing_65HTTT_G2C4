import 'package:flutter/material.dart';

import '../models/delivery_order_model.dart';
import '../models/shipper_user.dart';
import '../services/shipper_service.dart';
import '../widgets/delivery_order_card.dart';
import '../widgets/order_list_scaffold.dart';
import 'delivery_order_detail_screen.dart';

class AvailableOrdersScreen extends StatefulWidget {
  const AvailableOrdersScreen({super.key, required this.shipper});

  final ShipperUser shipper;

  @override
  State<AvailableOrdersScreen> createState() => _AvailableOrdersScreenState();
}

class _AvailableOrdersScreenState extends State<AvailableOrdersScreen> {
  final service = ShipperService();
  late Future<List<DeliveryOrderModel>> ordersFuture;
  String? actionOrderId;

  @override
  void initState() {
    super.initState();
    ordersFuture = service.getAvailableOrders();
  }

  void _refresh() {
    setState(() {
      ordersFuture = service.getAvailableOrders();
    });
  }

  Future<void> _accept(DeliveryOrderModel order) async {
    setState(() => actionOrderId = order.orderId);
    try {
      await service.acceptOrder(
        orderId: order.orderId,
        shipper: widget.shipper,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã nhận đơn')));
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
      title: 'Đơn chờ shipper lấy hàng',
      onRefresh: _refresh,
      future: ordersFuture,
      emptyText: 'Chưa có đơn nào đang chờ shipper.',
      itemBuilder: (order) => DeliveryOrderCard(
        order: order,
        primaryLabel: 'Nhận đơn',
        primaryIcon: Icons.check_circle_outline,
        loading: actionOrderId == order.orderId,
        onPrimary: () => _accept(order),
        onTap: () => _openDetail(context, order),
      ),
    );
  }
}

void _openDetail(BuildContext context, DeliveryOrderModel order) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => DeliveryOrderDetailScreen(order: order)),
  );
}
