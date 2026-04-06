import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';
import '../database/daos/transactions_dao.dart';
import '../models/spending_summary.dart';
import '../models/category_spend.dart';
import '../models/daily_spend.dart';
import '../../core/services/notification_service.dart';
import '../../data/repositories/budget_repository.dart';
import '../../data/repositories/category_repository.dart';

class TransactionRepository {
  final TransactionsDao _dao;
  final NotificationService _notificationService;
  final BudgetRepository _budgetRepo;
  final CategoryRepository _catRepo;
  final Uuid _uuid = const Uuid();
  
  TransactionRepository(this._dao, this._notificationService, this._budgetRepo, this._catRepo);

  Stream<List<Transaction>> watchAllTransactions() =>
    _dao.watchAllTransactions();

  Stream<List<Transaction>> watchByDateRange(DateTime from, DateTime to) =>
    _dao.watchTransactionsByDateRange(from, to);

  Future<List<Transaction>> getRecentTransactions(int limit) =>
    _dao.getRecentTransactions(limit);

  Future<Transaction?> getById(String id) =>
    _dao.getTransactionById(id);

  Future<void> addTransaction({
    required String title,
    required double amount,
    required String type,
    required String categoryId,
    String? note,
    required DateTime date,
    bool isRecurring = false,
    int? recurringIntervalDays,
  }) async {
    final entry = TransactionsCompanion.insert(
      id: _uuid.v4(),
      title: title,
      amount: amount,
      type: type,
      categoryId: categoryId,
      note: Value(note), 
      date: date.millisecondsSinceEpoch,
      isRecurring: Value(isRecurring),
      recurringIntervalDays: Value(recurringIntervalDays),
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _dao.insertTransaction(entry);

    if (type == 'expense') {
      _checkBudgetAlerts(categoryId);
    }
  }

  Future<void> updateTransaction(Transaction t) =>
    _dao.updateTransaction(t);

  Future<void> deleteTransaction(String id) =>
    _dao.deleteTransaction(id);

  Future<void> _checkBudgetAlerts(String categoryId) async {
    final budget = await _budgetRepo.getBudgetByCategory(categoryId);
    if (budget == null) return;

    final cats = await _catRepo.getAllCategories();
    final cat = cats.firstWhere((c) => c.id == categoryId, orElse: () => cats.last);
    
    final progress = await _budgetRepo.getBudgetProgress(budget, this, cat);
    
    if (progress.percentage > 100) {
      await _notificationService.showOverBudgetAlert(cat.name);
    } else {
      await _notificationService.showBudgetAlert(budget.id, cat.name, progress.percentage);
    }
  }

  // Same stats methods as before
  Future<SpendingSummary> getSpendingSummary(DateTime from, DateTime to) async {
    final all = await _dao.getTransactionsByDateRange(from, to);
    final expense = all.where((t) => t.type == 'expense').fold(0.0, (s, t) => s + t.amount);
    final income = all.where((t) => t.type == 'income').fold(0.0, (s, t) => s + t.amount);
    return SpendingSummary(
      totalExpense: expense,
      totalIncome: income,
      netBalance: income - expense,
      transactionCount: all.length,
    );
  }

  Future<List<CategorySpend>> getCategoryBreakdown(DateTime from, DateTime to, List<Category> categories) async {
    final all = await _dao.getTransactionsByDateRange(from, to);
    final expenses = all.where((t) => t.type == 'expense').toList();
    final total = expenses.fold(0.0, (s, t) => s + t.amount);
    
    final Map<String, double> catTotals = {};
    for (final t in expenses) {
      catTotals[t.categoryId] = (catTotals[t.categoryId] ?? 0) + t.amount;
    }
    
    return catTotals.entries.map((e) {
      final cat = categories.firstWhere((c) => c.id == e.key, orElse: () => categories.last);
      return CategorySpend(
        categoryId: e.key,
        categoryName: cat.name,
        emoji: cat.emoji,
        colorHex: cat.colorHex,
        totalAmount: e.value,
        percentage: total > 0 ? (e.value / total * 100) : 0,
      );
    }).toList()..sort((a,b) => b.totalAmount.compareTo(a.totalAmount));
  }

  Future<List<DailySpend>> getDailySpends(DateTime from, DateTime to) async {
    final all = await _dao.getTransactionsByDateRange(from, to);
    final Map<String, DailySpend> daily = {};
    for (final t in all) {
      final d = DateTime.fromMillisecondsSinceEpoch(t.date);
      final key = '${d.year}-${d.month}-${d.day}';
      final existing = daily[key];
      final date = DateTime(d.year, d.month, d.day);
      if (existing == null) {
        daily[key] = DailySpend(date: date, totalExpense: t.type == 'expense' ? t.amount : 0, totalIncome: t.type == 'income' ? t.amount : 0);
      } else {
        daily[key] = DailySpend(date: date, totalExpense: existing.totalExpense + (t.type == 'expense' ? t.amount : 0), totalIncome: existing.totalIncome + (t.type == 'income' ? t.amount : 0));
      }
    }
    return daily.values.toList()..sort((a,b) => a.date.compareTo(b.date));
  }

  Future<List<Transaction>> getRecurringTransactions() => _dao.getRecurringTransactions();
}
