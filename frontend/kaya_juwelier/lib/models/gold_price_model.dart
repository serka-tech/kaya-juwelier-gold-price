import 'package:flutter/foundation.dart';

@immutable
class GoldPriceModel {
  final double priceGram24K;
  final double priceGram22K;
  final double priceGram21K;
  final double priceGram18K;
  final double priceGram14K;
  final double priceTroyOz;
  final double priceUsdOz;
  final double eurUsdRate;
  final String currency;
  final bool   isDemo;
  final DateTime updatedAt;

  const GoldPriceModel({
    required this.priceGram24K,
    required this.priceGram22K,
    required this.priceGram21K,
    required this.priceGram18K,
    required this.priceGram14K,
    required this.priceTroyOz,
    required this.priceUsdOz,
    required this.eurUsdRate,
    required this.currency,
    required this.isDemo,
    required this.updatedAt,
  });

  factory GoldPriceModel.fromJson(Map<String, dynamic> json) => GoldPriceModel(
    priceGram24K: (json['priceGram24K'] as num).toDouble(),
    priceGram22K: (json['priceGram22K'] as num).toDouble(),
    priceGram21K: (json['priceGram21K'] as num).toDouble(),
    priceGram18K: (json['priceGram18K'] as num).toDouble(),
    priceGram14K: (json['priceGram14K'] as num? ?? 0).toDouble(),
    priceTroyOz:  (json['priceTroyOz']  as num).toDouble(),
    priceUsdOz:   (json['priceUsdOz']   as num? ?? 0).toDouble(),
    eurUsdRate:   (json['eurUsdRate']    as num? ?? 1.10).toDouble(),
    currency:     json['currency'] as String? ?? 'EUR',
    isDemo:       json['isDemo']   as bool?   ?? false,
    updatedAt:    DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
  );
}
