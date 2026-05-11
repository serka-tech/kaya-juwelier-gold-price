class CommissionModel {
  final String assetKey;
  final String assetLabel;
  final double commissionPercent;

  const CommissionModel({
    required this.assetKey,
    required this.assetLabel,
    required this.commissionPercent,
  });

  factory CommissionModel.fromJson(Map<String, dynamic> j) => CommissionModel(
        assetKey:          j['assetKey']          as String,
        assetLabel:        j['assetLabel']         as String,
        commissionPercent: (j['commissionPercent'] as num).toDouble(),
      );

  // Apply commission multiplier to a price
  double apply(double price) => price * (1 + commissionPercent / 100);
}

// Map of assetKey → CommissionModel for quick lookup
typedef CommissionMap = Map<String, CommissionModel>;
