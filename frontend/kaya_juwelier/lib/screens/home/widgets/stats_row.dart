import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaya_juwelier/core/theme/app_theme.dart';
import 'package:kaya_juwelier/models/price_stats_model.dart';

class StatsRow extends StatelessWidget {
  final PriceStats stats;

  const StatsRow({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00', 'de_DE');
    final chgColor =
        stats.isPositive ? AppTheme.priceUp : AppTheme.priceDown;
    final chgSign = stats.isPositive ? '+' : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _Stat(label: 'Açılış', value: fmt.format(stats.open)),
          _Divider(),
          _Stat(label: 'En Yüksek', value: fmt.format(stats.high),
              valueColor: AppTheme.priceUp),
          _Divider(),
          _Stat(label: 'En Düşük', value: fmt.format(stats.low),
              valueColor: AppTheme.priceDown),
          _Divider(),
          _Stat(
            label: 'Değişim',
            value: '$chgSign${stats.changePercent.toStringAsFixed(2)}%',
            valueColor: chgColor,
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _Stat({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 10)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  color: valueColor ?? AppTheme.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
        ],
      );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(height: 24, width: 1, color: AppTheme.cardBorder);
}
