class Environment {
  Environment._();

  static const apiBaseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://order-food-api-294162583218.asia-southeast1.run.app',
  );

  static const googleClientId = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
    defaultValue: '',
  );

  static const googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue: '',
  );

  static const fcmVapidKey = String.fromEnvironment(
    'FCM_VAPID_KEY',
    defaultValue: '',
  );
}

const String googleClientId = Environment.googleClientId;
const String googleServerClientId = Environment.googleServerClientId;
const String fcmVapidKey = Environment.fcmVapidKey;
