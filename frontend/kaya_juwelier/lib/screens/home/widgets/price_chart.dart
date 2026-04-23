import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kaya_juwelier/core/theme/app_theme.dart';
import 'package:kaya_juwelier/models/chart_point_model.dart';
import 'package:kaya_juwelier/providers/chart_provider.dart';
import 'package:kaya_juwelier/providers/gold_price_provider.dart';
import 'package:kaya_juwelier/screens/home/widgets/stats_row.dart';

class PriceChart extends ConsumerWidget {
  const PriceChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range = ref.watch(chartRangeProvider);
    final karat = ref.watch(chartKaratProvider);
    final dataAsync = ref.watch(chartDataProvider(range));
    final statsAsync = ref.watch(priceStatsProvider(range.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Karat selector ────────────────────────────────────────────
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ChartKarat.values.map((k) {
              final labels = {
                ChartKarat.k24: '24K',
                ChartKarat.k22: '22K',
                ChartKarat.k18: '18K',
                ChartKarat.troy: 'Troy oz',
              };
              final selected = karat == k;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text(labels[k]!),
                  selected: selected,
                  onSelected: (_) =>
                      ref.read(chartKaratProvider.notifier).set(k),
                  selectedColor: AppTheme.gold,
                  labelStyle: TextStyle(
                    color: selected ? Colors.black : AppTheme.textSecondary,
                    fontWeight:
                        selected ? FontWeight.bold : FontWeight.normal,
                  ),
                  backgroundColor: AppTheme.surface,
                  side: BorderSide.none,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),

        // ── Range selector ────────────────────────────────────────────
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ChartRange.values.map((r) {
              final selected = range == r;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: GestureDetector(
                  onTap: () =>
                      ref.read(chartRangeProvider.notifier).set(r),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected ? AppTheme.gold : AppTheme.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      r.label,
                      style: TextStyle(
                        color: selected
                            ? Colors.black
                            : AppTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),

        // ── Chart area ────────────────────────────────────────────────
        SizedBox(
          height: 200,
          child: dataAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppTheme.gold),
            ),
            error: (e, _) => _buildEmpty(),
            data: (points) =>
                points.isEmpty ? _buildEmpty() : _buildChart(points, karat, range),
          ),
        ),

        // ── Stats row ─────────────────────────────────────────────────
        statsAsync.when(
          loading: () => const SizedBox(height: 40),
          error: (e, _) => const SizedBox.shrink(),
          data: (stats) => stats.open == 0
              ? const SizedBox.shrink()
              : StatsRow(stats: stats),
        ),
      ],
    );
  }

  Widget _buildEmpty() => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, color: AppTheme.textSecondary, size: 36),
            SizedBox(height: 8),
            Text(
              'Grafik verisi henüz yok\n(Veri birikiyor...)',
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
          ],
        ),
      );

  Widget _buildChart(
      List<ChartPoint> points, ChartKarat karat, ChartRange range) {
    final spots = points.asMap().entries.map((e) {
      final y = switch (karat) {
        ChartKarat.k24  => e.value.price24K,
        ChartKarat.k22  => e.value.price22K,
        ChartKarat.k18  => e.value.price18K,
        ChartKarat.troy => e.value.priceTroyOz,
      };
      return FlSpot(e.key.toDouble(), y);
    }).toList();

    final prices = spots.map((s) => s.y).toList();
    final minY = prices.reduce((a, b) => a < b ? a : b);
    final maxY = prices.reduce((a, b) => a > b ? a : b);
    final padding = ((maxY - minY) * 0.12).clamp(0.01, double.infinity);

    // Determine line color based on first vs last price
    final lineColor = spots.last.y >= spots.first.y
        ? AppTheme.priceUp
        : AppTheme.priceDown;

    String formatX(int index) {
      if (index < 0 || index >= points.length) return '';
      final t = points[index].t.toLocal();
      return switch (range) {
        ChartRange.h1 => DateFormat('HH:mm').format(t),
        ChartRange.d1 => DateFormat('HH:mm').format(t),
        ChartRange.d5 => DateFormat('dd/MM').format(t),
        ChartRange.m1 => DateFormat('dd/MM').format(t),
        ChartRange.m3 => DateFormat('MMM dd').format(t),
        ChartRange.y1 => DateFormat('MMM yy').format(t),
      };
    }

    final xInterval =
        (spots.length / 5).ceil().toDouble().clamp(1.0, double.infinity);

    return LineChart(
      LineChartData(
        backgroundColor: AppTheme.surface,
        minY: minY - padding,
        maxY: maxY + padding,
        clipData: const FlClipData.all(),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: ((maxY - minY) / 4).clamp(0.001, double.infinity),
          getDrawingHorizontalLine: (_) => const FlLine(
            color: Color(0x22FFFFFF),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 56,
              getTitlesWidget: (value, meta) => Text(
                karat == ChartKarat.troy
                    ? value.toStringAsFixed(0)
                    : value.toStringAsFixed(2),
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 9),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 20,
              interval: xInterval,
              getTitlesWidget: (value, meta) {
                final idx = value.round();
                if (idx % xInterval.round() != 0) return const SizedBox();
                return Text(
                  formatX(idx),
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 9),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => const Color(0xFF2A2A3E),
            getTooltipItems: (touchedSpots) => touchedSpots
                .map((s) => LineTooltipItem(
                      '€ ${s.y.toStringAsFixed(karat == ChartKarat.troy ? 2 : 4)}',
                      const TextStyle(
                          color: AppTheme.gold,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ))
                .toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: lineColor,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  lineColor.withValues(alpha: 0.25),
                  lineColor.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 300),
    );
  }
}
