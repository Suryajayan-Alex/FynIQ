import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/app_database.dart';
import '../../data/models/budget_progress.dart';
import '../../data/models/category_spend.dart';
import '../../data/models/spending_summary.dart';
import '../../domain/providers/database_providers.dart';

final selectedPeriodProvider = StateProvider<String>((ref) => 'month');
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final dateRangeProvider = Provider<DateTimeRange>((ref) {
  final period = ref.watch(selectedPeriodProvider);
  final selected = ref.watch(selectedDateProvider);
  final realNow = DateTime.now();
  
  // For Today and Week, we almost always want the "Real" today/week
  // unless we're in a dedicated historical view (which we'll handle by 
  // checking if the selected year/month is different from now).
  final isHistorical = selected.year != realNow.year || selected.month != realNow.month;
  final baseDate = isHistorical ? selected : realNow;
  final today = DateTime(baseDate.year, baseDate.month, baseDate.day);

  switch (period) {
    case 'today':
      return DateTimeRange(start: today, end: today.add(const Duration(hours: 23, minutes: 59, seconds: 59, milliseconds: 999)));
    case 'week':
      final start = today.subtract(Duration(days: today.weekday - 1));
      final weekStart = DateTime(start.year, start.month, start.day);
      return DateTimeRange(start: weekStart, end: weekStart.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59, milliseconds: 999)));
    case 'year':
      final yearStart = DateTime(selected.year, 1, 1);
      return DateTimeRange(start: yearStart, end: DateTime(selected.year, 12, 31, 23, 59, 59, 999));
    case 'month':
    default:
      final monthStart = DateTime(selected.year, selected.month, 1);
      final lastDay = DateTime(selected.year, selected.month + 1, 0);
      return DateTimeRange(
        start: monthStart, 
        end: DateTime(lastDay.year, lastDay.month, lastDay.day, 23, 59, 59, 999),
      );
  }
});

final spendingSummaryProvider = FutureProvider.autoDispose<SpendingSummary>((ref) {
  final range = ref.watch(dateRangeProvider);
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.getSpendingSummary(range.start, range.end);
});

final recentTransactionsProvider = StreamProvider.autoDispose<List<Transaction>>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  final range = ref.watch(dateRangeProvider);
  return repo.watchByDateRange(range.start, range.end);
});

final allCategoriesProvider = StreamProvider.autoDispose<List<Category>>((ref) {
  final repo = ref.watch(categoryRepositoryProvider);
  return repo.watchAllCategories();
});

final categoryBreakdownProvider = FutureProvider.autoDispose<List<CategorySpend>>((ref) async {
  final range = ref.watch(dateRangeProvider);
  final repo = ref.watch(transactionRepositoryProvider);
  final catRepo = ref.watch(categoryRepositoryProvider);
  final cats = await catRepo.getAllCategories();
  return repo.getCategoryBreakdown(range.start, range.end, cats);
});

final budgetProgressListProvider = FutureProvider.autoDispose<List<BudgetProgress>>((ref) async {
  final budgetRepo = ref.watch(budgetRepositoryProvider);
  final txRepo = ref.watch(transactionRepositoryProvider);
  final catRepo = ref.watch(categoryRepositoryProvider);
  final budgets = await budgetRepo.getActiveBudgets();
  final cats = await catRepo.getAllCategories();
  return Future.wait(budgets.map((b) {
    final cat = cats.firstWhere((c) => c.id == b.categoryId, orElse: () => cats.last);
    return budgetRepo.getBudgetProgress(b, txRepo, cat);
  }));
});

final balanceVisibleProvider = StateProvider<bool>((ref) => true);

final userNameProvider = FutureProvider.autoDispose<String?>((ref) {
  return ref.read(settingsRepositoryProvider).getUserName();
});

final profileImageProvider = FutureProvider.autoDispose<String?>((ref) {
  return ref.read(settingsRepositoryProvider).getProfileImage();
});
