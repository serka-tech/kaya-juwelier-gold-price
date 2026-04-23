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
    final range     = ref.watch(chartRangeProvider);
    final karat     = ref.watch(chartKaratProvider);
    final dataAsync = ref.watch(chartDataProvider(range));
    final statsAsync = ref.watch(priceStatsProvider(range.value));

    const karatLabels = {
      ChartKarat.k24:  '24K',
      ChartKarat.k22:  '22K',
      ChartKarat.k18:  '18K',
      ChartKarat.troy: 'Ons',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        // ── Stats row (above chart) ────────────────────────────────────
        statsAsync.when(
          loading: () => const SizedBox(height: 36),
          error:   (e, _) => const SizedBox.shrink(),
          data: (stats) => stats.open == 0
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: StatsRow(stats: stats),
                ),
        ),

        // ── Karat selector ────────────────────────────────────────────
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ChartKarat.values.map((k) {
              final selected = karat == k;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => ref.read(chartKaratProvider.notifier).set(k),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? AppTheme.gold : AppTheme.surfaceAlt,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      karatLabels[k]!,
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : AppTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),

        // ── Chart area ────────────────────────────────────────────────
        SizedBox(
          height: 180,
          child: dataAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(
                  color: AppTheme.gold, strokeWidth: 2),
            ),
            error:   (e, _) => _buildEmpty(),
            data: (points) => points.isEmpty
                ? _buildEmpty()
                : _buildChart(points, karat, range),
          ),
        ),
        const SizedBox(height: 16),

        // ── Range selector ────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ChartRange.values.map((r) {
            final selected = range == r;
            return GestureDetector(
              onTap: () => ref.read(chartRangeProvider.notifier).set(r),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: selected ? AppTheme.gold : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  r.label,
                  style: TextStyle(
                    color: selected ? Colors.white : AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: selected
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildEmpty() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            color: AppTheme.surfaceAlt,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.show_chart_rounded,
              color: AppTheme.textHint, size: 28),
        ),
        const SizedBox(height: 10),
        const Text(
          'Grafik verisi birikiyor...',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
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

    final prices  = spots.map((s) => s.y).toList();
    final minY    = prices.reduce((a, b) => a < b ? a : b);
    final maxY    = prices.reduce((a, b) => a > b ? a : b);
    final pad     = ((maxY - minY) * 0.15).clamp(0.01, double.infinity);
    final isUp    = spots.last.y >= spots.first.y;
    final lineCol = isUp ? AppTheme.priceUp : AppTheme.priceDown;

    String fmtX(int i) {
      if (i < 0 || i >= points.length) return '';
      final t = points[i].t.toLocal();
      return switch (range) {
        ChartRange.h1 || ChartRange.d1 => DateFormat('HH:mm').format(t),
        ChartRange.d5 || ChartRange.m1 => DateFormat('dd/MM').format(t),
        ChartRange.m3 || ChartRange.y1 => DateFormat('MMM').format(t),
      };
    }

    final xInterval =
        (spots.length / 4).ceil().toDouble().clamp(1.0, double.infinity);

    return LineChart(
      LineChartData(
        backgroundColor: AppTheme.surface,
        minY: minY - pad,
        maxY: maxY + pad,
        clipData: const FlClipData.all(),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: ((maxY - minY) / 4).clamp(0.001, double.infinity),
          getDrawingHorizontalLine: (_) => const FlLine(
            color: AppTheme.divider,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 52,
              getTitlesWidget: (value, meta) => Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Text(
                  karat == ChartKarat.troy
                      ? value.toStringAsFixed(0)
                      : value.toStringAsFixed(2),
                  style: const TextStyle(
                    color: AppTheme.textHint, fontSize: 9,
                  ),
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: xInterval,
              getTitlesWidget: (value, meta) {
                final idx = value.round();
                if (idx % xInterval.round() != 0) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    fmtX(idx),
                    style: const TextStyle(
                      color: AppTheme.textHint, fontSize: 9,
                    ),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppTheme.textPrimary,
            tooltipRoundedRadius: 10,
            getTooltipItems: (touchedSpots) => touchedSpots
                .map((s) => LineTooltipItem(
                  karat == ChartKarat.troy
                      ? '€ ${s.y.toStringAsFixed(2)}'
                      : '€ ${s.y.toStringAsFixed(2)}/g',
                  const TextStyle(
                    color: Colors.white, fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ))
                .toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: lineCol,
            barWidth: 2.5,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  lineCol.withValues(alpha: 0.18),
                  lineCol.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 250),
    );
  }
}
