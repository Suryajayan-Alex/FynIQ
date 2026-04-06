import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/fyniq_scaffold.dart';
import '../../../core/widgets/shimmer_box.dart';
import '../../../core/utils/formatter.dart';
import '../../../domain/providers/dashboard_providers.dart';
import '../../../domain/providers/analytics_providers.dart';
import '../../widgets/trend_line_chart.dart';
import '../../widgets/income_expense_bar.dart';
import '../../widgets/category_bar_chart.dart';
import '../../widgets/stats_card.dart';
import '../../widgets/transaction_list_tile.dart';
import '../../widgets/error_card.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FyniqScaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: FyniqColors.primaryAccent,
          backgroundColor: FyniqColors.cardSurface,
          onRefresh: () async {
            HapticFeedback.mediumImpact();
            ref.invalidate(spendingSummaryProvider);
            ref.invalidate(categoryBreakdownProvider);
            ref.invalidate(filteredTransactionsProvider);
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context).animate().fadeIn().slideY(begin: -0.1)),
              SliverToBoxAdapter(child: _PeriodSelector().animate(delay: 100.ms).fadeIn().slideX(begin: 0.1)),
              SliverToBoxAdapter(
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: TrendLineChart(),
                ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.1),
              ),
              SliverToBoxAdapter(
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: IncomeExpenseBar(),
                ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.1),
              ),
              SliverToBoxAdapter(
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: CategoryBarChartCard(),
                ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.1),
              ),
              SliverToBoxAdapter(
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: StatsCardsRow(),
                ).animate(delay: 500.ms).fadeIn().slideY(begin: 0.1),
              ),
              SliverToBoxAdapter(child: _buildFilterSortRow(ref).animate(delay: 600.ms).fadeIn()),
              _buildFilteredTransactionList(ref),
              const SliverToBoxAdapter(child: SizedBox(height: 140)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Insight Zone 🧠", style: FyniqTextStyles.caption),
              const SizedBox(height: 4),
              Text("Analyzing your moves.", style: FyniqTextStyles.headingM),
            ],
          ),
          IconButton(
            tooltip: 'Go back to dashboard',
            onPressed: () {
              HapticFeedback.lightImpact();
              context.go('/home/dashboard');
            },
            icon: const Icon(Iconsax.arrow_right_1, color: FyniqColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSortRow(WidgetRef ref) {
    final filter = ref.watch(filterTypeProvider);
    final sort = ref.watch(sortOrderProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      child: Row(
        children: [
          ...['all', 'expense', 'income'].map((type) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Semantics(
                  label: 'Filter by $type',
                  selected: filter == type,
                  button: true,
                  child: ChoiceChip(
                    label: Text(type.toUpperCase()),
                    selected: filter == type,
                    onSelected: (val) {
                      HapticFeedback.lightImpact();
                      if (val) ref.read(filterTypeProvider.notifier).state = type;
                    },
                    selectedColor: FyniqColors.primaryAccent.withOpacity(0.3),
                    checkmarkColor: FyniqColors.primaryAccent,
                    backgroundColor: FyniqColors.cardSurface,
                    labelStyle: FyniqTextStyles.caption.copyWith(
                      color: filter == type ? FyniqColors.primaryAccent : Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )),
          const Spacer(),
          Semantics(
            label: 'Sort transactions',
            child: DropdownButton<String>(
              value: sort,
              dropdownColor: FyniqColors.cardSurface,
              icon: const Icon(Iconsax.sort, color: Colors.grey, size: 20),
              underline: const SizedBox(),
              onChanged: (v) {
                HapticFeedback.lightImpact();
                ref.read(sortOrderProvider.notifier).state = v!;
              },
              items: const [
                DropdownMenuItem(value: "newest", child: Text("Newest", style: TextStyle(fontSize: 12))),
                DropdownMenuItem(value: "oldest", child: Text("Oldest", style: TextStyle(fontSize: 12))),
                DropdownMenuItem(value: "highest", child: Text("Highest", style: TextStyle(fontSize: 12))),
                DropdownMenuItem(value: "lowest", child: Text("Lowest", style: TextStyle(fontSize: 12))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilteredTransactionList(WidgetRef ref) {
    final transactionsAsync = ref.watch(filteredTransactionsProvider);
    final categoriesAsync = ref.watch(allCategoriesProvider);

    return transactionsAsync.when(
      data: (list) {
        if (list.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(48.0),
              child: Column(
                children: [
                  const Text("🔍", style: TextStyle(fontSize: 56))
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .moveY(begin: -8, end: 8, duration: 1500.ms, curve: Curves.easeInOut),
                  const SizedBox(height: 16),
                  Text("No matches found.", style: FyniqTextStyles.headingM),
                ],
              ),
            ),
          );
        }

        final Map<String, List<dynamic>> grouped = {};
        for (var tx in list) {
          final date = DateTime.fromMillisecondsSinceEpoch(tx.date);
          final key = FyniqFormatter.formatDate(date);
          if (!grouped.containsKey(key)) grouped[key] = [];
          grouped[key]!.add(tx);
        }

        return categoriesAsync.when(
          data: (cats) => SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final groupKey = grouped.keys.elementAt(index);
                final items = grouped[groupKey]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                      child: Text(groupKey, style: FyniqTextStyles.caption.copyWith(fontWeight: FontWeight.w700)),
                    ),
                    ...items.map((tx) {
                      final cat = cats.firstWhere((c) => c.id == tx.categoryId, orElse: () => cats.last);
                      final itemIndex = list.indexOf(tx);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                        child: Semantics(
                          label: 'Transaction: ${tx.title}, ${tx.amount}',
                          child: TransactionListTile(
                            transaction: tx,
                            category: cat,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              context.push('/transaction-detail/${tx.id}');
                            },
                          ),
                        ),
                      ).animate(delay: (itemIndex * 50).ms).fadeIn().slideX(begin: 0.1);
                    }),
                  ],
                );
              },
              childCount: grouped.length,
            ),
          ),
          loading: () => const SliverToBoxAdapter(child: SizedBox()),
          error: (e, __) => SliverToBoxAdapter(child: ErrorCard(message: e.toString())),
        );
      },
      loading: () => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: List.generate(3, (i) => const ShimmerBox(width: double.infinity, height: 72, borderRadius: 20)),
          ),
        ),
      ),
      error: (e, __) => SliverToBoxAdapter(child: ErrorCard(message: e.toString())),
    );
  }
}

class _PeriodSelector extends ConsumerWidget {
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
