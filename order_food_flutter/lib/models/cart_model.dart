part of '../main.dart';

class CartModel {
  const CartModel({required this.items});

  final List<CartItem> items;

  int get totalItems => items.fold(0, (total, item) => total + item.quantity);
  int get subtotal =>
      items.fold(0, (total, item) => total + item.food.price * item.quantity);
}
