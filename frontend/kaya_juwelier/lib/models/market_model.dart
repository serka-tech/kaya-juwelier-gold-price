import 'package:flutter/foundation.dart';

@immutable
class MarketAssetData {
  final double price;
  final double bid;
  final double ask;
  final double changePercent;

  const MarketAssetData({
    required this.price,
    required this.bid,
    required this.ask,
    required this.changePercent,
  });
}

@immutable
class MarketModel {
  final MarketAssetData gold;
  final MarketAssetData silver;
  final MarketAssetData platinum;
  final MarketAssetData palladium;
  final MarketAssetData usdTry;
  final MarketAssetData eurTry;
  final double eurUsd;
  final bool isDemo;
  final DateTime updatedAt;

  const MarketModel({
    required this.gold,
    required this.silver,
    required this.platinum,
    required this.palladium,
    required this.usdTry,
    required this.eurTry,
    required this.eurUsd,
    required this.isDemo,
    required this.updatedAt,
  });

  factory MarketModel.fromJson(Map<String, dynamic> j) {
    MarketAssetData asset(String priceKey, String bidKey, String askKey, String chgKey) =>
        MarketAssetData(
          price:         (j[priceKey] as num? ?? 0).toDouble(),
          bid:           (j[bidKey]   as num? ?? 0).toDouble(),
          ask:           (j[askKey]   as num? ?? 0).toDouble(),
          changePercent: (j[chgKey]   as num? ?? 0).toDouble(),
        );

    return MarketModel(
      gold:      asset('goldEurGram',     'goldBid',      'goldAsk',      'goldChangePercent'),
      silver:    asset('silverEurGram',   'silverBid',    'silverAsk',    'silverChangePercent'),
      platinum:  asset('platinumEurGram', 'platinumBid',  'platinumAsk',  'platinumChangePercent'),
      palladium: asset('palladiumEurGram','palladiumBid', 'palladiumAsk', 'palladiumChangePercent'),
      usdTry:    asset('usdTry',          'usdTryBid',    'usdTryAsk',    'usdTryChangePercent'),
      eurTry:    asset('eurTry',          'eurTryBid',    'eurTryAsk',    'eurTryChangePercent'),
      eurUsd:    (j['eurUsd']   as num? ?? 1.10).toDouble(),
      isDemo:    j['isDemo']    as bool?  ?? false,
      updatedAt: DateTime.tryParse(j['updatedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
