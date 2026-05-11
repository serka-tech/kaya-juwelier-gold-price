import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaya_juwelier/core/theme/app_theme.dart';

class GoldPriceRow extends StatefulWidget {
  final String karat;
  final String fineness;
  final double price;
  final String currencySymbol;
  final String unit;
  final Color accentColor;
  final double? changePercent;
  final List<double> sparkData;

  const GoldPriceRow({
    super.key,
    required this.karat,
    required this.fineness,
    required this.price,
    this.currencySymbol = '€',
    this.unit = 'gram',
    this.accentColor = AppTheme.gold,
    this.changePercent,
    this.sparkData = const [],
  });

  @override
  State<GoldPriceRow> createState() => _GoldPriceRowState();
}

class _GoldPriceRowState extends State<GoldPriceRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _flashCtrl;
  late Animation<Color?> _rowColor;
  double? _prevPrice;
  bool _isUp = true;

  @override
  void initState() {
    super.initState();
    _flashCtrl = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _rowColor = ColorTween(
      begin: Colors.transparent, end: Colors.transparent,
    ).animate(_flashCtrl);
  }

  @override
  void didUpdateWidget(GoldPriceRow old) {
    super.didUpdateWidget(old);
    if (_prevPrice != null && old.price != widget.price) {
      _isUp = widget.price > old.price;
      _rowColor = ColorTween(
        begin: (_isUp ? AppTheme.priceUp : AppTheme.priceDown).withAlpha(20),
        end: Colors.transparent,
      ).animate(CurvedAnimation(parent: _flashCtrl, curve: Curves.easeOut));
      _flashCtrl
        ..reset()
        ..forward();
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
    final changePct = widget.changePercent;

    // Determine spark color
    final sparkUp = widget.sparkData.length >= 2
        ? widget.sparkData.last >= widget.sparkData.first
        : true;
    final sparkColor = sparkUp ? AppTheme.priceUp : AppTheme.priceDown;

    return AnimatedBuilder(
      animation: _rowColor,
      builder: (context, child) => Container(
        color: _rowColor.value ?? Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // ── Karat badge ──────────────────────────────────────────
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: widget.accentColor.withAlpha(18),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: widget.accentColor.withAlpha(50),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  widget.karat
                      .replaceAll(' AYAR', '')
                      .replaceAll(' Ayar', '')
                      .replaceAll('K', ''),
                  style: TextStyle(
                    color: widget.accentColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // ── Name + fineness ──────────────────────────────────────
            SizedBox(
              width: 72,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.karat.toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${widget.fineness} · ${widget.unit}',
                    style: const TextStyle(
                      color: AppTheme.textHint,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),

            // ── Sparkline ────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: widget.sparkData.length >= 4
                    ? SizedBox(
                        height: 36,
                        child: _SparkLine(
                          data: widget.sparkData,
                          color: sparkColor,
                        ),
                      )
                    : const SizedBox(height: 36),
              ),
            ),

            // ── Price + change ───────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${widget.currencySymbol} ${fmt.format(widget.price)}',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 3),
                if (changePct != null)
                  _ChangePill(percent: changePct, isUp: changePct >= 0)
                else if (hasChange)
                  _ChangePill(percent: null, isUp: _isUp)
                else
                  const Text(
                    '—',
                    style: TextStyle(color: AppTheme.textHint, fontSize: 11),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sparkline ─────────────────────────────────────────────────────────────────
class _SparkLine extends StatelessWidget {
  final List<double> data;
  final Color color;

  const _SparkLine({required this.data, required this.color});

  @override
  Widget build(BuildContext context) {
    final spots = data
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    final minY = data.reduce((a, b) => a < b ? a : b);
    final maxY = data.reduce((a, b) => a > b ? a : b);
    final pad = ((maxY - minY) * 0.2).clamp(0.001, double.infinity);

    return LineChart(
      LineChartData(
        minY: minY - pad,
        maxY: maxY + pad,
        clipData: const FlClipData.all(),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(
          leftTitles:   AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:  AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:    AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: color,
            barWidth: 1.8,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  color.withAlpha(40),
                  color.withAlpha(0),
                ],
              ),
            ),
          ),
        ],
      ),
      duration: Duration.zero,
    );
  }
}

// ── Change pill ───────────────────────────────────────────────────────────────
class _ChangePill extends StatelessWidget {
  final double? percent;
  final bool isUp;

  const _ChangePill({this.percent, required this.isUp});

  @override
  Widget build(BuildContext context) {
    final color = isUp ? AppTheme.priceUp : AppTheme.priceDown;
    final bg    = isUp ? AppTheme.priceUpBg : AppTheme.priceDownBg;
    final icon  = isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          if (percent != null)
            Text(
              '${percent! >= 0 ? '+' : ''}${percent!.toStringAsFixed(2)}%',
              style: TextStyle(
                color: color, fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            )
          else
            Text(
              isUp ? 'Arttı' : 'Düştü',
              style: TextStyle(
                color: color, fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}
