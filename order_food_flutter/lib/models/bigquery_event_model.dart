part of '../main.dart';

class BigQueryOrderEvent {
  const BigQueryOrderEvent({
    required this.eventType,
    required this.orderId,
    required this.userEmail,
    required this.status,
    required this.totalAmount,
    required this.itemCount,
    required this.eventAt,
  });

  final String eventType;
  final String orderId;
  final String userEmail;
  final String status;
  final int totalAmount;
  final int itemCount;
  final DateTime? eventAt;

  factory BigQueryOrderEvent.fromJson(dynamic json) {
    final data = Map<String, dynamic>.from(json as Map);
    return BigQueryOrderEvent(
      eventType: (data['eventType'] ?? '').toString(),
      orderId: (data['orderId'] ?? '').toString(),
      userEmail: (data['userEmail'] ?? '').toString(),
      status: (data['status'] ?? '').toString(),
      totalAmount: _asInt(data['totalAmount']),
      itemCount: _asInt(data['itemCount']),
      eventAt: _parseBigQueryTimestamp(data['eventAt']),
    );
  }
}
