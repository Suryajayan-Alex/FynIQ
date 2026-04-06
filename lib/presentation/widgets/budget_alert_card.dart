import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import '../../data/models/budget_progress.dart';

class BudgetAlertCard extends StatelessWidget {
  final BudgetProgress bp;
  const BudgetAlertCard({super.key, required this.bp});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(bp.category.emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    bp.category.name,
                    style: FyniqTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: bp.percentage / 100),
              duration: 800.ms,
              curve: Curves.easeOutCubic,
              builder: (ctx, val, _) => ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: val.clamp(0.0, 1.0),
                  backgroundColor: FyniqColors.divider,
                  valueColor: AlwaysStoppedAnimation(
                    bp.percentage < 70
                        ? FyniqColors.success
                        : bp.percentage < 90
                            ? FyniqColors.warning
                            : FyniqColors.highlightCTA,
                  ),
                  minHeight: 8,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "${bp.percentage.toStringAsFixed(0)}% used",
              style: FyniqTextStyles.caption.copyWith(
                color: bp.percentage > 90 ? FyniqColors.highlightCTA : FyniqColors.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              bp.isOverBudget
                  ? "₹${(bp.spentAmount - bp.budget.limitAmount).toStringAsFixed(0)} over 🚨"
                  : "₹${bp.remainingAmount.toStringAsFixed(0)} left ✅",
              style: FyniqTextStyles.caption.copyWith(
                color: bp.isOverBudget ? FyniqColors.warning : FyniqColors.success,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
