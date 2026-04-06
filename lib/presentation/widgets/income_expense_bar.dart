import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/shimmer_box.dart';
import '../../core/utils/formatter.dart';
import '../../domain/providers/dashboard_providers.dart';

class IncomeExpenseBar extends ConsumerWidget {
  const IncomeExpenseBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(spendingSummaryProvider);

    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Income vs Spending 💹", style: FyniqTextStyles.headingM),
          const SizedBox(height: 24),
          summaryAsync.when(
            data: (s) {
              final ratio = s.totalIncome > 0 ? (s.totalExpense / s.totalIncome).clamp(0.0, 1.0) : (s.totalExpense > 0 ? 1.0 : 0.0);

              return Column(
                children: [
                   // Income bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Income", style: FyniqTextStyles.body),
                      Text(
                        FyniqFormatter.formatCurrency(s.totalIncome),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: FyniqColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: const LinearProgressIndicator(
                      value: 1.0,
                      minHeight: 12,
                      backgroundColor: FyniqColors.divider,
                      color: FyniqColors.success,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Expense bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Spent", style: FyniqTextStyles.body),
                      Text(
                        FyniqFormatter.formatCurrency(s.totalExpense),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: FyniqColors.highlightCTA,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: ratio),
                    duration: 800.ms,
                    curve: Curves.easeOutCubic,
                    builder: (_, val, __) => ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: val,
                        minHeight: 12,
                        backgroundColor: FyniqColors.divider,
                        color: FyniqColors.highlightCTA,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Summary text
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ratio > 1
                          ? FyniqColors.warning.withOpacity(0.15)
                          : FyniqColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      ratio >= 1 && s.totalExpense > s.totalIncome
                          ? "⚠️ You spent more than you earned this period"
                          : "✅ You spent ${(ratio * 100).toStringAsFixed(0)}% of your income",
                      style: FyniqTextStyles.caption.copyWith(
                        color: ratio >= 1 && s.totalExpense > s.totalIncome ? FyniqColors.warning : FyniqColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => const ShimmerBox(width: double.infinity, height: 100),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
    );
  }
}
