import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaya_juwelier/core/theme/app_theme.dart';

class TroyOunceRow extends StatelessWidget {
  final double priceTroyOz;     // EUR
  final double priceUsdOz;      // USD
  final DateTime updatedAt;
  final String currency;        // 'EUR' or 'USD'

  const TroyOunceRow({
    super.key,
    required this.priceTroyOz,
    required this.priceUsdOz,
    required this.updatedAt,
    this.currency = 'EUR',
  });

  @override
  Widget build(BuildContext context) {
    final fmtEur = NumberFormat('#,##0.00', 'de_DE');
    final fmtUsd = NumberFormat('#,##0.00', 'en_US');
    final fmtTime = DateFormat('HH:mm:ss');

    final displayPrice = currency == 'USD' ? priceUsdOz : priceTroyOz;
    final displayFmt   = currency == 'USD' ? fmtUsd : fmtEur;
    final symbol       = currency == 'USD' ? '\$' : '€';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.gold.withAlpha(80)),
      ),
      child: Row(
        children: [
          // Gold coin icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.gold.withAlpha(30),
              border: Border.all(color: AppTheme.gold.withAlpha(100)),
            ),
            child: const Center(
              child: Text('Au', style: TextStyle(
                  color: AppTheme.gold,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ons (Troy oz)',
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12)),
                const SizedBox(height: 2),
                Text(
                  '$symbol ${displayFmt.format(displayPrice)}',
                  style: const TextStyle(
                      color: AppTheme.gold,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          // Last update time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Son güncelleme',
                  style: TextStyle(
                      color: AppTheme.textSecondary, fontSize: 10)),
              const SizedBox(height: 2),
              Text(
                fmtTime.format(updatedAt.toLocal()),
                style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    fontFamily: 'monospace'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
