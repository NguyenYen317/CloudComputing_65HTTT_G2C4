import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int maxLines;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    keyboardType: keyboardType,
    obscureText: obscureText,
    maxLines: maxLines,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: icon == null ? null : Icon(icon),
      border: const OutlineInputBorder(),
    ),
  );
}
