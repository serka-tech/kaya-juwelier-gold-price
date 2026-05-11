import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kaya_juwelier/core/theme/app_theme.dart';
import 'package:kaya_juwelier/providers/upload_provider.dart';

class AppDrawer extends ConsumerWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const AppDrawer({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logoUrl = ref.watch(uploadManifestProvider).asData?.value.fullLogoUrl();
    return Drawer(
      backgroundColor: AppTheme.surface,
      child: Column(
        children: [
          // ── Header ────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
                24, MediaQuery.of(context).padding.top + 24, 24, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFF8E8), Color(0xFFFFF0C0)],
              ),
              border: Border(
                bottom: BorderSide(color: AppTheme.divider, width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                logoUrl != null
                    ? Image.network(
                        logoUrl,
                        height: 44,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => SvgPicture.asset(
                          'assets/juvkaya-yataylogo.svg',
                          height: 44,
                          fit: BoxFit.contain,
                        ),
                      )
                    : SvgPicture.asset(
                        'assets/juvkaya-yataylogo.svg',
                        height: 44,
                        fit: BoxFit.contain,
                      ),
                const SizedBox(height: 12),
                const Text('Altın Fiyat Takip',
                  style: TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // ── Menu items ────────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                _DrawerItem(
                  icon: Icons.show_chart_rounded,
                  label: 'Altın Fiyatları',
                  selected: selectedIndex == 0,
                  onTap: () { onTap(0); Navigator.pop(context); },
                ),
                _DrawerItem(
                  icon: Icons.candlestick_chart_outlined,
                  label: 'Fiyat Grafiği',
                  selected: selectedIndex == 1,
                  onTap: () { onTap(1); Navigator.pop(context); },
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Divider(color: AppTheme.divider),
                ),
                _DrawerItem(
                  icon: Icons.tune_rounded,
                  label: 'Ayarlar',
                  selected: selectedIndex == 2,
                  onTap: () { onTap(2); Navigator.pop(context); },
                ),
              ],
            ),
          ),

          // ── Footer ────────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppTheme.divider)),
            ),
            padding: EdgeInsets.fromLTRB(
                20, 12, 20, MediaQuery.of(context).padding.bottom + 16),
            child: Row(
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.priceUp,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Finnhub WebSocket · Canlı',
                  style: TextStyle(
                    color: AppTheme.textHint, fontSize: 11,
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

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: selected ? AppTheme.goldGlow : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected
                    ? AppTheme.gold.withAlpha(80)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: selected ? AppTheme.gold : AppTheme.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? AppTheme.gold : AppTheme.textSecondary,
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
                if (selected) ...[
                  const Spacer(),
                  Container(
                    width: 6, height: 6,
                    decoration: const BoxDecoration(
                      color: AppTheme.gold,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
