import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kaya_juwelier/core/theme/app_theme.dart';
import 'package:kaya_juwelier/models/gold_price_model.dart';
import 'package:kaya_juwelier/providers/chart_provider.dart';
import 'package:kaya_juwelier/providers/gold_price_provider.dart';
import 'package:kaya_juwelier/screens/home/widgets/live_pulse.dart';
import 'package:kaya_juwelier/screens/home/widgets/price_card.dart';
import 'package:kaya_juwelier/screens/home/widgets/price_chart.dart';
import 'package:kaya_juwelier/screens/home/widgets/status_bar.dart';
import 'package:kaya_juwelier/screens/home/widgets/troy_ounce_row.dart';
import 'package:kaya_juwelier/screens/settings/settings_screen.dart';
import 'package:kaya_juwelier/services/signalr_service.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final priceAsync  = ref.watch(goldPriceStreamProvider);
    final statusAsync = ref.watch(connectionStatusProvider);
    final currency    = ref.watch(currencyProvider);

    final status = statusAsync.when(
      data:    (s) => s,
      loading: () => ConnectionStatus.connecting,
      error:   (e, st) => ConnectionStatus.error,
    );

    final lastPrice = priceAsync.when(
      data: (p) => p, loading: () => null, error: (e, s) => null,
    );

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ── Sticky top app bar ─────────────────────────────────────
          SliverAppBar(
            pinned: true,
            floating: false,
            expandedHeight: 0,
            backgroundColor: AppTheme.surface,
            surfaceTintColor: Colors.transparent,
            shadowColor: AppTheme.divider,
            elevation: 0.5,
            titleSpacing: 20,
            title: Row(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.goldGlow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text('K',
                      style: TextStyle(
                        color: AppTheme.gold, fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text('Kaya Juwelier',
                  style: TextStyle(
                    color: AppTheme.textPrimary, fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            actions: [
              // Status indicator
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: StatusBar(status: status),
              ),
              if (status == ConnectionStatus.live && lastPrice != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
                  child: LivePulse(trigger: lastPrice.updatedAt),
                ),
              // Currency toggle
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                child: GestureDetector(
                  onTap: () => ref.read(currencyProvider.notifier).toggle(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.goldGlow,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(currency,
                      style: const TextStyle(
                        color: AppTheme.gold, fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
              // Settings
              IconButton(
                icon: const Icon(Icons.tune_rounded,
                    color: AppTheme.textSecondary, size: 22),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),

          // ── Pull-to-refresh wrapper ─────────────────────────────────
          CupertinoSliverRefreshControl(
            onRefresh: () async {
              final service = ref.read(signalRServiceProvider);
              await service.connect();
              ref.invalidate(chartDataProvider);
            },
          ),

          // ── Body content ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: priceAsync.when(
              loading: () => _buildLoading(),
              error:   (e, _) => _buildError(e),
              data:    (price) => _buildBody(context, ref, price, currency),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    GoldPriceModel price,
    String currency,
  ) {
    final eurUsd = price.eurUsdRate > 0 ? price.eurUsdRate : 1.10;
    double toDisplay(double eurGram) =>
        currency == 'USD' ? eurGram * eurUsd : eurGram;

    final p24 = toDisplay(price.priceGram24K);
    final p22 = toDisplay(price.priceGram22K);
    final p21 = toDisplay(price.priceGram21K);
    final p18 = toDisplay(price.priceGram18K);
    final currencyLabel = currency == 'USD' ? 'USD/g' : 'EUR/g';
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 600;
    final pad = isWide ? 24.0 : 16.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Hero section ─────────────────────────────────────────────
        _HeroSection(price: price, currency: currency, eurUsd: eurUsd),

        // ── Section label ─────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.fromLTRB(pad, 20, pad, 12),
          child: const Text('Altın Fiyatları',
            style: TextStyle(
              color: AppTheme.textPrimary, fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        // ── Price cards grid ─────────────────────────────────────────
        isWide
            ? Padding(
                padding: EdgeInsets.symmetric(horizontal: pad),
                child: Row(children: [
                  Expanded(child: PriceCard(label: '24 Ayar', fineness: '999.9', price: p24, accentColor: const Color(0xFFC9A227), currencyLabel: currencyLabel)),
                  const SizedBox(width: 12),
                  Expanded(child: PriceCard(label: '22 Ayar', fineness: '916.6', price: p22, accentColor: const Color(0xFFB8960E), currencyLabel: currencyLabel)),
                  const SizedBox(width: 12),
                  Expanded(child: PriceCard(label: '21 Ayar', fineness: '875.0', price: p21, accentColor: const Color(0xFFA07C10), currencyLabel: currencyLabel)),
                  const SizedBox(width: 12),
                  Expanded(child: PriceCard(label: '18 Ayar', fineness: '750.0', price: p18, accentColor: const Color(0xFF8B6914), currencyLabel: currencyLabel)),
                ]),
              )
            : Padding(
                padding: EdgeInsets.symmetric(horizontal: pad),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.45,
                  children: [
                    PriceCard(label: '24 Ayar', fineness: '999.9', price: p24, accentColor: const Color(0xFFC9A227), currencyLabel: currencyLabel),
                    PriceCard(label: '22 Ayar', fineness: '916.6', price: p22, accentColor: const Color(0xFFB8960E), currencyLabel: currencyLabel),
                    PriceCard(label: '21 Ayar', fineness: '875.0', price: p21, accentColor: const Color(0xFFA07C10), currencyLabel: currencyLabel),
                    PriceCard(label: '18 Ayar', fineness: '750.0', price: p18, accentColor: const Color(0xFF8B6914), currencyLabel: currencyLabel),
                  ],
                ),
              ),

        const SizedBox(height: 16),

        // ── Troy ounce ───────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.symmetric(horizontal: pad),
          child: TroyOunceRow(
            priceTroyOz: price.priceTroyOz,
            priceUsdOz:  price.priceUsdOz,
            updatedAt:   price.updatedAt,
            currency:    currency,
          ),
        ),

        const SizedBox(height: 20),

        // ── Chart section ─────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.symmetric(horizontal: pad),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 16, 0),
                  child: Row(
                    children: [
                      const Text('Fiyat Grafiği',
                        style: TextStyle(
                          color: AppTheme.textPrimary, fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => ref.invalidate(chartDataProvider),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceAlt,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.refresh_rounded,
                            color: AppTheme.textSecondary, size: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: PriceChart(),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // ── Disclaimer ───────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.symmetric(horizontal: pad),
          child: const Text(
            'Fiyatlar bilgi amaçlıdır, yatırım tavsiyesi değildir.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textHint, fontSize: 11),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildLoading() => const SizedBox(
    height: 400,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppTheme.gold, strokeWidth: 2,
          ),
          SizedBox(height: 16),
          Text('Fiyatlar yükleniyor...',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
        ],
      ),
    ),
  );

  Widget _buildError(Object e) => SizedBox(
    height: 400,
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: AppTheme.priceDownBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.wifi_off_rounded,
                color: AppTheme.priceDown, size: 36),
            ),
            const SizedBox(height: 20),
            const Text('Bağlantı kurulamadı',
              style: TextStyle(
                color: AppTheme.textPrimary, fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sunucunun çalıştığından emin olun:\ndotnet run',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}

// ── Hero section ─────────────────────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  final GoldPriceModel price;
  final String currency;
  final double eurUsd;

  const _HeroSection({
    required this.price,
    required this.currency,
    required this.eurUsd,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00', 'de_DE');
    final displayPrice = currency == 'USD'
        ? price.priceGram24K * eurUsd
        : price.priceGram24K;
    final symbol = currency == 'USD' ? '\$' : '€';

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.goldGlow,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, color: AppTheme.gold, size: 7),
                    SizedBox(width: 5),
                    Text('Canlı Altın Fiyatı',
                      style: TextStyle(
                        color: AppTheme.gold, fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // EUR/USD rate chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceAlt,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'EUR/USD  ${eurUsd.toStringAsFixed(4)}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Big price — 24K
          Text(
            '$symbol ${fmt.format(displayPrice)}',
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 38,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '24 Ayar · gram başına',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 16),

          // Troy ounce quick stat row
          Row(
            children: [
              _HeroStat(
                label: 'Troy Ons (EUR)',
                value: '€ ${fmt.format(price.priceTroyOz)}',
                iconBg: AppTheme.goldGlow,
                iconColor: AppTheme.gold,
                icon: Icons.monetization_on_outlined,
              ),
              const SizedBox(width: 12),
              _HeroStat(
                label: 'Troy Ons (USD)',
                value: '\$ ${NumberFormat('#,##0.00', 'en_US').format(price.priceUsdOz)}',
                iconBg: const Color(0xFFE8F5E9),
                iconColor: AppTheme.priceUp,
                icon: Icons.attach_money_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;
  final Color iconBg;
  final Color iconColor;
  final IconData icon;

  const _HeroStat({
    required this.label,
    required this.value,
    required this.iconBg,
    required this.iconColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                color: iconBg, borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                    style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 10,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(value,
                    style: const TextStyle(
                      color: AppTheme.textPrimary, fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper pulled out to use CupertinoSliverRefreshControl
class CupertinoSliverRefreshControl extends StatelessWidget {
  final Future<void> Function() onRefresh;
  const CupertinoSliverRefreshControl({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(child: const SizedBox.shrink());
  }
}
