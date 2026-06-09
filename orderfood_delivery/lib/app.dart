import 'package:flutter/material.dart';

import 'models/shipper_user.dart';
import 'screens/login_screen.dart';
import 'screens/shipper_home_screen.dart';

class DeliveryApp extends StatefulWidget {
  const DeliveryApp({super.key});

  @override
  State<DeliveryApp> createState() => _DeliveryAppState();
}

class _DeliveryAppState extends State<DeliveryApp> {
  ShipperUser? shipper;

  void _handleLogin(ShipperUser value) {
    setState(() => shipper = value);
  }

  void _handleLogout() {
    setState(() => shipper = null);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Order Food Delivery',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff0f766e),
          primary: const Color(0xff0f766e),
        ),
        scaffoldBackgroundColor: const Color(0xfff7f5f2),
        useMaterial3: true,
      ),
      home: shipper == null
          ? LoginScreen(onLoggedIn: _handleLogin)
          : ShipperHomeScreen(shipper: shipper!, onLogout: _handleLogout),
    );
  }
}
