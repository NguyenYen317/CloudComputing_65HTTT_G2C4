part of '../main.dart';

class CartItem {
  CartItem({required this.food, this.quantity = 1});

  final Food food;
  int quantity;

  Map<String, dynamic> toJson() => {'foodId': food.id, 'quantity': quantity};
}
