import '../config/environment.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static const foods = '/foods';
  static const orders = '/orders';
  static const cart = '/cart';
  static const users = '/users';

  static const login = '/auth/login';
  static const register = '/auth/register';
  static const googleLogin = '/auth/google';

  static const adminFoods = '/admin/foods';
  static const adminUsers = '/admin/users';
  static const adminOrders = '/admin/orders';
  static const adminMlPredictions = '/admin/ml-predictions';
  static const adminBigQueryEvents = '/admin/bigquery-events';
  static const saveFcmToken = '/notifications/save-token';

  static Uri uri(String path) => Uri.parse('${Environment.apiBaseUrl}$path');
}

const String apiBaseUrl = Environment.apiBaseUrl;
