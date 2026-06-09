import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/delivery_order_model.dart';
import '../models/shipper_user.dart';
import 'api_service.dart';

class ShipperService {
  Future<List<DeliveryOrderModel>> getAvailableOrders() async {
    final response = await http.get(
      ApiService.uri('/shipper/orders/available'),
    );
    ApiService.ensureSuccess(response);
    return _ordersFromResponse(response);
  }

  Future<List<DeliveryOrderModel>> getMyOrders(String shipperId) async {
    final response = await http.get(
      ApiService.uri('/shipper/orders/my-orders/$shipperId'),
    );
    ApiService.ensureSuccess(response);
    return _ordersFromResponse(response);
  }

  Future<DeliveryOrderModel> acceptOrder({
    required String orderId,
    required ShipperUser shipper,
  }) {
    return _patchOrder('/shipper/orders/$orderId/accept', {
      'shipperId': shipper.id,
      'shipperEmail': shipper.email,
      'shipperName': shipper.name,
    });
  }

  Future<DeliveryOrderModel> startDelivering({
    required String orderId,
    required String shipperId,
  }) {
    return _patchOrder('/shipper/orders/$orderId/delivering', {
      'shipperId': shipperId,
    });
  }

  Future<DeliveryOrderModel> completeOrder({
    required String orderId,
    required String shipperId,
  }) {
    return _patchOrder('/shipper/orders/$orderId/completed', {
      'shipperId': shipperId,
    });
  }

  Future<DeliveryOrderModel> _patchOrder(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final response = await http.patch(
      ApiService.uri(endpoint),
      headers: ApiService.jsonHeaders(),
      body: jsonEncode(body),
    );
    ApiService.ensureSuccess(response);
    final data = Map<String, dynamic>.from(ApiService.decode(response) as Map);
    return DeliveryOrderModel.fromJson(
      Map<String, dynamic>.from(data['order'] as Map? ?? {}),
    );
  }

  List<DeliveryOrderModel> _ordersFromResponse(http.Response response) {
    final data = ApiService.decode(response);
    final list = data is List ? data : const [];
    return list
        .map(
          (item) => DeliveryOrderModel.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }
}
