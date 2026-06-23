import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/config/environment.dart';
import '../core/constants/api_endpoints.dart';

class FcmService {
  const FcmService();

  static StreamSubscription<RemoteMessage>? _foregroundSubscription;

  Future<String?> requestToken() async {
    if (kIsWeb && fcmVapidKey.isEmpty) {
      throw Exception(
        'Thiếu FCM_VAPID_KEY. Hãy build lại web với --dart-define=FCM_VAPID_KEY=...',
      );
    }

    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final allowed =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;

    if (!allowed) {
      throw Exception(
        'Chrome chưa cho phép Notification. Hãy bấm Allow hoặc bật lại quyền thông báo trong Site settings.',
      );
    }

    final token = await messaging.getToken(
      vapidKey: kIsWeb ? fcmVapidKey : null,
    );
    if (token == null || token.isEmpty) {
      throw Exception(
        'Firebase không trả về FCM token. Kiểm tra firebase-messaging-sw.js và quyền Notification.',
      );
    }

    return token;
  }

  Future<String?> registerCurrentDevice({required String userId}) async {
    final token = await requestToken();
    if (token == null || token.isEmpty) return null;

    await saveToken(userId: userId, fcmToken: token);
    return token;
  }

  void listenToForegroundMessages(void Function(String message) onMessage) {
    _foregroundSubscription?.cancel();
    _foregroundSubscription = FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      final title = notification?.title ?? 'Order Food';
      final body = notification?.body ?? 'Bạn có thông báo mới.';
      onMessage('$title: $body');
    });
  }

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
