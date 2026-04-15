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
import 'package:intl/intl.dart';
import '../../widgets/trend_line_chart.dart';
import '../../widgets/transaction_list_tile.dart';
import '../../widgets/error_card.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spendingSummary = ref.watch(spendingSummaryProvider);
    final filter = ref.watch(filterTypeProvider);

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
              // ── Header (Statistics) ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => context.go('/home/dashboard'),
                        icon: const Icon(Iconsax.arrow_left_1, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.05),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      Text("Statistics", style: FyniqTextStyles.headingM),
                      IconButton(
                        onPressed: () {}, // Share action or similar
                        icon: const Icon(Iconsax.export, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.05),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Centered Amount ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      spendingSummary.when(
                        data: (summary) {
                          double displayAmount = 0;
                          Color displayColor = Colors.white;
                          String sign = "";
                          
                          if (filter == 'all') {
                            displayAmount = summary.netBalance.abs();
                            displayColor = summary.netBalance < 0 ? FyniqColors.warning : Colors.white;
                            sign = summary.netBalance < 0 ? "-" : "";
                          } else if (filter == 'expense') {
                            displayAmount = summary.totalExpense;
                            displayColor = FyniqColors.warning;
                            sign = "";
                          } else { // income
                            displayAmount = summary.totalIncome;
                            displayColor = FyniqColors.success;
                            sign = "";
                          }

                          return Text(
                            "$sign₹${FyniqFormatter.formatAmount(displayAmount)}",
                            style: FyniqTextStyles.headingXL.copyWith(
                              fontSize: 40,
                              color: displayColor,
                            ),
                          );
                        },
                        loading: () => const ShimmerBox(width: 200, height: 48),
                        error: (_, __) => Text("Rs. 0.00", style: FyniqTextStyles.headingXL),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        DateFormat('MMM d, yyyy').format(ref.watch(selectedDateProvider)),
                        style: FyniqTextStyles.caption.copyWith(color: FyniqColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Period Selector (Week, Month, Year) ──
              SliverToBoxAdapter(child: _PeriodSelector().animate(delay: 100.ms).fadeIn()),

              // ── Trend Line Chart ──
              SliverToBoxAdapter(
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: TrendLineChart(),
                ).animate(delay: 200.ms).fadeIn(),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Text("Top Spending", style: FyniqTextStyles.headingM),
                ),
              ),

              SliverToBoxAdapter(child: _buildFilterSortRow(ref)),
              
              _buildFilteredTransactionList(ref),
              const SliverToBoxAdapter(child: SizedBox(height: 140)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSortRow(WidgetRef ref) {
    final filter = ref.watch(filterTypeProvider);
    final sort = ref.watch(sortOrderProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
      child: Row(
        children: [
          ...['all', 'expense', 'income'].map((type) => Padding(
                padding: const EdgeInsets.only(right: 8),
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
                    color: filter == type ? FyniqColors.primaryAccent : FyniqColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )),
          const Spacer(),
          DropdownButton<String>(
            value: sort,
            dropdownColor: FyniqColors.cardSurface,
            icon: const Icon(Iconsax.sort, color: FyniqColors.textSecondary, size: 20),
            underline: const SizedBox(),
            onChanged: (v) {
              HapticFeedback.lightImpact();
              ref.read(sortOrderProvider.notifier).state = v!;
            },
            items: const [
              DropdownMenuItem(value: "newest", child: Text("Newest", style: TextStyle(fontSize: 12, color: FyniqColors.textPrimary))),
              DropdownMenuItem(value: "oldest", child: Text("Oldest", style: TextStyle(fontSize: 12, color: FyniqColors.textPrimary))),
              DropdownMenuItem(value: "highest", child: Text("Highest", style: TextStyle(fontSize: 12, color: FyniqColors.textPrimary))),
              DropdownMenuItem(value: "lowest", child: Text("Lowest", style: TextStyle(fontSize: 12, color: FyniqColors.textPrimary))),
            ],
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
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: ['week', 'month', 'year'].map((period) {
            final isSelected = selectedPeriod == period;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                   HapticFeedback.selectionClick();
                   ref.read(selectedPeriodProvider.notifier).state = period;
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.black : Colors.transparent,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ] : [],
                  ),
                  child: Center(
                    child: Text(
                      period.toUpperCase(),
                      style: FyniqTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                        fontSize: 11,
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
