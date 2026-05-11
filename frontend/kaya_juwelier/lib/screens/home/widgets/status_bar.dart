import 'package:flutter/material.dart';
import 'package:kaya_juwelier/core/theme/app_theme.dart';
import 'package:kaya_juwelier/services/signalr_service.dart';

class StatusBar extends StatelessWidget {
  final ConnectionStatus status;
  const StatusBar({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (dotColor, bgColor, label) = switch (status) {
      ConnectionStatus.live         => (AppTheme.priceUp,   AppTheme.priceUpBg,     'Canlı'),
      ConnectionStatus.demo         => (Colors.amber,       const Color(0xFFFFFBEB), 'Demo'),
      ConnectionStatus.reconnecting => (Colors.orange,      const Color(0xFFFFF7ED), 'Bağlanıyor'),
      ConnectionStatus.error        => (AppTheme.priceDown, AppTheme.priceDownBg,   'Hata'),
      ConnectionStatus.connecting   => (AppTheme.textHint,  AppTheme.surfaceAlt,    'Bağlanıyor'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: dotColor.withAlpha(50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6, height: 6,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(label,
            style: TextStyle(
              color: dotColor, fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
