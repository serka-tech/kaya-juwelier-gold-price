import 'package:flutter/material.dart';
import 'package:kaya_juwelier/core/theme/app_theme.dart';
import 'package:kaya_juwelier/screens/home/widgets/animated_price_text.dart';

class PriceCard extends StatefulWidget {
  final String label;
  final String fineness;
  final double price;
  final Color  accentColor;
  final String currencyLabel; // e.g. "EUR / gram"

  const PriceCard({
    super.key,
    required this.label,
    required this.fineness,
    required this.price,
    required this.accentColor,
    this.currencyLabel = 'EUR / gram',
  });

  @override
  State<PriceCard> createState() => _PriceCardState();
}

class _PriceCardState extends State<PriceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _flashController;
  late Animation<Color?> _flashColor;
  double? _prevPrice;
  bool _isUp = true;

  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _flashColor = ColorTween(begin: Colors.transparent, end: Colors.transparent)
        .animate(_flashController);
  }

  @override
  void didUpdateWidget(PriceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_prevPrice != null && oldWidget.price != widget.price) {
      _isUp = widget.price > oldWidget.price;
      _flashColor = ColorTween(
        begin: (_isUp ? AppTheme.priceUp : AppTheme.priceDown).withAlpha(80),
        end:   Colors.transparent,
      ).animate(CurvedAnimation(parent: _flashController, curve: Curves.easeOut));
      _flashController
        ..reset()
        ..forward();
    }
    _prevPrice = oldWidget.price;
  }

  @override
  void dispose() {
    _flashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _flashColor,
      builder: (context, child) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: _flashColor.value,
        ),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row: label + fineness badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        widget.label,
                        style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        border: Border.all(color: widget.accentColor),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(widget.fineness,
                          style: TextStyle(
                              color: widget.accentColor, fontSize: 10)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Price row with change arrow
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: AnimatedPriceText(
                        price: widget.price,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    if (_prevPrice != null && _prevPrice != widget.price)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Icon(
                          _isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                          color: _isUp ? AppTheme.priceUp : AppTheme.priceDown,
                          size: 20,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 2),
                Text(
                  widget.currencyLabel,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
