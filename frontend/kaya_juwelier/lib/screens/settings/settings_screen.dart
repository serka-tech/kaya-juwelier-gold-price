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
      appBar: AppBar(title: const Text('AYARLAR')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Currency section ──────────────────────────────────────
          _SectionHeader('Para Birimi'),
          _Card(
            child: SwitchListTile(
              title: const Text('USD / EUR',
                  style: TextStyle(color: AppTheme.textPrimary)),
              subtitle: Text(
                currency == 'EUR'
                    ? 'Gram altın fiyatı EUR olarak gösteriliyor'
                    : 'Gram altın fiyatı USD olarak gösteriliyor',
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 12),
              ),
              value: currency == 'USD',
              activeThumbColor: AppTheme.gold,
              activeTrackColor: AppTheme.gold.withAlpha(100),
              onChanged: (_) => ref.read(currencyProvider.notifier).toggle(),
              secondary: Text(
                currency,
                style: TextStyle(
                  color: AppTheme.gold,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Connection section ────────────────────────────────────
          _SectionHeader('Bağlantı'),
          _Card(
            child: Column(
              children: [
                _InfoTile(
                  icon: Icons.hub_outlined,
                  label: 'SignalR Hub',
                  value: AppConstants.signalRHubUrl,
                ),
                const Divider(color: AppTheme.cardBorder, height: 1),
                _InfoTile(
                  icon: Icons.api_outlined,
                  label: 'API Adresi',
                  value: AppConstants.apiBaseUrl,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── About section ─────────────────────────────────────────
          _SectionHeader('Hakkında'),
          _Card(
            child: Column(
              children: [
                _InfoTile(
                  icon: Icons.storefront_outlined,
                  label: 'Uygulama',
                  value: 'Kaya Juwelier Altın Takip',
                ),
                const Divider(color: AppTheme.cardBorder, height: 1),
                _InfoTile(
                  icon: Icons.data_object_outlined,
                  label: 'Veri Kaynağı',
                  value: 'Finnhub WebSocket (OANDA)',
                ),
                const Divider(color: AppTheme.cardBorder, height: 1),
                _InfoTile(
                  icon: Icons.sync_outlined,
                  label: 'Güncelleme Sıklığı',
                  value: 'Gerçek zamanlı (saniye bazlı)',
                ),
                const Divider(color: AppTheme.cardBorder, height: 1),
                _InfoTile(
                  icon: Icons.storage_outlined,
                  label: 'Veri Saklama',
                  value: '1 yıl (MySQL)',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Disclaimer ────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: const Text(
              '⚠️  Buradaki fiyatlar yalnızca bilgi amaçlıdır. '
              'Yatırım tavsiyesi niteliği taşımaz. Kaya Juwelier, '
              'bu fiyatlara dayanılarak yapılan işlemlerden sorumlu değildir.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: AppTheme.gold,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
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
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: child,
      );
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(icon, color: AppTheme.gold, size: 20),
        title: Text(label,
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 12)),
        subtitle: Text(value,
            style: const TextStyle(
                color: AppTheme.textPrimary, fontSize: 13)),
        dense: true,
      );
}
