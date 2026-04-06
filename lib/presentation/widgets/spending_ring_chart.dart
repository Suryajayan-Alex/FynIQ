import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/shimmer_box.dart';
import '../../core/widgets/amount_text.dart';
import '../../domain/providers/dashboard_providers.dart';

class SpendingRingSection extends ConsumerWidget {
  const SpendingRingSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final breakdownAsync = ref.watch(categoryBreakdownProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Spending Breakdown 📊", style: FyniqTextStyles.headingM),
            const SizedBox(height: 16),
            breakdownAsync.when(
              data: (breakdown) {
                if (breakdown.isEmpty) {
                  return Center(
                    child: Column(
                      children: [
                        const Text("💰", style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        Text("No spending yet! 🎉", style: FyniqTextStyles.headingM, textAlign: TextAlign.center),
                        Text("Start tracking to see your breakdown", style: FyniqTextStyles.caption, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    // Donut Chart (fl_chart)
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          centerSpaceRadius: 60,
                          sectionsSpace: 3,
                          sections: breakdown.take(5).map((cs) {
                            final color = Color(int.parse(cs.colorHex.replaceAll('#', '0xFF')));
                            return PieChartSectionData(
                              value: cs.totalAmount,
                              color: color,
                              radius: 50,
                              showTitle: false,
                            );
                          }).toList(),
                          pieTouchData: PieTouchData(enabled: true),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Legend
                    ...breakdown.take(5).map((cs) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Color(int.parse(cs.colorHex.replaceAll('#', '0xFF'))),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text("${cs.emoji} ${cs.categoryName}", style: FyniqTextStyles.body),
                          ),
                          AmountText(amount: cs.totalAmount, fontSize: 14),
                          const SizedBox(width: 8),
                          Text("${cs.percentage.toStringAsFixed(0)}%", style: FyniqTextStyles.caption.copyWith(color: Colors.grey)),
                        ],
                      ),
                    )),
                  ],
                );
              },
              loading: () => const ShimmerBox(width: double.infinity, height: 200),
              error: (err, __) => Text("Error loading breakdown: $err"),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2);
  }
}
