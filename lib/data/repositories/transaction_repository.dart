import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/app_database.dart';
import '../database/daos/transactions_dao.dart';
import '../models/spending_summary.dart';
import '../models/category_spend.dart';
import '../models/daily_spend.dart';
import '../../core/services/notification_service.dart';
import '../../data/repositories/budget_repository.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/notification_repository.dart';

class TransactionRepository {
  final TransactionsDao _dao;
  final NotificationService _notificationService;
  final BudgetRepository _budgetRepo;
  final CategoryRepository _catRepo;
  final NotificationRepository _notifRepo;
  final Uuid _uuid = const Uuid();
  
  TransactionRepository(this._dao, this._notificationService, this._budgetRepo, this._catRepo, this._notifRepo);

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
      _checkOverallSpending();
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
      await _notifRepo.addNotification(
        title: 'Over Budget!',
        body: 'You have exceeded your ${cat.name} budget.',
        type: 'budget',
      );
    } else {
      await _notificationService.showBudgetAlert(budget.id, cat.name, progress.percentage);
      await _notifRepo.addNotification(
        title: 'Budget Alert',
        body: 'You have used ${progress.percentage.toStringAsFixed(0)}% of your ${cat.name} budget.',
        type: 'budget',
      );
    }
  }

  Future<void> _checkOverallSpending() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final lastDay = DateTime(now.year, now.month + 1, 0);
      final endOfMonth = DateTime(lastDay.year, lastDay.month, lastDay.day, 23, 59, 59, 999);
      
      final summary = await getSpendingSummary(startOfMonth, endOfMonth);
      
      if (summary.totalExpense > summary.totalIncome) {
        final prefs = await SharedPreferences.getInstance();
        final alertKey = 'cashflow_alert_${now.year}_${now.month}';
        
        if (!(prefs.getBool(alertKey) ?? false)) {
          await prefs.setBool(alertKey, true);
          
          await _notificationService.plugin.show(
            88,
            '📉 Cashflow Warning!',
            'Your expenses have officially exceeded your income this month.',
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'fyniq_budget_alerts',
                'Budget Alerts',
                importance: Importance.high,
                priority: Priority.high,
                color: Color(0xFFFB7185),
              ),
            ),
          );
          
          await _notifRepo.addNotification(
            title: 'Spending > Income',
            body: 'Caution: You have spent more than your total income this month.',
            type: 'budget',
          );
        }
      }
    } catch (e) {
      // Background task fail, fail silently
    }
  }

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
    final Map<String, DailySpend> dailyMap = {};
    
    // 1. Group existing transactions
    for (final t in all) {
      final d = DateTime.fromMillisecondsSinceEpoch(t.date);
      final key = DateFormat('yyyy-MM-dd').format(d);
      final existing = dailyMap[key];
      final date = DateTime(d.year, d.month, d.day);
      if (existing == null) {
        dailyMap[key] = DailySpend(
          date: date, 
          totalExpense: t.type == 'expense' ? t.amount : 0, 
          totalIncome: t.type == 'income' ? t.amount : 0
        );
      } else {
        dailyMap[key] = DailySpend(
          date: date, 
          totalExpense: existing.totalExpense + (t.type == 'expense' ? t.amount : 0), 
          totalIncome: existing.totalIncome + (t.type == 'income' ? t.amount : 0)
        );
      }
    }

    // 2. Fill gaps for every day in the range
    final List<DailySpend> result = [];
    DateTime current = DateTime(from.year, from.month, from.day);
    final DateTime targetEnd = DateTime(to.year, to.month, to.day);

    while (current.isBefore(targetEnd) || current.isAtSameMomentAs(targetEnd)) {
      final key = DateFormat('yyyy-MM-dd').format(current);
      if (dailyMap.containsKey(key)) {
        result.add(dailyMap[key]!);
      } else {
        result.add(DailySpend(
          date: current,
          totalExpense: 0,
          totalIncome: 0,
        ));
      }
      current = current.add(const Duration(days: 1));
    }

    return result;
  }

  Future<List<Transaction>> getRecurringTransactions() => _dao.getRecurringTransactions();
}
