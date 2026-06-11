import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants/api_endpoints.dart';

class FcmService {
  const FcmService();

  Future<void> saveToken({
    required String userId,
    required String fcmToken,
  }) async {
    final response = await http.post(
      ApiEndpoints.uri(ApiEndpoints.saveFcmToken),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'fcmToken': fcmToken}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Không lưu được FCM token: ${response.body}');
    }
  }
}
