import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ApiService {
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://order-food-api-294162583218.asia-southeast1.run.app',
  );

  static Uri uri(String endpoint) => Uri.parse('$baseUrl$endpoint');

  static Map<String, String> jsonHeaders([String? token]) => {
    'Content-Type': 'application/json',
    if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
  };

  static dynamic decode(http.Response response) {
    if (response.body.isEmpty) return null;
    return jsonDecode(response.body);
  }

  static void ensureSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;

    try {
      final data = decode(response);
      if (data is Map && data['message'] != null) {
        throw ApiException(data['message'].toString());
      }
    } catch (error) {
      if (error is ApiException) rethrow;
    }

    throw ApiException('API lỗi ${response.statusCode}');
  }
}
