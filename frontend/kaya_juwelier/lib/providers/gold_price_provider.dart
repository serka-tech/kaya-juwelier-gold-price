import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kaya_juwelier/core/constants/app_constants.dart';
import 'package:kaya_juwelier/models/gold_price_model.dart';
import 'package:kaya_juwelier/models/price_stats_model.dart';
import 'package:kaya_juwelier/services/signalr_service.dart';

// ─────────────────────────────────────────────────────────────────────
// SignalR service singleton
// ─────────────────────────────────────────────────────────────────────
final signalRServiceProvider = Provider<SignalRService>((ref) {
  final service = SignalRService();
  ref.onDispose(service.dispose);
  return service;
});

// ─────────────────────────────────────────────────────────────────────
// Live price stream — emits each time a new price arrives from SignalR
// Also persists the last-known price to SharedPreferences so the app
// can show a cached value on startup before the first tick arrives.
// ─────────────────────────────────────────────────────────────────────
final goldPriceStreamProvider = StreamProvider<GoldPriceModel>((ref) async* {
  final service = ref.watch(signalRServiceProvider);
  service.connect();

  // Emit last cached price immediately so the UI doesn't stay on loading
  final cached = await _loadCachedPrice();
  if (cached != null) yield cached;

  await for (final price in service.priceStream) {
    await _savePrice(price);
    yield price;
  }
});

// ─────────────────────────────────────────────────────────────────────
// Connection status stream
// ─────────────────────────────────────────────────────────────────────
final connectionStatusProvider = StreamProvider<ConnectionStatus>((ref) {
  final service = ref.watch(signalRServiceProvider);
  return service.statusStream;
});

// ─────────────────────────────────────────────────────────────────────
// Currency display toggle: EUR ↔ USD
// ─────────────────────────────────────────────────────────────────────
class CurrencyNotifier extends Notifier<String> {
  @override
  String build() => 'EUR';
  void toggle() => state = state == 'EUR' ? 'USD' : 'EUR';
}

final currencyProvider =
    NotifierProvider<CurrencyNotifier, String>(CurrencyNotifier.new);

// ─────────────────────────────────────────────────────────────────────
// Price statistics (open/high/low/close/change%) for the current range
// ─────────────────────────────────────────────────────────────────────
final priceStatsProvider = FutureProvider.autoDispose
    .family<PriceStats, String>((ref, range) async {
  final url = Uri.parse('${AppConstants.statsUrl}?range=$range');
  final response = await http.get(url).timeout(const Duration(seconds: 10));
  if (response.statusCode != 200) {
    throw Exception('İstatistik alınamadı');
  }
  return PriceStats.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>);
});

// ─────────────────────────────────────────────────────────────────────
// SharedPreferences cache helpers
// ─────────────────────────────────────────────────────────────────────
const _kCachedPrice = 'cached_gold_price';

Future<GoldPriceModel?> _loadCachedPrice() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kCachedPrice);
    if (raw == null) return null;
    return GoldPriceModel.fromJson(
        jsonDecode(raw) as Map<String, dynamic>);
  } catch (_) {
    return null;
  }
}

Future<void> _savePrice(GoldPriceModel p) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _kCachedPrice,
        jsonEncode({
          'priceGram24K': p.priceGram24K,
          'priceGram22K': p.priceGram22K,
          'priceGram21K': p.priceGram21K,
          'priceGram18K': p.priceGram18K,
          'priceTroyOz':  p.priceTroyOz,
          'priceUsdOz':   p.priceUsdOz,
          'eurUsdRate':   p.eurUsdRate,
          'currency':     p.currency,
          'isDemo':       p.isDemo,
          'updatedAt':    p.updatedAt.toIso8601String(),
        }));
  } catch (_) {}
}
