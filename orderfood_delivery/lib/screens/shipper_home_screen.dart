import 'package:flutter/material.dart';

import '../models/shipper_user.dart';
import 'available_orders_screen.dart';
import 'my_delivery_orders_screen.dart';

class ShipperHomeScreen extends StatefulWidget {
  const ShipperHomeScreen({
    super.key,
    required this.shipper,
    required this.onLogout,
  });

  final ShipperUser shipper;
  final VoidCallback onLogout;

  @override
  State<ShipperHomeScreen> createState() => _ShipperHomeScreenState();
}

class _ShipperHomeScreenState extends State<ShipperHomeScreen> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      AvailableOrdersScreen(shipper: widget.shipper),
      MyDeliveryOrdersScreen(shipper: widget.shipper),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(child: Text(widget.shipper.email)),
          ),
          IconButton(
            tooltip: 'Đăng xuất',
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Đơn chờ giao',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_shipping_outlined),
            selectedIcon: Icon(Icons.local_shipping),
            label: 'Đơn của tôi',
          ),
        ],
      ),
    );
  }
}
