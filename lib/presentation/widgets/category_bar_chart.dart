import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/shimmer_box.dart';
import '../../core/utils/formatter.dart';
import '../../domain/providers/dashboard_providers.dart';

class CategoryBarChartCard extends ConsumerWidget {
  const CategoryBarChartCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final breakdownAsync = ref.watch(categoryBreakdownProvider);

    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Top Categories 🏆", style: FyniqTextStyles.headingM),
          const SizedBox(height: 24),
          breakdownAsync.when(
            data: (breakdown) {
              if (breakdown.isEmpty) {
                return const Center(child: Text("No expenses tracked yet"));
              }

              final top = breakdown.take(6).toList();
              final maxAmount = top.first.totalAmount;

              return Column(
                children: top.map((cs) {
                  final color = Color(int.parse(cs.colorHex.replaceAll('#', '0xFF')));
                  final ratio = maxAmount > 0 ? cs.totalAmount / maxAmount : 0.0;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        SizedBox(width: 32, child: Text(cs.emoji, style: const TextStyle(fontSize: 18))),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 80,
                          child: Text(
                            cs.categoryName,
                            style: FyniqTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: ratio),
                            duration: (600 + (top.indexOf(cs) * 100)).ms,
                            curve: Curves.easeOutCubic,
                            builder: (_, val, __) => ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: val,
                                minHeight: 10,
                                backgroundColor: FyniqColors.divider,
                                valueColor: AlwaysStoppedAnimation(color),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          FyniqFormatter.formatCurrency(cs.totalAmount),
                          style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const ShimmerBox(width: double.infinity, height: 200),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
    );
  }
}
