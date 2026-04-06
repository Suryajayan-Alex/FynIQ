import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/shimmer_box.dart';
import '../../core/widgets/amount_text.dart';
import '../../domain/providers/dashboard_providers.dart';

class BalanceHeroCard extends ConsumerWidget {
  const BalanceHeroCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visible = ref.watch(balanceVisibleProvider);
    final summaryAsync = ref.watch(spendingSummaryProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                FyniqColors.primaryAccent.withOpacity(0.1),
                FyniqColors.highlightCTA.withOpacity(0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Total Balance", style: FyniqTextStyles.caption.copyWith(color: Colors.grey)),
                  GestureDetector(
                    onTap: () => ref.read(balanceVisibleProvider.notifier).state = !visible,
                    child: Icon(visible ? Iconsax.eye : Iconsax.eye_slash, color: Colors.grey, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              summaryAsync.when(
                data: (s) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedSwitcher(
                      duration: 300.ms,
                      transitionBuilder: (child, anim) => RotationTransition(
                        turns: Tween<double>(begin: 0.05, end: 0.0).animate(anim),
                        child: FadeTransition(opacity: anim, child: child),
                      ),
                      child: AmountText(
                        key: ValueKey(visible),
                        amount: s.netBalance,
                        fontSize: 40,
                        isHidden: !visible,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s.netBalance >= 0 ? "You're outsmarting your spending 🟢" : "Whoa, watch that spending 👀",
                      style: FyniqTextStyles.caption.copyWith(
                        color: s.netBalance >= 0 ? FyniqColors.success : FyniqColors.warning,
                      ),
                    ),
                  ],
                ),
                loading: () => const ShimmerBox(width: 200, height: 48, borderRadius: 12),
                error: (err, __) => Text("Error loading balance: $err"),
              ),
              const SizedBox(height: 12),
              const Divider(color: FyniqColors.divider),
              const SizedBox(height: 12),
              Row(
                children: [
                   _buildSubAmount(
                    label: "Income",
                    icon: Iconsax.arrow_down,
                    color: FyniqColors.success,
                    amount: summaryAsync.when(data: (s) => s.totalIncome, loading: () => 0, error: (_, __) => 0),
                    visible: visible,
                    loading: summaryAsync.isLoading,
                  ),
                  Container(width: 1, height: 40, color: FyniqColors.divider),
                  const SizedBox(width: 24),
                  _buildSubAmount(
                    label: "Spent",
                    icon: Iconsax.arrow_up,
                    color: FyniqColors.highlightCTA,
                    amount: summaryAsync.when(data: (s) => s.totalExpense, loading: () => 0, error: (_, __) => 0),
                    visible: visible,
                    loading: summaryAsync.isLoading,
                    crossAlign: CrossAxisAlignment.start,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2);
  }

  Widget _buildSubAmount({
    required String label,
    required IconData icon,
    required Color color,
    required double amount,
    required bool visible,
    required bool loading,
    CrossAxisAlignment crossAlign = CrossAxisAlignment.start,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: crossAlign,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(label, style: FyniqTextStyles.caption),
            ],
          ),
          const SizedBox(height: 4),
          if (loading)
            const ShimmerBox(width: 80, height: 24)
          else
            AnimatedSwitcher(
              duration: 300.ms,
              child: AmountText(
                key: ValueKey(visible),
                amount: amount,
                fontSize: 20,
                color: color,
                isHidden: !visible,
              ),
            ),
        ],
      ),
    );
  }
}
