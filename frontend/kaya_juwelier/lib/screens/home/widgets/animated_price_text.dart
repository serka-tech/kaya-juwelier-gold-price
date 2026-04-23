import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AnimatedPriceText extends StatelessWidget {
  final double price;
  final TextStyle? style;

  const AnimatedPriceText({super.key, required this.price, this.style});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: price),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        final formatted = NumberFormat('#,##0.00', 'de_DE').format(value);
        return Text(formatted, style: style);
      },
    );
  }
}
