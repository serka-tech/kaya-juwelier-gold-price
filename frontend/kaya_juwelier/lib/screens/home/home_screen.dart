import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    // Use last emitted price for the pulse trigger
    final lastPrice = priceAsync.when(
      data: (p) => p, loading: () => null, error: (e, s) => null);

    return Scaffold(
      appBar: AppBar(
        title: const Text('KAYA JUWELİER'),
        actions: [
          // Currency toggle button
          GestureDetector(
            onTap: () => ref.read(currencyProvider.notifier).toggle(),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.gold.withAlpha(150)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                currency,
                style: const TextStyle(
                    color: AppTheme.gold,
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
              ),
            ),
          ),
          // Settings button
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppTheme.gold),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(32),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StatusBar(status: status),
                if (status == ConnectionStatus.live && lastPrice != null) ...[
                  const SizedBox(width: 12),
                  LivePulse(trigger: lastPrice.updatedAt),
                ],
              ],
            ),
          ),
        ),
      ),
      body: priceAsync.when(
        loading: () => _buildLoading(),
        error:   (e, _) => _buildError(e),
        data: (price) => RefreshIndicator(
          color: AppTheme.gold,
          onRefresh: () async {
            final service = ref.read(signalRServiceProvider);
            await service.connect();
            ref.invalidate(chartDataProvider);
          },
          child: _buildBody(context, ref, price, currency),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    GoldPriceModel price,
    String currency,
  ) {
    // Convert prices to USD if needed
    final eurUsd = price.eurUsdRate > 0 ? price.eurUsdRate : 1.10;

    double toDisplay(double eurGram) =>
        currency == 'USD' ? eurGram * eurUsd : eurGram;

    final p24 = toDisplay(price.priceGram24K);
    final p22 = toDisplay(price.priceGram22K);
    final p21 = toDisplay(price.priceGram21K);
    final p18 = toDisplay(price.priceGram18K);
    final currencyLabel = currency == 'USD' ? 'USD / gram' : 'EUR / gram';
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 600;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(isWide ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Price cards ──────────────────────────────────────────────
          isWide
              ? Row(
                  children: [
                    Expanded(child: PriceCard(label: '24 Ayar Altın', fineness: '999.9', price: p24, accentColor: AppTheme.gold, currencyLabel: currencyLabel)),
                    const SizedBox(width: 12),
                    Expanded(child: PriceCard(label: '22 Ayar Altın', fineness: '916.6', price: p22, accentColor: const Color(0xFFFFD700), currencyLabel: currencyLabel)),
                    const SizedBox(width: 12),
                    Expanded(child: PriceCard(label: '21 Ayar Altın', fineness: '875.0', price: p21, accentColor: const Color(0xFFFFC107), currencyLabel: currencyLabel)),
                    const SizedBox(width: 12),
                    Expanded(child: PriceCard(label: '18 Ayar Altın', fineness: '750.0', price: p18, accentColor: const Color(0xFFFFB300), currencyLabel: currencyLabel)),
                  ],
                )
              : GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.15,
                  children: [
                    PriceCard(label: '24 Ayar Altın', fineness: '999.9', price: p24, accentColor: AppTheme.gold, currencyLabel: currencyLabel),
                    PriceCard(label: '22 Ayar Altın', fineness: '916.6', price: p22, accentColor: const Color(0xFFFFD700), currencyLabel: currencyLabel),
                    PriceCard(label: '21 Ayar Altın', fineness: '875.0', price: p21, accentColor: const Color(0xFFFFC107), currencyLabel: currencyLabel),
                    PriceCard(label: '18 Ayar Altın', fineness: '750.0', price: p18, accentColor: const Color(0xFFFFB300), currencyLabel: currencyLabel),
                  ],
                ),
          const SizedBox(height: 12),

          // ── Troy ounce row ───────────────────────────────────────────
          TroyOunceRow(
            priceTroyOz: price.priceTroyOz,
            priceUsdOz:  price.priceUsdOz,
            updatedAt:   price.updatedAt,
            currency:    currency,
          ),
          const SizedBox(height: 16),

          // ── EUR/USD rate badge ────────────────────────────────────────
          _EurUsdBadge(rate: eurUsd),
          const SizedBox(height: 16),

          // ── Chart section ────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Fiyat Grafiği',
                      style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.refresh,
                          color: AppTheme.textSecondary, size: 18),
                      tooltip: 'Grafiği yenile',
                      onPressed: () => ref.invalidate(chartDataProvider),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const PriceChart(),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Disclaimer ───────────────────────────────────────────────
          Center(
            child: Text(
              'Fiyatlar bilgi amaçlıdır, yatırım tavsiyesi değildir.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontSize: 11),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildLoading() => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppTheme.gold),
            SizedBox(height: 16),
            Text('Fiyatlar yükleniyor...',
                style: TextStyle(color: AppTheme.textSecondary)),
          ],
        ),
      );

  Widget _buildError(Object e) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, color: AppTheme.priceDown, size: 56),
              const SizedBox(height: 16),
              const Text('Sunucuya bağlanılamadı',
                  style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('$e',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12),
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
              const Text(
                'Sunucunun çalıştığından emin olun:\ndotnet run',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
}

class _EurUsdBadge extends StatelessWidget {
  final double rate;
  const _EurUsdBadge({required this.rate});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.cardBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('EUR/USD  ',
                  style: TextStyle(
                      color: AppTheme.textSecondary, fontSize: 11)),
              Text(
                rate.toStringAsFixed(4),
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
