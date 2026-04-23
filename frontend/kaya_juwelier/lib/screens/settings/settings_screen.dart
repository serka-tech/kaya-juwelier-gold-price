import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaya_juwelier/core/constants/app_constants.dart';
import 'package:kaya_juwelier/core/theme/app_theme.dart';
import 'package:kaya_juwelier/providers/gold_price_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(currencyProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: const Text('Ayarlar'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppTheme.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Currency ─────────────────────────────────────────────
          _Section(title: 'Para Birimi'),
          _Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: AppTheme.goldGlow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.currency_exchange_rounded,
                        color: AppTheme.gold, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Para Birimi',
                          style: TextStyle(
                            color: AppTheme.textPrimary, fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          currency == 'EUR'
                              ? 'Euro (€) olarak gösteriliyor'
                              : 'Dolar (\$) olarak gösteriliyor',
                          style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Toggle pill
                  GestureDetector(
                    onTap: () => ref.read(currencyProvider.notifier).toggle(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceAlt,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _CurrencyTab(label: 'EUR', active: currency == 'EUR'),
                          _CurrencyTab(label: 'USD', active: currency == 'USD'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Connection ────────────────────────────────────────────
          _Section(title: 'Bağlantı'),
          _Card(
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.hub_outlined,
                  iconBg: const Color(0xFFEEF2FF),
                  iconColor: const Color(0xFF6366F1),
                  label: 'SignalR Hub',
                  value: AppConstants.signalRHubUrl,
                ),
                const Divider(color: AppTheme.divider, height: 1, indent: 60),
                _InfoRow(
                  icon: Icons.api_outlined,
                  iconBg: const Color(0xFFECFDF5),
                  iconColor: AppTheme.priceUp,
                  label: 'API Adresi',
                  value: AppConstants.apiBaseUrl,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── About ─────────────────────────────────────────────────
          _Section(title: 'Hakkında'),
          _Card(
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.storefront_outlined,
                  iconBg: AppTheme.goldGlow,
                  iconColor: AppTheme.gold,
                  label: 'Uygulama',
                  value: 'Kaya Juwelier Altın Takip',
                ),
                const Divider(color: AppTheme.divider, height: 1, indent: 60),
                _InfoRow(
                  icon: Icons.data_object_outlined,
                  iconBg: const Color(0xFFF0F9FF),
                  iconColor: const Color(0xFF0EA5E9),
                  label: 'Veri Kaynağı',
                  value: 'Finnhub WebSocket (OANDA)',
                ),
                const Divider(color: AppTheme.divider, height: 1, indent: 60),
                _InfoRow(
                  icon: Icons.bolt_outlined,
                  iconBg: const Color(0xFFFFFBEB),
                  iconColor: Colors.amber,
                  label: 'Güncelleme',
                  value: 'Gerçek zamanlı (saniye bazlı)',
                ),
                const Divider(color: AppTheme.divider, height: 1, indent: 60),
                _InfoRow(
                  icon: Icons.storage_outlined,
                  iconBg: const Color(0xFFF5F3FF),
                  iconColor: const Color(0xFF8B5CF6),
                  label: 'Veri Saklama',
                  value: '1 yıl (MySQL)',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Disclaimer ────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded,
                    color: Colors.amber, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Buradaki fiyatlar yalnızca bilgi amaçlıdır. '
                    'Yatırım tavsiyesi niteliği taşımaz.',
                    style: TextStyle(
                      color: Color(0xFF92400E), fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  const _Section({required this.title});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 2, bottom: 10),
    child: Text(title,
      style: const TextStyle(
        color: AppTheme.textSecondary, fontSize: 12,
        fontWeight: FontWeight.w600, letterSpacing: 0.5,
      ),
    ),
  );
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(16),
      boxShadow: AppTheme.subtleShadow,
    ),
    child: child,
  );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: iconBg, borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(value,
                style: const TextStyle(
                  color: AppTheme.textPrimary, fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _CurrencyTab extends StatelessWidget {
  final String label;
  final bool active;
  const _CurrencyTab({required this.label, required this.active});

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
    decoration: BoxDecoration(
      color: active ? AppTheme.gold : Colors.transparent,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Text(label,
      style: TextStyle(
        color: active ? Colors.white : AppTheme.textSecondary,
        fontSize: 12, fontWeight: FontWeight.w700,
      ),
    ),
  );
}
