import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/fyniq_scaffold.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/shimmer_box.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/utils/formatter.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../domain/providers/database_providers.dart';
import '../../../domain/providers/budget_providers.dart';
import '../../widgets/budget_detail_card.dart';
import '../../widgets/error_card.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FyniqScaffold(
      appBar: AppBar(
        title: Text("Budgets 🎯", style: FyniqTextStyles.headingM),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.add, color: FyniqColors.primaryAccent),
            tooltip: 'Add new budget',
            onPressed: () {
              HapticFeedback.lightImpact();
              context.push('/add-budget');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: FyniqColors.primaryAccent,
          backgroundColor: FyniqColors.cardSurface,
          onRefresh: () async {
            HapticFeedback.mediumImpact();
            ref.invalidate(budgetProgressAllProvider);
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(child: _OverallSummaryCard()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                  child: Text("Your Budgets", style: FyniqTextStyles.headingM),
                ),
              ),
              const _BudgetList(),
              const SliverToBoxAdapter(child: SizedBox(height: 140)),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverallSummaryCard extends ConsumerWidget {
  const _OverallSummaryCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(budgetProgressAllProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Semantics(
        label: 'Overall Budget Health Summary',
        child: GlassCard(
          padding: const EdgeInsets.all(24),
          child: progressAsync.when(
            data: (list) {
              if (list.isEmpty) return const _EmptyBudgets();

              final totalLimit = list.fold(0.0, (s, bp) => s + bp.budget.limitAmount);
              final totalSpent = list.fold(0.0, (s, bp) => s + bp.spentAmount);
              final overallPct = totalLimit > 0 ? (totalSpent / totalLimit * 100).clamp(0, 100).toDouble() : 0.0;

              final color = overallPct < 70
                  ? FyniqColors.success
                  : overallPct < 90
                      ? FyniqColors.warning
                      : FyniqColors.highlightCTA;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Overall Budget", style: FyniqTextStyles.headingM),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "${overallPct.toStringAsFixed(0)}%",
                          style: FyniqTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: overallPct / 100),
                    duration: 1000.ms,
                    curve: Curves.easeOutCubic,
                    builder: (_, val, __) => ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: val,
                        minHeight: 14,
                        backgroundColor: FyniqColors.divider,
                        valueColor: AlwaysStoppedAnimation(color),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Total Budget", style: FyniqTextStyles.caption.copyWith(color: Colors.grey)),
                          Text(FyniqFormatter.formatCurrency(totalLimit),
                              style: FyniqTextStyles.body.copyWith(fontWeight: FontWeight.w700, fontSize: 18)),
                        ],
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("Total Spent", style: FyniqTextStyles.caption.copyWith(color: Colors.grey)),
                          Text(FyniqFormatter.formatCurrency(totalSpent),
                              style: FyniqTextStyles.body.copyWith(
                                  fontWeight: FontWeight.w700, fontSize: 18, color: FyniqColors.highlightCTA)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    overallPct < 70
                        ? "You're outsmarting your spending 🟢"
                        : overallPct < 90
                            ? "Getting close ⚠️ Slow down a bit"
                            : "Whoa, you've crossed the limit 🚨",
                    style: FyniqTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w600),
                  ),
                ],
              );
            },
            loading: () => const ShimmerBox(width: double.infinity, height: 160),
            error: (e, __) => ErrorCard(message: e.toString()),
          ),
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }
}

class _BudgetList extends ConsumerWidget {
  const _BudgetList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(budgetProgressAllProvider);

    return progressAsync.when(
      data: (list) {
        if (list.isEmpty) return const SliverToBoxAdapter(child: _EmptyBudgetsState());

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (ctx, i) {
              final bp = list[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                child: Dismissible(
                  key: Key(bp.budget.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    decoration: BoxDecoration(
                      color: FyniqColors.highlightCTA.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Iconsax.trash, color: FyniqColors.highlightCTA),
                  ),
                  confirmDismiss: (_) {
                    HapticFeedback.vibrate();
                    return showDialog<bool>(
                      context: context,
                      builder: (dCtx) => AlertDialog(
                        backgroundColor: FyniqColors.cardSurface,
                        title: Text("Delete Budget?", style: FyniqTextStyles.headingM),
                        content: const Text("This can't be undone. You sure?", style: TextStyle(color: Colors.white)),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(dCtx, false), child: const Text("Cancel")),
                          TextButton(
                            onPressed: () => Navigator.pop(dCtx, true),
                            style: TextButton.styleFrom(foregroundColor: FyniqColors.highlightCTA),
                            child: const Text("Delete"),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (_) async {
                    HapticFeedback.heavyImpact();
                    await ref.read(budgetRepositoryProvider).deleteBudget(bp.budget.id);
                    if (context.mounted) {
                      FyniqSnackbar.show(context, "Budget deleted 🗑️", isError: true);
                    }
                    ref.invalidate(budgetProgressAllProvider);
                  },
                  child: Semantics(
                    label: 'Budget for ${bp.category.name}: ${bp.percentage.toStringAsFixed(0)}% used',
                    child: BudgetDetailCard(bp: bp),
                  ),
                ),
              ).animate(delay: (i * 100).ms).fadeIn().slideX(begin: 0.1);
            },
            childCount: list.length,
          ),
        );
      },
      loading: () => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(children: List.generate(3, (i) => const ShimmerBox(width: double.infinity, height: 100))),
        ),
      ),
      error: (e, __) => SliverToBoxAdapter(child: ErrorCard(message: e.toString())),
    );
  }
}

class _EmptyBudgets extends StatelessWidget {
  const _EmptyBudgets();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("🎯", style: TextStyle(fontSize: 56))
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .moveY(begin: -8, end: 8, duration: 1500.ms, curve: Curves.easeInOut),
        const SizedBox(height: 16),
        Text("No active budgets", style: FyniqTextStyles.headingM),
        const SizedBox(height: 8),
        Text("Track limits per category to stay in control.",
            style: FyniqTextStyles.caption.copyWith(color: Colors.grey), textAlign: TextAlign.center),
      ],
    );
  }
}

class _EmptyBudgetsState extends StatelessWidget {
  const _EmptyBudgetsState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(48.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("🎯", style: TextStyle(fontSize: 80))
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveY(begin: -8, end: 8, duration: 1500.ms, curve: Curves.easeInOut),
          const SizedBox(height: 32),
          Text("No budgets yet.", style: FyniqTextStyles.headingL, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(
            "Set limits per category and\nFyniq will keep you on track.",
            style: FyniqTextStyles.body.copyWith(color: FyniqColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          GradientButton(
            text: "Create First Budget",
            onPressed: () {
              HapticFeedback.mediumImpact();
              context.push('/add-budget');
            },
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}
