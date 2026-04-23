import 'package:flutter/material.dart';
import 'package:kaya_juwelier/services/signalr_service.dart';

class StatusBar extends StatelessWidget {
  final ConnectionStatus status;
  const StatusBar({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      ConnectionStatus.live        => (Colors.green,  'Canlı veri'),
      ConnectionStatus.demo        => (Colors.amber,  'Demo modu'),
      ConnectionStatus.reconnecting => (Colors.orange, 'Yeniden bağlanıyor...'),
      ConnectionStatus.error       => (Colors.red,    'Bağlantı hatası'),
      ConnectionStatus.connecting  => (Colors.grey,   'Bağlanıyor...'),
    };

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: color.withAlpha(128), blurRadius: 6)],
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: color, fontSize: 13)),
      ],
    );
  }
}
