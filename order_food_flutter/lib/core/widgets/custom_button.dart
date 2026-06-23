import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Text(text);

    if (icon == null) {
      return FilledButton(
        onPressed: isLoading ? null : onPressed,
        child: child,
      );
    }

    return FilledButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: Icon(icon),
      label: child,
    );
  }
}
