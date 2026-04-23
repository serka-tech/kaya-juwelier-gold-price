import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaya_juwelier/core/theme/app_theme.dart';

class PriceCard extends StatefulWidget {
  final String label;
  final String fineness;
  final double price;
  final Color  accentColor;
  final String currencyLabel;

  const PriceCard({
    super.key,
    required this.label,
    required this.fineness,
    required this.price,
    required this.accentColor,
    this.currencyLabel = 'EUR/g',
  });

  @override
  State<PriceCard> createState() => _PriceCardState();
}

class _PriceCardState extends State<PriceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _flashCtrl;
  late Animation<Color?> _bgColor;
  double? _prevPrice;
  bool _isUp = true;

  @override
  void initState() {
    super.initState();
    _flashCtrl = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _bgColor = ColorTween(
      begin: Colors.transparent, end: Colors.transparent,
    ).animate(_flashCtrl);
  }

  @override
  void didUpdateWidget(PriceCard old) {
    super.didUpdateWidget(old);
    if (_prevPrice != null && old.price != widget.price) {
      _isUp = widget.price > old.price;
      _bgColor = ColorTween(
        begin: (_isUp ? AppTheme.priceUp : AppTheme.priceDown).withAlpha(25),
        end:   Colors.transparent,
      ).animate(CurvedAnimation(parent: _flashCtrl, curve: Curves.easeOut));
      _flashCtrl..reset()..forward();
    }
    _prevPrice = old.price;
  }

  @override
  void dispose() {
    _flashCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00', 'de_DE');
    final hasChange = _prevPrice != null && _prevPrice != widget.price;

    return AnimatedBuilder(
      animation: _bgColor,
      builder: (context, child) => Container(
        decoration: BoxDecoration(
          color: _bgColor.value ?? AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.subtleShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Left accent stripe
              Positioned(
                left: 0, top: 0, bottom: 0,
                child: Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: widget.accentColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                  ),
                ),
              ),
              // Card content
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top row: label + fineness badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.label,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: widget.accentColor.withAlpha(20),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.fineness,
                            style: TextStyle(
                              color: widget.accentColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Price
                    Text(
                      fmt.format(widget.price),
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Bottom row: currency + direction badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.currencyLabel,
                          style: const TextStyle(
                            color: AppTheme.textHint, fontSize: 11,
                          ),
                        ),
                        if (hasChange)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _isUp
                                  ? AppTheme.priceUpBg
                                  : AppTheme.priceDownBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isUp
                                      ? Icons.arrow_upward_rounded
                                      : Icons.arrow_downward_rounded,
                                  color: _isUp
                                      ? AppTheme.priceUp
                                      : AppTheme.priceDown,
                                  size: 10,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  _isUp ? 'Arttı' : 'Düştü',
                                  style: TextStyle(
                                    color: _isUp
                                        ? AppTheme.priceUp
                                        : AppTheme.priceDown,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
