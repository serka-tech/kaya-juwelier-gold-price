import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kaya_juwelier/core/constants/app_constants.dart';
import 'package:kaya_juwelier/core/theme/app_theme.dart';
import 'package:kaya_juwelier/models/market_model.dart';
import 'package:kaya_juwelier/providers/market_provider.dart';

class PiyasalarScreen extends ConsumerWidget {
  const PiyasalarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final marketAsync = ref.watch(marketStreamProvider);

    return marketAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.gold)),
      error: (_, __) => const _ErrorView(),
      data: (market) => _MarketBody(market: market),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, size: 48, color: AppTheme.textHint),
          const SizedBox(height: 12),
          const Text('Piyasa verisi alınamadı',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
          const SizedBox(height: 6),
          const Text('Bağlantı bekleniyor...',
              style: TextStyle(color: AppTheme.textHint, fontSize: 12)),
        ],
      ),
    );
  }
}

// ── Market body ───────────────────────────────────────────────────────────────
class _MarketBody extends StatelessWidget {
  final MarketModel market;
  const _MarketBody({required this.market});

  @override
  Widget build(BuildContext context) {
    final time = _formatTime(market.updatedAt);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // ── Status bar ────────────────────────────────────────────────
        Container(
          color: AppTheme.surfaceElevated,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 7, height: 7,
                decoration: BoxDecoration(
                  color: market.isDemo ? AppTheme.gold : AppTheme.priceUp,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                market.isDemo ? 'Demo Modu' : 'Canlı Veri',
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text('Güncelleme: $time',
                  style: const TextStyle(
                      color: AppTheme.textHint, fontSize: 11)),
            ],
          ),
        ),

        // ── Precious Metals ───────────────────────────────────────────
        _SectionHeader(
          icon: Icons.diamond_outlined,
          title: 'KIYMETLİ MADENLER',
          sub: 'EUR / gram',
        ),
        _TableHeader(),
        _AssetRow(
          name: 'Altın',
          symbol: 'XAU',
          emoji: '🥇',
          imageUrl: '${AppConstants.ghAssetsBase}altin.png',
          asset: market.gold,
          fmt: NumberFormat('#,##0.0000', 'de_DE'),
          unit: '€',
          color: AppTheme.gold,
        ),
        const Divider(height: 1, color: AppTheme.divider),
        _AssetRow(
          name: 'Gümüş',
          symbol: 'XAG',
          emoji: '🥈',
          imageUrl: '${AppConstants.ghAssetsBase}gumus.png',
          asset: market.silver,
          fmt: NumberFormat('#,##0.0000', 'de_DE'),
          unit: '€',
          color: const Color(0xFFAFAFAF),
          unavailable: market.silver.price <= 0,
        ),
        const Divider(height: 1, color: AppTheme.divider),
        _AssetRow(
          name: 'Platin',
          symbol: 'XPT',
          emoji: '⬜',
          imageUrl: '${AppConstants.ghAssetsBase}platin.png',
          asset: market.platinum,
          fmt: NumberFormat('#,##0.00', 'de_DE'),
          unit: '€',
          color: const Color(0xFF9BB7D4),
          unavailable: market.platinum.price <= 0,
        ),
        const Divider(height: 1, color: AppTheme.divider),
        _AssetRow(
          name: 'Paladyum',
          symbol: 'XPD',
          emoji: '🔘',
          imageUrl: '${AppConstants.ghAssetsBase}paladyum.png',
          asset: market.palladium,
          fmt: NumberFormat('#,##0.00', 'de_DE'),
          unit: '€',
          color: const Color(0xFF8B9DC3),
          unavailable: market.palladium.price <= 0,
        ),

        const SizedBox(height: 8),

        // ── Currencies ────────────────────────────────────────────────
        _SectionHeader(
          icon: Icons.currency_exchange_rounded,
          title: 'DÖVİZ',
          sub: 'TRY karşılığı',
        ),
        _TableHeader(isCurrency: true),
        _AssetRow(
          name: 'Dolar',
          symbol: 'USD/TRY',
          emoji: '💵',
          imageUrl: '${AppConstants.ghAssetsBase}dolar.png',
          asset: market.usdTry,
          fmt: NumberFormat('#,##0.0000', 'de_DE'),
          unit: '₺',
          color: const Color(0xFF4CAF50),
          unavailable: market.usdTry.price <= 0,
        ),
        const Divider(height: 1, color: AppTheme.divider),
        _AssetRow(
          name: 'Euro',
          symbol: 'EUR/TRY',
          emoji: '💶',
          imageUrl: '${AppConstants.ghAssetsBase}euro.png',
          asset: market.eurTry,
          fmt: NumberFormat('#,##0.0000', 'de_DE'),
          unit: '₺',
          color: const Color(0xFF2196F3),
          unavailable: market.eurTry.price <= 0,
        ),

