import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kaya_juwelier/core/theme/app_theme.dart';
import 'package:kaya_juwelier/providers/gold_price_provider.dart';
import 'package:kaya_juwelier/providers/market_provider.dart';

class TickerStrip extends ConsumerWidget {
  const TickerStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final priceAsync  = ref.watch(goldPriceStreamProvider);
    final marketAsync = ref.watch(marketStreamProvider);

    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(bottom: BorderSide(color: AppTheme.divider, width: 1)),
      ),
      child: priceAsync.when(
        loading: () => const SizedBox.shrink(),
        error:   (_, __) => const SizedBox.shrink(),
        data: (price) {
          final fmt2   = NumberFormat('#,##0.00', 'de_DE');
          final fmt4   = NumberFormat('#,##0.0000', 'de_DE');
          final market = marketAsync.asData?.value;
          final eurUsd = price.eurUsdRate > 0 ? price.eurUsdRate : 1.10;

          final items = <_TickerData>[
            // ALTIN — always available from gold price stream
            _TickerData(
              label: 'ALTIN',
              sub: '24K · €/gram',
              value: '€ ${fmt2.format(price.priceGram24K)}',
              change: market?.gold.changePercent,
              highlight: true,
            ),
            // GÜMÜŞ
            _TickerData(
              label: 'GÜMÜŞ',
              sub: 'XAG · €/gram',
              value: market != null && market.silver.price > 0
                  ? '€ ${fmt4.format(market.silver.price)}'
                  : '—',
              change: market?.silver.changePercent,
            ),
            // PLATİN
            _TickerData(
              label: 'PLATİN',
              sub: 'XPT · €/gram',
              value: market != null && market.platinum.price > 0
                  ? '€ ${fmt2.format(market.platinum.price)}'
                  : '—',
              change: market?.platinum.changePercent,
            ),
            // PALADYUM
            _TickerData(
              label: 'PALADYUM',
              sub: 'XPD · €/gram',
              value: market != null && market.palladium.price > 0
                  ? '€ ${fmt2.format(market.palladium.price)}'
                  : '—',
              change: market?.palladium.changePercent,
            ),
            // DOLAR
            _TickerData(
              label: 'DOLAR',
              sub: 'USD/EUR',
              value: eurUsd > 0
                  ? fmt4.format(1.0 / eurUsd)
                  : '—',
              change: null,
            ),
            // EURO
            _TickerData(
              label: 'EURO',
              sub: 'EUR/USD',
              value: eurUsd > 0
                  ? fmt4.format(eurUsd)
                  : '—',
              change: null,
            ),
          ];

          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: items.length,
            separatorBuilder: (_, __) => Container(
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
  final String label;
  final String sub;
  final String value;
  final double? change;
  final bool highlight;

  const _TickerData({
    required this.label,
    required this.sub,
    required this.value,
    this.change,
    this.highlight = false,
  });
}

class _TickerItem extends StatelessWidget {
  final _TickerData data;
  const _TickerItem({required this.data});

  @override
  Widget build(BuildContext context) {
    final chg = data.change;
    final isUp   = chg != null && chg > 0;
    final isDown = chg != null && chg < 0;

    final labelColor = data.highlight ? AppTheme.gold : AppTheme.textSecondary;
    final valueColor = data.highlight ? AppTheme.gold : AppTheme.textPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label row
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(data.label,
                  style: TextStyle(
                    color: labelColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  )),
              if (data.highlight) ...[
                const SizedBox(width: 5),
                Container(
                  width: 5, height: 5,
                  decoration: const BoxDecoration(
                      color: AppTheme.gold, shape: BoxShape.circle),
                ),
              ],
            ],
          ),
          const SizedBox(height: 3),
          // Price
          Text(data.value,
              style: TextStyle(
                color: valueColor,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              )),
          const SizedBox(height: 2),
          // Sub + change
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(data.sub,
                  style: const TextStyle(
                      color: AppTheme.textHint, fontSize: 9)),
              if (chg != null) ...[
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: isUp
                        ? AppTheme.priceUpBg
                        : isDown
                            ? AppTheme.priceDownBg
                            : AppTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    '${isUp ? '+' : ''}${chg.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: isUp
                          ? AppTheme.priceUp
                          : isDown
                              ? AppTheme.priceDown
                              : AppTheme.textHint,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
