import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaya_juwelier/models/market_model.dart';
import 'package:kaya_juwelier/providers/gold_price_provider.dart';

final marketStreamProvider = StreamProvider<MarketModel>((ref) {
  final service = ref.watch(signalRServiceProvider);
  return service.marketStream;
});
