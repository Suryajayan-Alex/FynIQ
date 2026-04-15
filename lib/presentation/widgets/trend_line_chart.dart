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
import '../../domain/providers/dashboard_providers.dart';

class TrendLineChart extends ConsumerWidget {
  const TrendLineChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendAsync = ref.watch(spendingTrendProvider);
    final period = ref.watch(selectedPeriodProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        trendAsync.when(
          data: (daily) {
            if (daily.isEmpty) {
              return const SizedBox(
                height: 250,
                child: Center(child: Text("No data yet for this period", style: TextStyle(color: FyniqColors.textSecondary))),
              );
            }

            final spots = daily.asMap().entries.map((e) =>
              FlSpot(e.key.toDouble(), e.value.totalExpense)).toList();

            return Container(
              height: 250,
              width: double.infinity,
              padding: const EdgeInsets.only(top: 40, bottom: 0),
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      curveSmoothness: 0.4,
                      color: Colors.white, // High contrast line like image
                      barWidth: 2.5,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: Colors.black,
                        ),
                        checkToShowDot: (spot, barData) => false, // Only show on touch
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.white.withOpacity(0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
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
                        reservedSize: 32,
                        interval: _getInterval(daily.length, period),
                        getTitlesWidget: (val, meta) {
                          if (val.toInt() >= daily.length || val.toInt() < 0) return const SizedBox();
                          return Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Text(
                              _getLabel(daily[val.toInt()].date, period),
                              style: FyniqTextStyles.caption.copyWith(
                                color: FyniqColors.textSecondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  lineTouchData: LineTouchData(
                    getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
                      return spotIndexes.map((spotIndex) {
                        return TouchedSpotIndicatorData(
                          FlLine(
                            color: Colors.white.withOpacity(0.2),
                            strokeWidth: 1.5,
                            dashArray: [5, 5],
                          ),
                          FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                              radius: 6,
                              color: Colors.black,
                              strokeWidth: 3,
                              strokeColor: Colors.white,
                            ),
                          ),
                        );
                      }).toList();
                    },
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => Colors.white,
                      tooltipRoundedRadius: 8,
                      tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      getTooltipItems: (touchedSpots) => touchedSpots.map((s) =>
                        LineTooltipItem(
                          FyniqFormatter.formatCurrency(s.y),
                          GoogleFonts.plusJakartaSans(
                            color: Colors.black,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ).toList(),
                    ),
                  ),
                ),
              ),
            );
          },
          loading: () => const ShimmerBox(width: double.infinity, height: 250),
          error: (_, __) => const Text("Error loading trend"),
        ),
      ],
    );
  }

  double _getInterval(int count, String period) {
    if (period == 'week') return 1;
    if (period == 'month') return 5;
    if (period == 'year') return 1;
    return max(1, count / 5).toDouble();
  }

  String _getLabel(DateTime date, String period) {
    if (period == 'week') return DateFormat('E').format(date);
    if (period == 'month') return DateFormat('d').format(date);
    if (period == 'year') return DateFormat('MMM').format(date);
    return DateFormat('d').format(date);
  }
}
