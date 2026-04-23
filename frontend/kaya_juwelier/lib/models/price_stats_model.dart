class PriceStats {
  final double open;
  final double high;
  final double low;
  final double close;
  final double changePercent;

  const PriceStats({
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.changePercent,
  });

  factory PriceStats.fromJson(Map<String, dynamic> json) => PriceStats(
        open:          (json['open']          as num).toDouble(),
        high:          (json['high']          as num).toDouble(),
        low:           (json['low']           as num).toDouble(),
        close:         (json['close']         as num).toDouble(),
        changePercent: (json['changePercent'] as num).toDouble(),
      );

  bool get isPositive => changePercent >= 0;
}
