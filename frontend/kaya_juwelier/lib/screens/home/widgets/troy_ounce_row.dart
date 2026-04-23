import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaya_juwelier/core/theme/app_theme.dart';

class TroyOunceRow extends StatelessWidget {
  final double priceTroyOz;
  final double priceUsdOz;
  final DateTime updatedAt;
  final String currency;

  const TroyOunceRow({
    super.key,
    required this.priceTroyOz,
    required this.priceUsdOz,
    required this.updatedAt,
    this.currency = 'EUR',
  });

  @override
  Widget build(BuildContext context) {
    final fmtEur  = NumberFormat('#,##0.00', 'de_DE');
    final fmtUsd  = NumberFormat('#,##0.00', 'en_US');
    final fmtTime = DateFormat('HH:mm:ss');

    final eurFmt = fmtEur.format(priceTroyOz);
    final usdFmt = fmtUsd.format(priceUsdOz);
    final timeStr = fmtTime.format(updatedAt.toLocal());

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.subtleShadow,
      ),
      child: Row(
        children: [
          // Au coin
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE8C84A), Color(0xFFC9A227)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Text('Au',
                style: TextStyle(
                  color: Colors.white, fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Prices
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Troy Ons',
                  style: TextStyle(
                    color: AppTheme.textSecondary, fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('€ $eurFmt',
                      style: const TextStyle(
                        color: AppTheme.textPrimary, fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('\$ $usdFmt',
                      style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Timestamp
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Son güncelleme',
                style: TextStyle(color: AppTheme.textHint, fontSize: 10)),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceAlt,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  timeStr,
                  style: const TextStyle(
                    color: AppTheme.textPrimary, fontSize: 11,
                    fontWeight: FontWeight.w600,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
