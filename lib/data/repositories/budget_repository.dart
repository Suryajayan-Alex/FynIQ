import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';
import '../database/daos/budgets_dao.dart';
import '../models/budget_progress.dart';
import 'transaction_repository.dart';

class BudgetRepository {
  final BudgetsDao _dao;
  final Uuid _uuid = const Uuid();

  BudgetRepository(this._dao);

  Stream<List<Budget>> watchAllBudgets() => _dao.watchAllBudgets();

  Future<List<Budget>> getActiveBudgets() => _dao.getActiveBudgets();

  Future<Budget?> getBudgetByCategory(String categoryId) =>
      _dao.getBudgetByCategory(categoryId);

  Future<void> addBudget({
    required String name,
    required String categoryId,
    required double limitAmount,
    required String period,
  }) async {
    final entry = BudgetsCompanion.insert(
      id: _uuid.v4(),
      name: name,
      categoryId: categoryId,
      limitAmount: limitAmount,
      period: period,
      startDate: DateTime.now().millisecondsSinceEpoch,
      isActive: const Value(true),
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _dao.insertBudget(entry);
  }

  Future<void> updateBudget(Budget budget) => _dao.updateBudget(budget);

  Future<void> deleteBudget(String id) => _dao.deleteBudget(id);

  Future<BudgetProgress> getBudgetProgress(
    Budget budget,
    TransactionRepository txRepo,
    Category category,
  ) async {
    final now = DateTime.now();
    DateTime from;
    DateTime to = now;

    if (budget.period == 'weekly') {
      from = now.subtract(Duration(days: now.weekday - 1)); // Start of week
      from = DateTime(from.year, from.month, from.day);
    } else {
      from = DateTime(now.year, now.month, 1); // Start of month
    }

    final allTransactionsInRange = await txRepo.watchByDateRange(from, to).first;
    final spentAmount = allTransactionsInRange
        .where((t) => t.categoryId == budget.categoryId && t.type == 'expense')
        .fold(0.0, (sum, t) => sum + t.amount);

    return BudgetProgress(
      budget: budget,
      category: category,
      spentAmount: spentAmount,
      percentage: budget.limitAmount > 0 ? (spentAmount / budget.limitAmount * 100) : 0,
    );
  }
}
