import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/fyniq_scaffold.dart';
import '../../../core/widgets/shimmer_box.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/utils/formatter.dart';
import '../../../domain/providers/dashboard_providers.dart';
import '../../widgets/balance_hero_card.dart';
import '../../widgets/budget_alert_card.dart';
import '../../widgets/transaction_list_tile.dart';
import '../../widgets/error_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userNameAsync = ref.watch(userNameProvider);

    return FyniqScaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: FyniqColors.primaryAccent,
          backgroundColor: FyniqColors.cardSurface,
          onRefresh: () async {
            HapticFeedback.mediumImpact();
            ref.invalidate(spendingSummaryProvider);
            ref.invalidate(recentTransactionsProvider);
            ref.invalidate(categoryBreakdownProvider);
            ref.invalidate(budgetProgressListProvider);
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Yo 👋", style: FyniqTextStyles.caption),
                          const SizedBox(height: 4),
                          userNameAsync.when(
                            data: (name) => Text(
                              name ?? "Finance Ninja",
                              style: FyniqTextStyles.headingM,
                            ),
                            loading: () => const ShimmerBox(width: 120, height: 24),
                            error: (_, __) => Text("Friend", style: FyniqTextStyles.headingM),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Iconsax.notification, color: Colors.white70),
                        onPressed: () => context.push('/notifications'),
                      ),
                    ],
                  ),
                ),
              ),

              // Period Selector
              const SliverToBoxAdapter(child: _PeriodSelector()),

              // Hero Card
              const SliverToBoxAdapter(child: BalanceHeroCard()),

              // Budget Alerts (Sliding Row)
              const SliverToBoxAdapter(child: _BudgetAlertsRow()),

              // Recent Transactions Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Recent Activity", style: FyniqTextStyles.headingM),
                      TextButton(
                        onPressed: () => context.push('/analytics'),
                        child: const Text("See All", style: TextStyle(color: FyniqColors.primaryAccent)),
                      ),
                    ],
                  ),
                ),
              ),

              // Transactions List
              const _RecentTransactionsList(),

              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedback.heavyImpact();
          context.push('/add-transaction');
        },
        backgroundColor: FyniqColors.primaryAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Iconsax.add, color: Colors.white, size: 28),
      ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
            begin: const Offset(1, 1),
            end: const Offset(1.1, 1.1),
            duration: 2000.ms,
            curve: Curves.easeInOut,
          ),
    );
  }
}

class _RecentTransactionsList extends ConsumerWidget {
  const _RecentTransactionsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(recentTransactionsProvider);
    final categoriesAsync = ref.watch(allCategoriesProvider);

    return transactionsAsync.when(
      data: (list) {
        if (list.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(48.0),
              child: Column(
                children: [
                  const Text("👻", style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 16),
                  Text("No transactions yet", style: FyniqTextStyles.body.copyWith(color: Colors.grey)),
                  const SizedBox(height: 24),
                  GradientButton(
                    text: "Log First Expense",
                    onPressed: () => context.push('/add-transaction'),
                    width: 200,
                  ),
                ],
              ),
            ),
          );
        }

        return categoriesAsync.when(
          data: (cats) {
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final tx = list[index];
                  final cat = cats.firstWhere((c) => c.id == tx.categoryId, orElse: () => cats.first);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
                    child: TransactionListTile(
                      transaction: tx,
                      category: cat,
                      onTap: () => context.push('/transaction-detail/${tx.id}'),
                    ),
                  ).animate(delay: (index * 100).ms).fadeIn().slideX(begin: 0.1);
                },
                childCount: list.length,
              ),
            );
          },
          loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
          error: (e, __) => SliverToBoxAdapter(child: ErrorCard(message: e.toString())),
        );
      },
      loading: () => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(children: List.generate(3, (i) => const ShimmerBox(width: double.infinity, height: 80))),
        ),
      ),
      error: (e, __) => SliverToBoxAdapter(child: ErrorCard(message: e.toString())),
    );
  }
}

class _BudgetAlertsRow extends ConsumerWidget {
  const _BudgetAlertsRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(budgetProgressListProvider);

    return progressAsync.when(
      data: (list) {
        final alerts = list.where((p) => p.percentage >= 75).toList();
        if (alerts.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: alerts.length,
            itemBuilder: (context, index) => BudgetAlertCard(bp: alerts[index]),
          ),
        ).animate().fadeIn();
      },
      loading: () => const SizedBox.shrink(),
      error: (e, __) => const SizedBox.shrink(),
    );
  }
}

class _PeriodSelector extends ConsumerWidget {
  const _PeriodSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPeriod = ref.watch(selectedPeriodProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: ['today', 'week', 'month', 'year'].map((period) {
            final isSelected = selectedPeriod == period;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Semantics(
                label: 'View $period stats',
                selected: isSelected,
                button: true,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ref.read(selectedPeriodProvider.notifier).state = period;
                  },
                  child: AnimatedContainer(
                    duration: 200.ms,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(colors: [FyniqColors.primaryAccent, FyniqColors.highlightCTA])
                          : null,
                      color: !isSelected ? FyniqColors.cardSurface : null,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      FyniqFormatter.formatPeriodLabel(period),
                      style: FyniqTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : FyniqColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
