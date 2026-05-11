import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaya_juwelier/core/constants/app_constants.dart';
import 'package:kaya_juwelier/core/theme/app_theme.dart';
import 'package:kaya_juwelier/providers/commission_provider.dart';
import 'package:kaya_juwelier/providers/gold_price_provider.dart';
import 'package:kaya_juwelier/screens/admin/admin_screen.dart';
import 'package:kaya_juwelier/screens/login/login_screen.dart';

class SettingsScreen extends ConsumerWidget {
  /// When [embedded] is true the screen is shown inside HomeScreen's
  /// IndexedStack and therefore must not show its own AppBar/back button.
  final bool embedded;

  const SettingsScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(currencyProvider);

    final body = ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // ── Currency ──────────────────────────────────────────────────
        _Section(title: 'PARA BİRİMİ'),
        _Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                      const SizedBox(height: 2),
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
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.cardBorder),
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
        const SizedBox(height: 24),

        // ── Connection ────────────────────────────────────────────────
        _Section(title: 'BAĞLANTI'),
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
                iconBg: AppTheme.priceUpBg,
                iconColor: AppTheme.priceUp,
                label: 'API Adresi',
                value: AppConstants.apiBaseUrl,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // ── About ─────────────────────────────────────────────────────
        _Section(title: 'HAKKINDA'),
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
                iconBg: const Color(0xFFE0F2FE),
                iconColor: const Color(0xFF0284C7),
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
                iconColor: const Color(0xFF7C3AED),
                label: 'Veri Saklama',
                value: '1 yıl (MySQL)',
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // ── Admin ─────────────────────────────────────────────────────
        _Section(title: 'YÖNETİM'),
        _AdminTile(embedded: embedded),
        const SizedBox(height: 24),

        // ── Disclaimer ────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.goldGlow,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.goldDim.withAlpha(80)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded,
                  color: AppTheme.gold, size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Buradaki fiyatlar yalnızca bilgi amaçlıdır. '
                  'Yatırım tavsiyesi niteliği taşımaz.',
                  style: TextStyle(
                    color: AppTheme.textSecondary, fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );

    if (embedded) return body;

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
      body: body,
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
        color: AppTheme.textHint, fontSize: 10,
        fontWeight: FontWeight.w700, letterSpacing: 1.2,
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
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppTheme.cardBorder),
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
                  color: AppTheme.textHint, fontSize: 11,
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

class _AdminTile extends ConsumerWidget {
  final bool embedded;
  const _AdminTile({required this.embedded});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final token = ref.watch(authProvider).asData?.value;
    final isLoggedIn = token != null;

    return _Card(
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
              child: const Icon(Icons.admin_panel_settings_rounded,
                  color: AppTheme.gold, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Admin Paneli',
                    style: TextStyle(
                      color: AppTheme.textPrimary, fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    isLoggedIn ? 'Giriş yapıldı' : 'Komisyon yönetimi',
                    style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isLoggedIn) ...[
              TextButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AdminScreen())),
                child: const Text('Aç',
                    style: TextStyle(
                        color: AppTheme.gold, fontWeight: FontWeight.w700)),
              ),
              TextButton(
                onPressed: () =>
                    ref.read(authProvider.notifier).logout(),
                child: const Text('Çıkış',
                    style: TextStyle(color: AppTheme.textHint)),
              ),
            ] else
              TextButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const LoginScreen())),
                child: const Text('Giriş Yap',
                    style: TextStyle(
                        color: AppTheme.gold, fontWeight: FontWeight.w700)),
              ),
          ],
        ),
      ),
    );
  }
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
