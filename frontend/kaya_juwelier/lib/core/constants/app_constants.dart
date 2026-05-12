import 'package:flutter/foundation.dart' show kIsWeb;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html show window;

class AppConstants {
  // On web: use same origin as the page (works with any ngrok/domain)
  // On Android emulator: use 10.0.2.2
  static String get apiBaseUrl {
    if (kIsWeb) {
      final origin = html.window.location.origin;
      // If running on localhost dev server, point to backend port
      if (origin.contains('localhost:') && !origin.contains(':5000')) {
        return 'http://localhost:5000';
      }
      return origin;
    }
    return const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://10.0.2.2:5000',
    );
  }

  // GitHub asset CDN
  static const String ghAssetsBase =
      'https://raw.githubusercontent.com/serka-tech/kaya-juwelier-gold-price/main/assets/';
  static String get logoUrl => '${ghAssetsBase}logo.png';

  static String get signalRHubUrl   => '$apiBaseUrl/hubs/goldprice';
  static String get currentPriceUrl => '$apiBaseUrl/api/goldprice/current';
  static String get chartUrl        => '$apiBaseUrl/api/goldprice/chart';
  static String get statsUrl        => '$apiBaseUrl/api/goldprice/stats';
  static String get marketUrl       => '$apiBaseUrl/api/market/current';

  // SignalR reconnect delays in milliseconds
  static const List<int> reconnectDelays = [0, 2000, 5000, 10000, 30000];
}
