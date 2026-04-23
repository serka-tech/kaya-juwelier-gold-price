class ChartPoint {
  final DateTime t;
  final double price24K;
  final double price22K;
  final double price18K;
  final double priceTroyOz;

  const ChartPoint({
    required this.t,
    required this.price24K,
    required this.price22K,
    required this.price18K,
    required this.priceTroyOz,
  });

  factory ChartPoint.fromJson(Map<String, dynamic> json) => ChartPoint(
        t: DateTime.parse(json['t'] as String),
        price24K: (json['price24K'] as num).toDouble(),
        price22K: (json['price22K'] as num).toDouble(),
        price18K: (json['price18K'] as num).toDouble(),
        priceTroyOz: (json['priceTroyOz'] as num).toDouble(),
      );
}

enum ChartRange {
  h1('1h', '1 Saat'),
  d1('1d', '1 Gün'),
  d5('5d', '5 Gün'),
  m1('1m', '1 Ay'),
  m3('3m', '3 Ay'),
  y1('1y', '1 Yıl');

  const ChartRange(this.value, this.label);
  final String value;
  final String label;
}