        const SizedBox(height: 8),

        // ── EUR/USD reference ─────────────────────────────────────────
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.cardBorder),
          ),
          child: Row(
            children: [
              const Icon(Icons.swap_horiz_rounded,
                  size: 15, color: AppTheme.textHint),
              const SizedBox(width: 8),
              const Text('EUR/USD',
                  style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
              const Spacer(),
              Text(
                NumberFormat('#,##0.0000', 'de_DE').format(market.eurUsd),
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // ── Disclaimer ────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded,
                  size: 12, color: AppTheme.textHint),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Fiyatlar Finnhub üzerinden gerçek zamanlı alınmaktadır. '
                  'Bid/Ask gösterge amaçlıdır. Alım/satım için mağazamızı arayınız.',
                  style: TextStyle(color: AppTheme.textHint, fontSize: 10),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  String _formatTime(DateTime dt) {
    final local = dt.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}:'
        '${local.second.toString().padLeft(2, '0')}';
  }
}

// ── Section header ────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String sub;
  const _SectionHeader({required this.icon, required this.title, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surfaceElevated,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 4, height: 16,
            decoration: BoxDecoration(
                color: AppTheme.gold, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 8),
          Icon(icon, size: 14, color: AppTheme.textSecondary),
          const SizedBox(width: 6),
          Text(title,
              style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1)),
          const Spacer(),
          Text(sub,
              style: const TextStyle(
                  color: AppTheme.textHint, fontSize: 10)),
        ],
      ),
    );
  }
}

// ── Table column headers ──────────────────────────────────────────────────────
class _TableHeader extends StatelessWidget {
  final bool isCurrency;
  const _TableHeader({this.isCurrency = false});

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
        color: AppTheme.textHint,
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5);

    return Container(
      color: AppTheme.background,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Row(
        children: [
          const Expanded(flex: 3, child: Text('VARLIK', style: style)),
          const Expanded(flex: 2, child: Text('BID', style: style, textAlign: TextAlign.end)),
          const Expanded(flex: 2, child: Text('ASK', style: style, textAlign: TextAlign.end)),
          const Expanded(flex: 2, child: Text('DEĞİŞİM', style: style, textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}

// ── Asset row ─────────────────────────────────────────────────────────────────
class _AssetRow extends StatelessWidget {
  final String name;
  final String symbol;
  final String emoji;
  final String imageUrl;
  final MarketAssetData asset;
  final NumberFormat fmt;
  final String unit;
  final Color color;
  final bool unavailable;

  const _AssetRow({
    required this.name,
    required this.symbol,
    required this.emoji,
    required this.imageUrl,
    required this.asset,
    required this.fmt,
    required this.unit,
    required this.color,
    this.unavailable = false,
  });

  @override
  Widget build(BuildContext context) {
    final chg     = asset.changePercent;
    final isUp    = chg > 0;
    final isDown  = chg < 0;
    final chgColor = isUp
        ? AppTheme.priceUp
        : isDown
            ? AppTheme.priceDown
            : AppTheme.textHint;

    const na = '—';

    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Name + symbol
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    color: color.withAlpha(25),
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(color: color.withAlpha(60)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(17),
                    child: Image.network(
                      imageUrl,
                      width: 34, height: 34,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, progress) =>
                          progress == null
                              ? child
                              : Center(child: Text(emoji,
                                  style: const TextStyle(fontSize: 16))),
                      errorBuilder: (_, __, ___) =>
                          Center(child: Text(emoji,
                              style: const TextStyle(fontSize: 16))),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700)),
                    Text(symbol,
                        style: const TextStyle(
                            color: AppTheme.textHint, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),

          // Bid
          Expanded(
            flex: 2,
            child: Text(
              unavailable ? na : '$unit ${fmt.format(asset.bid)}',
              textAlign: TextAlign.end,
              style: TextStyle(
                  color: unavailable ? AppTheme.textHint : AppTheme.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
          ),

          // Ask
          Expanded(
            flex: 2,
            child: Text(
              unavailable ? na : '$unit ${fmt.format(asset.ask)}',
              textAlign: TextAlign.end,
              style: TextStyle(
                  color: unavailable ? AppTheme.textHint : color,
                  fontSize: 12,
                  fontWeight: FontWeight.w700),
            ),
          ),

          // Change
          Expanded(
            flex: 2,
            child: unavailable
                ? const Text(na,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                        color: AppTheme.textHint, fontSize: 12))
                : Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: isUp
                            ? AppTheme.priceUpBg
                            : isDown
                                ? AppTheme.priceDownBg
                                : AppTheme.surfaceElevated,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        '${isUp ? '+' : ''}${chg.toStringAsFixed(2)}%',
                        style: TextStyle(
                            color: chgColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
