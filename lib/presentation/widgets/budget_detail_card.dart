import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/utils/formatter.dart';
import '../../data/models/budget_progress.dart';

class BudgetDetailCard extends StatelessWidget {
  final BudgetProgress bp;
  
  const BudgetDetailCard({super.key, required this.bp});

  @override
  Widget build(BuildContext context) {
    final categoryColor = Color(int.parse(bp.category.colorHex.replaceAll('#', '0xFF')));
    final color = bp.percentage < 70 
        ? FyniqColors.success 
        : bp.percentage < 90 
            ? FyniqColors.warning 
            : FyniqColors.highlightCTA;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Text(bp.category.emoji, style: const TextStyle(fontSize: 20))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bp.budget.name,
                      style: FyniqTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(bp.category.name, style: FyniqTextStyles.caption.copyWith(color: Colors.grey)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: FyniqColors.cardSurface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: FyniqColors.divider),
                ),
                child: Text(
                  bp.budget.period == 'weekly' ? "Weekly" : "Monthly",
                  style: FyniqTextStyles.caption.copyWith(fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: bp.percentage / 100),
            duration: 800.ms,
            curve: Curves.easeOutCubic,
            builder: (_, val, __) {
              return Stack(
                children: [
                  Container(height: 8, decoration: BoxDecoration(color: FyniqColors.divider, borderRadius: BorderRadius.circular(4))),
                  AnimatedContainer(
                    duration: 300.ms,
                    width: (MediaQuery.of(context).size.width - 96) * val.clamp(0, 1),
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: bp.percentage > 90 
                        ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 6)] 
                        : [],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${bp.percentage.toStringAsFixed(0)}% used",
                style: FyniqTextStyles.caption.copyWith(color: Colors.grey),
              ),
              Text(
                bp.isOverBudget
                    ? "₹${(bp.spentAmount - bp.budget.limitAmount).toStringAsFixed(0)} over"
                    : "₹${bp.remainingAmount.toStringAsFixed(0)} left",
                style: FyniqTextStyles.caption.copyWith(
                    color: bp.isOverBudget ? FyniqColors.warning : FyniqColors.success,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                FyniqFormatter.formatCurrency(bp.spentAmount),
                style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w700, color: FyniqColors.highlightCTA),
              ),
              Text(" / ", style: FyniqTextStyles.caption.copyWith(color: Colors.grey)),
              Text(
                FyniqFormatter.formatCurrency(bp.budget.limitAmount),
                style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
