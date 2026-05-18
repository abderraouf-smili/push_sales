import 'app_environment.dart';

class AppConfig {
  static const String _envName = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'vpn',
  );

  static const String _apiBaseUrlOverride = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );

  static const String firebaseApiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: 'AIzaSyCVRFwJ9fko-vJ9VhYg6TWQ96xU1K7Rraw',
  );

  static const String firebaseAppId = String.fromEnvironment(
    'FIREBASE_APP_ID',
    defaultValue: '1:908812739457:android:b40dbd59692694c9d77e80',
  );

  static const String firebaseMessagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
    defaultValue: '908812739457',
  );

  static const String firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'pushsale-2ed49',
  );

  static const String firebaseStorageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
    defaultValue: 'pushsale-2ed49.firebasestorage.app',
  );

  static AppEnvironment get environment => AppEnvironment.fromName(_envName);

  static bool get isDemoMode => environment == AppEnvironment.demo;

  static bool get isRealDataMode =>
      environment == AppEnvironment.vpn ||
      environment == AppEnvironment.real ||
      environment == AppEnvironment.production;

  static String get apiBaseUrl {
    if (_apiBaseUrlOverride.trim().isNotEmpty) {
      return _normalizeBaseUrl(_apiBaseUrlOverride);
    }

    switch (environment) {
      case AppEnvironment.demo:
        return 'http://192.168.1.20:8000';
      case AppEnvironment.emulator:
        return 'http://10.0.2.2:8000';
      case AppEnvironment.real:
        return 'http://192.168.1.20:8000';
      case AppEnvironment.production:
        return 'https://example.com';
      case AppEnvironment.vpn:
        return 'http://192.168.1.20:8000';
    }
  }

  static String get apiRootUrl =>
      '${apiBaseUrl.replaceAll(RegExp(r'/+$'), '')}/api';

  static String _normalizeBaseUrl(String value) {
    return value
        .trim()
        .replaceAll(RegExp(r'/api/?$'), '')
        .replaceAll(RegExp(r'/+$'), '');
  }
}
