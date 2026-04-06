import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/app_database.dart';
import '../../data/models/budget_progress.dart';
import '../../domain/providers/database_providers.dart';

final budgetListStreamProvider = StreamProvider.autoDispose<List<Budget>>((ref) {
  return ref.watch(budgetRepositoryProvider).watchAllBudgets();
});

final budgetProgressAllProvider = FutureProvider.autoDispose<List<BudgetProgress>>((ref) async {
  final budgets = await ref.watch(budgetRepositoryProvider).getActiveBudgets();
  final txRepo = ref.watch(transactionRepositoryProvider);
  final catRepo = ref.watch(categoryRepositoryProvider);
  final cats = await catRepo.getAllCategories();
  
  return Future.wait(budgets.map((b) {
    final cat = cats.firstWhere((c) => c.id == b.categoryId, orElse: () => cats.last);
    return ref.watch(budgetRepositoryProvider).getBudgetProgress(b, txRepo, cat);
  }));
});
