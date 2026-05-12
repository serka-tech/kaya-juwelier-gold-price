import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kaya_juwelier/core/constants/app_constants.dart';
import 'package:kaya_juwelier/core/theme/app_theme.dart';
import 'package:kaya_juwelier/models/chart_point_model.dart';
import 'package:kaya_juwelier/providers/chart_provider.dart';
import 'package:kaya_juwelier/providers/gold_price_provider.dart';
import 'package:kaya_juwelier/screens/home/widgets/app_drawer.dart';
import 'package:kaya_juwelier/screens/home/widgets/gold_price_row.dart';
import 'package:kaya_juwelier/screens/home/widgets/price_chart.dart';
import 'package:kaya_juwelier/screens/home/widgets/status_bar.dart';
import 'package:kaya_juwelier/screens/home/widgets/ticker_strip.dart';
import 'package:kaya_juwelier/screens/home/widgets/turkish_gold_section.dart';
import 'package:kaya_juwelier/models/turkish_gold_model.dart';
import 'package:kaya_juwelier/providers/commission_provider.dart';
import 'package:kaya_juwelier/screens/piyasalar/piyasalar_screen.dart';
import 'package:kaya_juwelier/services/signalr_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final statusAsync = ref.watch(connectionStatusProvider);
    final currency    = ref.watch(currencyProvider);

    final status = statusAsync.when(
      data:    (s) => s,
      loading: () => ConnectionStatus.connecting,
      error:   (e, _) => ConnectionStatus.error,
    );

    return Scaffold(
      backgroundColor: AppTheme.background,
      drawer: AppDrawer(
        selectedIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
      ),
      appBar: _buildAppBar(status, currency),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          _PricesTab(),
          PiyasalarScreen(),
          _ChartTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar(ConnectionStatus status, String currency) {
    return AppBar(
      backgroundColor: AppTheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 0,
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu_rounded,
              color: AppTheme.textSecondary, size: 22),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
      title: _LogoWidget(height: 28),
      actions: [
        // Status badge
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: StatusBar(status: status),
        ),
        const SizedBox(width: 6),
        // Currency toggle
        GestureDetector(
          onTap: () => ref.read(currencyProvider.notifier).toggle(),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: Text(
              currency,
              style: const TextStyle(
                color: AppTheme.gold,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  BottomNavigationBar _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (i) => setState(() => _selectedIndex = i),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.show_chart_rounded),
          label: 'Fiyatlar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart_rounded),
          label: 'Piyasalar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.candlestick_chart_outlined),
          label: 'Grafik',
        ),
      ],
    );
  }
}

