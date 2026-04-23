import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:kaya_juwelier/core/constants/app_constants.dart';
import 'package:kaya_juwelier/models/chart_point_model.dart';

/// Currently selected karat for chart display
enum ChartKarat { k24, k22, k18, troy }

/// Notifier for selected chart range
class ChartRangeNotifier extends Notifier<ChartRange> {
  @override
  ChartRange build() => ChartRange.h1;
  void set(ChartRange r) => state = r;
}

/// Notifier for selected karat
class ChartKaratNotifier extends Notifier<ChartKarat> {
  @override
  ChartKarat build() => ChartKarat.k24;
  void set(ChartKarat k) => state = k;
}

final chartRangeProvider =
    NotifierProvider<ChartRangeNotifier, ChartRange>(ChartRangeNotifier.new);

final chartKaratProvider =
    NotifierProvider<ChartKaratNotifier, ChartKarat>(ChartKaratNotifier.new);

/// Fetch chart data whenever range changes
final chartDataProvider = FutureProvider.autoDispose
    .family<List<ChartPoint>, ChartRange>((ref, range) async {
  final url = Uri.parse('${AppConstants.chartUrl}?range=${range.value}');
  final response =
      await http.get(url).timeout(const Duration(seconds: 15));
  if (response.statusCode != 200) {
    throw Exception('Grafik verisi alınamadı (${response.statusCode})');
  }
  final list = jsonDecode(response.body) as List<dynamic>;
  return list
      .map((e) => ChartPoint.fromJson(e as Map<String, dynamic>))
      .toList();
});
