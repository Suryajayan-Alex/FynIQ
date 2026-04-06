import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/shimmer_box.dart';
import '../../core/utils/formatter.dart';
import '../../domain/providers/analytics_providers.dart';

class TrendLineChart extends ConsumerWidget {
  const TrendLineChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendAsync = ref.watch(spendingTrendProvider);

    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Spending Trend 📈", style: FyniqTextStyles.headingM),
          const SizedBox(height: 24),
          trendAsync.when(
            data: (daily) {
              if (daily.isEmpty) {
                return const Center(child: Text("No data yet for this period"));
              }

              final spots = daily.asMap().entries.map((e) =>
                FlSpot(e.key.toDouble(), e.value.totalExpense)).toList();

              return SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        curveSmoothness: 0.3,
                        color: FyniqColors.primaryAccent,
                        barWidth: 3,
                        dotData: FlDotData(
                          getDotPainter: (spot, percent, barData, index) =>
                            FlDotCirclePainter(
                              radius: 4,
                              color: FyniqColors.primaryAccent,
                              strokeColor: Colors.white,
                              strokeWidth: 2,
                            ),
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              FyniqColors.primaryAccent.withOpacity(0.3),
                              FyniqColors.primaryAccent.withOpacity(0.0),
                            ],
                          ),
                        ),
                      ),
                    ],
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: max(1, daily.length / 5).toDouble(),
                          getTitlesWidget: (val, meta) {
                            if (val.toInt() >= daily.length) return const SizedBox();
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                DateFormat('d').format(daily[val.toInt()].date),
                                style: FyniqTextStyles.caption.copyWith(color: Colors.grey),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (_) => FyniqColors.cardSurface,
                        getTooltipItems: (touchedSpots) => touchedSpots.map((s) =>
                          LineTooltipItem(
                            FyniqFormatter.formatCurrency(s.y),
                            GoogleFonts.spaceGrotesk(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ).toList(),
                      ),
                    ),
                  ),
                ),
              );
            },
            loading: () => const ShimmerBox(width: double.infinity, height: 200),
            error: (_, __) => const Text("Error loading trend"),
          ),
        ],
      ),
    );
  }
}
