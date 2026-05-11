import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kaya_juwelier/core/theme/app_theme.dart';
import 'package:kaya_juwelier/providers/gold_price_provider.dart';

class TickerStrip extends ConsumerWidget {
  const TickerStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final priceAsync = ref.watch(goldPriceStreamProvider);
    final currency   = ref.watch(currencyProvider);

    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          bottom: BorderSide(color: AppTheme.divider, width: 1),
        ),
      ),
      child: priceAsync.when(
        loading: () => const SizedBox.shrink(),
        error:   (e, st) => const SizedBox.shrink(),
        data: (price) {
          final eurUsd = price.eurUsdRate > 0 ? price.eurUsdRate : 1.10;
          final fmtEur = NumberFormat('#,##0.00', 'de_DE');
          final fmtUsd = NumberFormat('#,##0.00', 'en_US');
          final fmtRate = NumberFormat('#,##0.0000', 'de_DE');

          final items = [
            _TickerData(
              symbol: 'XAU/EUR',
              subtitle: '24K · gram',
              value: '€ ${fmtEur.format(price.priceGram24K)}',
              isHighlighted: currency == 'EUR',
            ),
            _TickerData(
              symbol: 'XAU/USD',
              subtitle: 'Troy ons',
              value: '\$ ${fmtUsd.format(price.priceUsdOz)}',
              isHighlighted: currency == 'USD',
            ),
            _TickerData(
              symbol: 'XAU/EUR',
              subtitle: 'Troy ons',
              value: '€ ${fmtEur.format(price.priceTroyOz)}',
              isHighlighted: false,
            ),
            _TickerData(
              symbol: 'EUR/USD',
              subtitle: 'Kur',
              value: fmtRate.format(eurUsd),
              isHighlighted: false,
            ),
            _TickerData(
              symbol: 'XAU/USD',
              subtitle: '24K · gram',
              value: '\$ ${fmtUsd.format(price.priceGram24K * eurUsd)}',
              isHighlighted: false,
            ),
          ];

          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: items.length,
            separatorBuilder: (context, index) => Container(
              width: 1,
              margin: const EdgeInsets.symmetric(vertical: 20),
              color: AppTheme.divider,
            ),
            itemBuilder: (_, i) => _TickerItem(data: items[i]),
          );
        },
      ),
    );
  }
}

class _TickerData {
  final String symbol;
  final String subtitle;
  final String value;
  final bool isHighlighted;

  const _TickerData({
    required this.symbol,
    required this.subtitle,
    required this.value,
    required this.isHighlighted,
  });
}

class _TickerItem extends StatelessWidget {
  final _TickerData data;
  const _TickerItem({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                data.symbol,
                style: TextStyle(
                  color: data.isHighlighted ? AppTheme.gold : AppTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              if (data.isHighlighted) ...[
                const SizedBox(width: 5),
                Container(
                  width: 5, height: 5,
                  decoration: const BoxDecoration(
                    color: AppTheme.gold,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 3),
          Text(
            data.value,
            style: TextStyle(
              color: data.isHighlighted
                  ? AppTheme.gold
                  : AppTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            data.subtitle,
            style: const TextStyle(
              color: AppTheme.textHint,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