// ── Prices Tab ────────────────────────────────────────────────────────────────
class _PricesTab extends ConsumerWidget {
  const _PricesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final priceAsync = ref.watch(goldPriceStreamProvider);
    final currency   = ref.watch(currencyProvider);
    final statsAsync = ref.watch(priceStatsProvider(ChartRange.d1.value));
    final chartAsync = ref.watch(chartDataProvider(ChartRange.d1));
    final commMap    = ref.watch(commissionProvider).asData?.value ?? {};
    return Column(
      children: [
        // ── Ticker strip ───────────────────────────────────────────────
        const TickerStrip(),

        // ── Price rows ─────────────────────────────────────────────────
        Expanded(
          child: priceAsync.when(
            loading: () => const _LoadingView(),
            error:   (e, _) => const _ErrorView(),
            data: (price) {
              final eurUsd = price.eurUsdRate > 0 ? price.eurUsdRate : 1.10;
              double toDisplay(double eurGram) =>
                  currency == 'USD' ? eurGram * eurUsd : eurGram;

              // Apply commission: multiply by (1 + commission%)
              double withComm(double p, String key) =>
                  commMap[key]?.apply(p) ?? p;

              final changePct = statsAsync.whenOrNull(
                data: (s) => s.open > 0 ? s.changePercent : null,
              );

              // Extract spark series from chart data (downsample to ~30 pts)
              final chartPoints = chartAsync.whenOrNull(data: (pts) => pts) ?? [];
              List<double> toSpark(List<double> full) {
                if (full.length <= 30) return full;
                final step = (full.length / 30).ceil();
                return [
                  for (int i = 0; i < full.length; i += step) full[i],
                ];
              }

              final spark24 = toSpark(chartPoints.map((p) => toDisplay(p.price24K)).toList());
              final spark22 = toSpark(chartPoints.map((p) => toDisplay(p.price22K)).toList());
              // 21K not in chart model — derive from 22K
              final spark21 = toSpark(chartPoints.map((p) => toDisplay(p.price22K * 21 / 22)).toList());
              final spark18 = toSpark(chartPoints.map((p) => toDisplay(p.price18K)).toList());
              final spark14 = toSpark(chartPoints.map((p) => toDisplay(p.price18K * 14 / 18)).toList());

              final rows = [
                _GoldRowData('24 Ayar', '999.9',
                    withComm(toDisplay(price.priceGram24K), '24K'),
                    const Color(0xFFC9A227), spark24),
                _GoldRowData('22 Ayar', '916.6',
                    withComm(toDisplay(price.priceGram22K), '22K'),
                    const Color(0xFFB8960E), spark22),
                _GoldRowData('21 Ayar', '875.0',
                    withComm(toDisplay(price.priceGram21K), '21K'),
                    const Color(0xFFA07C10), spark21),
                _GoldRowData('18 Ayar', '750.0',
                    withComm(toDisplay(price.priceGram18K), '18K'),
                    const Color(0xFF8B6914), spark18),
                _GoldRowData('14 Ayar', '585.0',
                    withComm(toDisplay(price.priceGram14K), '14K'),
                    const Color(0xFF7A5C0A), spark14),
              ];

              return ListView(
                children: [
                  // ── Turkish gold coins ─────────────────────────────────
                  TurkishGoldSection(
                    prices: TurkishGoldCalculator.calculate(price.priceGram22K),
                    currencySymbol: currency == 'EUR' ? '€' : '\$',
                    commMap: commMap,
                  ),

                  // ── Karat section header ───────────────────────────────
                  Container(
                    color: AppTheme.surfaceElevated,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 4, height: 16,
                          decoration: BoxDecoration(
                            color: AppTheme.gold,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'GRAM ALTIN',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          currency == 'EUR' ? 'FİYAT (€/g)' : 'FİYAT (\$/g)',
                          style: const TextStyle(
                            color: AppTheme.textHint,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppTheme.divider),

                  for (int i = 0; i < rows.length; i++) ...[
                    GoldPriceRow(
                      karat: rows[i].karat,
                      fineness: rows[i].fineness,
                      price: rows[i].price,
                      currencySymbol: currency == 'EUR' ? '€' : '\$',
                      unit: 'gram',
                      accentColor: rows[i].color,
                      changePercent: changePct,
                      sparkData: rows[i].spark,
                    ),
                    if (i < rows.length - 1)
                      const Divider(height: 1, color: AppTheme.divider,
                          indent: 68),
                  ],

                  // ── Troy ounce row ─────────────────────────────────────
                  const Divider(height: 1, color: AppTheme.divider),
                  _TroyRow(
                    priceTroyOz: withComm(price.priceTroyOz, 'troy'),
                    priceUsdOz:  withComm(price.priceUsdOz,  'troy'),
                    currency:    currency,
                  ),
                  const Divider(height: 1, color: AppTheme.divider),
                  const SizedBox(height: 8),

                  // ── Last update ────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time_rounded,
                            size: 12, color: AppTheme.textHint),
                        const SizedBox(width: 5),
                        Text(
                          'Son güncelleme: ${_formatTime(price.updatedAt)}',
                          style: const TextStyle(
                            color: AppTheme.textHint, fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Disclaimer ─────────────────────────────────────────
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 4, 16, 20),
                    child: Text(
                      'Fiyatlar bilgi amaçlıdır, yatırım tavsiyesi değildir.',
                      style: TextStyle(
                          color: AppTheme.textHint, fontSize: 10),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dt) {
    final local = dt.toLocal();
    final h = local.hour.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');
    final s = local.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}

class _GoldRowData {
  final String karat, fineness;
  final double price;
  final Color color;
  final List<double> spark;
  const _GoldRowData(this.karat, this.fineness, this.price, this.color,
      [this.spark = const []]);
}

// ── Troy row ──────────────────────────────────────────────────────────────────
class _TroyRow extends StatelessWidget {
  final double priceTroyOz;
  final double priceUsdOz;
  final String currency;

  const _TroyRow({
    required this.priceTroyOz,
    required this.priceUsdOz,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surfaceElevated,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          // Badge
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppTheme.surfaceHighlight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppTheme.cardBorder,
                width: 1,
              ),
            ),
            child: const Center(
              child: Text(
                'OZ',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Name
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Troy Ons',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  '31.1035 g · 24K',
                  style: TextStyle(
                    color: AppTheme.textHint, fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // Prices
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '€ ${priceTroyOz.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '\$ ${priceUsdOz.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 11,
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

// ── Chart Tab ─────────────────────────────────────────────────────────────────
class _ChartTab extends StatelessWidget {
  const _ChartTab();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fiyat Grafiği',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 16),
          PriceChart(),
          SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Loading / Error views ─────────────────────────────────────────────────────
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppTheme.gold, strokeWidth: 2),
          SizedBox(height: 16),
          Text(
            'Fiyatlar yükleniyor...',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView();

  @override
  Widget build(BuildContext context) {
    return Center(
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
            const Text(
              'Bağlantı kurulamadı',
              style: TextStyle(
                color: AppTheme.textPrimary, fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sunucunun çalıştığından emin olun:\ndotnet run',
              style: TextStyle(
                  color: AppTheme.textSecondary, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Logo: loads from GitHub, falls back to local SVG ─────────────────────────
class _LogoWidget extends StatelessWidget {
  final double height;
  const _LogoWidget({required this.height});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      AppConstants.logoUrl,
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => SvgPicture.asset(
        'assets/juvkaya-yataylogo.svg',
        height: height,
        fit: BoxFit.contain,
      ),
    );
  }
}
