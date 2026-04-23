import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaya_juwelier/core/theme/app_theme.dart';
import 'package:kaya_juwelier/models/price_stats_model.dart';

class StatsRow extends StatelessWidget {
  final PriceStats stats;
  const StatsRow({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final fmt      = NumberFormat('#,##0.00', 'de_DE');
    final isUp     = stats.isPositive;
    final chgColor = isUp ? AppTheme.priceUp : AppTheme.priceDown;
    final chgBg    = isUp ? AppTheme.priceUpBg : AppTheme.priceDownBg;
    final chgSign  = isUp ? '+' : '';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          _StatBox(label: 'Açılış',     value: fmt.format(stats.open)),
          _StatBox(label: 'En Yüksek',  value: fmt.format(stats.high),
              valueColor: AppTheme.priceUp),
          _StatBox(label: 'En Düşük',   value: fmt.format(stats.low),
              valueColor: AppTheme.priceDown),
          // Change % — pill style
          Expanded(
            child: Column(
              children: [
                const Text('Değişim',
                  style: TextStyle(
                    color: AppTheme.textSecondary, fontSize: 10,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: chgBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$chgSign${stats.changePercent.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: chgColor, fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _StatBox({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(label,
          style: const TextStyle(
            color: AppTheme.textSecondary, fontSize: 10,
          ),
        ),
        const SizedBox(height: 4),
        Text(value,
          style: TextStyle(
            color: valueColor ?? AppTheme.textPrimary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}
