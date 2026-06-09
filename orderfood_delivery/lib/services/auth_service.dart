import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/shipper_user.dart';
import 'api_service.dart';

class AuthService {
  Future<ShipperUser> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      ApiService.uri('/auth/login'),
      headers: ApiService.jsonHeaders(),
      body: jsonEncode({'email': email, 'password': password}),
    );

    ApiService.ensureSuccess(response);
    final data = Map<String, dynamic>.from(ApiService.decode(response) as Map);
    final user = ShipperUser.fromLoginJson(data);

    if (user.role != 'shipper') {
      throw const ApiException('Tài khoản này không phải shipper');
    }

    return user;
  }
}
