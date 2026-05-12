class AppConstants {
  // Android emulator uses 10.0.2.2 to reach host machine's localhost
  // iOS simulator and Web use: http://localhost:5000
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5000',
  );

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
