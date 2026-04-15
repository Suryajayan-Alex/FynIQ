import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/theme/app_theme.dart';
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
    return Scaffold(
      backgroundColor: FyniqColors.background,
      body: RefreshIndicator(
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
            // ── Purple Gradient Hero Header ──
            const SliverToBoxAdapter(child: BalanceHeroCard()),

            // ── "Your Money" Section ──
            SliverToBoxAdapter(
              child: Transform.translate(
                offset: const Offset(0, -16),
                child: const _YourMoneyCard(),
              ),
            ),

            // ── Period Selector ──
            const SliverToBoxAdapter(child: _PeriodSelector()),

            // ── Insight / Budget Alerts Banner ──
            // const SliverToBoxAdapter(child: _InsightBanner()),

            // ── Budget Alerts (Sliding Row) ──
            const SliverToBoxAdapter(child: _BudgetAlertsRow()),

            // ── Transactions Header ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Transactions",
                      style: FyniqTextStyles.headingM.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/home/analytics'),
                      child: const Row(
                        children: [
                          Icon(Iconsax.filter, size: 18, color: FyniqColors.textSecondary),
                          SizedBox(width: 12),
                          Icon(Iconsax.arrow_swap_horizontal, size: 18, color: FyniqColors.textSecondary),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Transaction Date + Total ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _getFormattedDate(),
                      style: FyniqTextStyles.caption.copyWith(
                        color: FyniqColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Consumer(
                      builder: (context, ref, _) {
                        final summaryAsync = ref.watch(spendingSummaryProvider);
                        return summaryAsync.when(
                          data: (s) => Row(
                            children: [
                              Text(
                                "Total  ",
                                style: FyniqTextStyles.caption.copyWith(
                                  color: FyniqColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                "₹${FyniqFormatter.formatAmount(s.totalIncome + s.totalExpense)}",
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: FyniqColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // ── Transactions List ──
            const _RecentTransactionsList(),

            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }

  static String _getFormattedDate() {
    final now = DateTime.now();
    final weekday = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return "${weekday[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}, ${now.year}";
  }
}

// ── "Your Money" White Card with Income/Expense ──
class _YourMoneyCard extends ConsumerWidget {
  const _YourMoneyCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(spendingSummaryProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: FyniqColors.cardSurface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: FyniqColors.primaryAccent.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      "Your Money",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: FyniqColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => _showInfoDialog(context),
                      child: Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: FyniqColors.textSecondary.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => context.push('/home/analytics'),
                  child: Row(
                    children: [
                      Text(
                        "Details",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: FyniqColors.primaryAccent,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: FyniqColors.primaryAccent,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Income / Expense Cards Row
            Row(
              children: [
                Expanded(
                  child: _MoneyStatCard(
                    icon: Icons.trending_up_rounded,
                    iconBgColor: const Color(0xFFEBF5FF),
                    iconColor: const Color(0xFF3B82F6),
                    label: "Income",
                    amountAsync: summaryAsync.whenData((s) => s.totalIncome),
                    amountColor: FyniqColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MoneyStatCard(
                    icon: Icons.trending_down_rounded,
                    iconBgColor: const Color(0xFFFEE2E2),
                    iconColor: const Color(0xFFEF4444),
                    label: "Expenses",
                    amountAsync: summaryAsync.whenData((s) => s.totalExpense),
                    amountColor: FyniqColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
  }
  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Your Money 📊"),
        content: const Text(
          "This summary shows your total Income and Expenses for the selected period (today, week, month, or year).\n\n"
          "Income: Money you received.\n"
          "Expenses: Money you spent.",
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Got it")),
        ],
      ),
    );
  }
}

// ── Individual Money Stat Card (Income / Expense) ──
class _MoneyStatCard extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String label;
  final AsyncValue<double> amountAsync;
  final Color amountColor;

  const _MoneyStatCard({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.label,
    required this.amountAsync,
    required this.amountColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: FyniqColors.background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon + info
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text("$label Info ℹ️"),
                      content: Text(
                        label == "Income" 
                            ? "This shows total money added to your account in this period."
                            : "This shows total money spent in this period."
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK")),
                      ],
                    ),
                  );
                },
                child: Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: FyniqColors.textSecondary.withOpacity(0.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: FyniqColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          amountAsync.when(
            data: (amount) => Text(
              "₹${FyniqFormatter.formatAmount(amount)}",
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: amountColor,
              ),
            ),
            loading: () => const ShimmerBox(width: 80, height: 24),
            error: (_, __) => Text(
              "₹0",
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: amountColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Insight Banner ──
class _InsightBanner extends ConsumerWidget {
  const _InsightBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(spendingSummaryProvider);

    return summaryAsync.when(
      data: (s) {
        if (s.transactionCount == 0) return const SizedBox.shrink();

        final savingsRate = s.totalIncome > 0
            ? ((s.totalIncome - s.totalExpense) / s.totalIncome * 100).clamp(0, 100)
            : 0.0;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: FyniqColors.textPrimary,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: FyniqColors.primaryAccent.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: FyniqColors.secondaryAccent,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    savingsRate > 20
                        ? "Great! You're saving ${savingsRate.toStringAsFixed(0)}% 🔥"
                        : "Your insight is ready",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push('/analytics'),
                  child: Text(
                    "View →",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: FyniqColors.secondaryAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.05);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

// ── Period Selector Chips ──
class _PeriodSelector extends ConsumerWidget {
  const _PeriodSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPeriod = ref.watch(selectedPeriodProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
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
                          ? const LinearGradient(colors: [
                              FyniqColors.primaryAccent,
                              FyniqColors.highlightCTA,
                            ])
                          : null,
                      color: !isSelected ? FyniqColors.cardSurface : null,
                      borderRadius: BorderRadius.circular(12),
                      border: !isSelected
                          ? Border.all(color: FyniqColors.divider, width: 1)
                          : null,
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

// ── Recent Transactions List ──
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
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: FyniqColors.primaryAccent.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text("💸", style: TextStyle(fontSize: 36)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "No transactions yet",
                    style: FyniqTextStyles.headingM.copyWith(
                      color: FyniqColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Start tracking your finances",
                    style: FyniqTextStyles.body.copyWith(color: FyniqColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  GradientButton(
                    text: "Log First Expense",
                    onPressed: () => context.push('/add-transaction'),
                    width: 200,
                    colors: const [FyniqColors.primaryAccent, FyniqColors.highlightCTA],
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
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                    child: TransactionListTile(
                      transaction: tx,
                      category: cat,
                      onTap: () => context.push('/transaction-detail/${tx.id}'),
                    ),
                  ).animate(delay: (index * 80).ms).fadeIn().slideX(begin: 0.05);
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
          child: Column(children: List.generate(3, (i) => const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: ShimmerBox(width: double.infinity, height: 72),
          ))),
        ),
      ),
      error: (e, __) => SliverToBoxAdapter(child: ErrorCard(message: e.toString())),
    );
  }
}

// ── Budget Alerts Row ──
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
