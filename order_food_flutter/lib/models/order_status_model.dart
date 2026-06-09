part of '../main.dart';

class OrderStatusModel {
  const OrderStatusModel._();

  static const pending = 'pending';
  static const confirmed = 'confirmed';
  static const preparing = 'preparing';
  static const waitingShipper = 'waiting_shipper';
  static const assignedShipper = 'assigned_shipper';
  static const delivering = 'delivering';
  static const completed = 'completed';
  static const cancelled = 'cancelled';
}
