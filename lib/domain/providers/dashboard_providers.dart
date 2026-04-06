import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/app_database.dart';
import '../../data/models/budget_progress.dart';
import '../../data/models/category_spend.dart';
import '../../data/models/spending_summary.dart';
import '../../domain/providers/database_providers.dart';

final selectedPeriodProvider = StateProvider<String>((ref) => 'month');

final dateRangeProvider = Provider<DateTimeRange>((ref) {
  final period = ref.watch(selectedPeriodProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  switch (period) {
    case 'today':
      return DateTimeRange(start: today, end: today.add(const Duration(days: 1)));
    case 'week':
      final start = today.subtract(Duration(days: today.weekday - 1));
      return DateTimeRange(start: start, end: start.add(const Duration(days: 7)));
    case 'year':
      return DateTimeRange(start: DateTime(now.year, 1, 1), end: DateTime(now.year + 1, 1, 1));
    case 'month':
    default:
      return DateTimeRange(start: DateTime(now.year, now.month, 1), end: DateTime(now.year, now.month + 1, 1));
  }
});

final spendingSummaryProvider = FutureProvider.autoDispose<SpendingSummary>((ref) {
  final range = ref.watch(dateRangeProvider);
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.getSpendingSummary(range.start, range.end);
});

final recentTransactionsProvider = StreamProvider.autoDispose<List<Transaction>>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.watchAllTransactions().map((list) => list.take(5).toList());
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
