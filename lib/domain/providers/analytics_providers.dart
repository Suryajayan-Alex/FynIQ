import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/database/app_database.dart';
import '../../data/models/daily_spend.dart';
import '../../domain/providers/database_providers.dart';
import '../../domain/providers/dashboard_providers.dart';

final filterTypeProvider = StateProvider<String>((ref) => 'all'); 

final sortOrderProvider = StateProvider<String>((ref) => 'newest'); 

final spendingTrendProvider = FutureProvider.autoDispose<List<DailySpend>>((ref) async {
  final range = ref.watch(dateRangeProvider);
  final repo = ref.watch(transactionRepositoryProvider);
  final period = ref.watch(selectedPeriodProvider);
  
  final daily = await repo.getDailySpends(range.start, range.end);
  
  if (period == 'year') {
    // Aggregate by month for clearer trend
    final Map<int, DailySpend> monthlyMap = {};
    for (int i = 1; i <= 12; i++) {
        monthlyMap[i] = DailySpend(
          date: DateTime(range.start.year, i, 1),
          totalExpense: 0,
          totalIncome: 0,
        );
    }

    for (var d in daily) {
      final monthIndex = d.date.month;
      final current = monthlyMap[monthIndex]!;
      monthlyMap[monthIndex] = DailySpend(
        date: current.date,
        totalExpense: current.totalExpense + d.totalExpense,
        totalIncome: current.totalIncome + d.totalIncome,
      );
    }
    return monthlyMap.values.toList()..sort((a, b) => a.date.compareTo(b.date));
  }
  
  return daily;
});

class AnalyticsStats {
  final Transaction? biggestTransaction;
  final String? mostActiveDay;
  final int mostActiveDayCount;
  final double avgDailySpend;

  AnalyticsStats({
    this.biggestTransaction,
    this.mostActiveDay,
    this.mostActiveDayCount = 0,
    this.avgDailySpend = 0.0,
  });
}

final analyticsStatsProvider = FutureProvider.autoDispose<AnalyticsStats>((ref) async {
  final range = ref.watch(dateRangeProvider);
  final repo = ref.watch(transactionRepositoryProvider);
  final txList = await repo.watchByDateRange(range.start, range.end).first;
  
  final expenses = txList.where((t) => t.type == 'expense').toList();
  final biggest = expenses.isEmpty ? null : expenses.reduce((a, b) => a.amount > b.amount ? a : b);
  
  final Map<String, int> dayCounts = {};
  for (final t in txList) {
    final day = DateFormat('EEEE').format(DateTime.fromMillisecondsSinceEpoch(t.date));
    dayCounts[day] = (dayCounts[day] ?? 0) + 1;
  }
  
  final mostActiveDay = dayCounts.isEmpty ? null : dayCounts.entries.reduce((a, b) => a.value > b.value ? a : b);
  
  final days = range.end.difference(range.start).inDays;
  final totalExpense = expenses.fold(0.0, (s, t) => s + t.amount);
  final avgDaily = days > 0 ? totalExpense / days : totalExpense;
  
  return AnalyticsStats(
    biggestTransaction: biggest,
    mostActiveDay: mostActiveDay?.key,
    mostActiveDayCount: mostActiveDay?.value ?? 0,
    avgDailySpend: avgDaily,
  );
});

final filteredTransactionsProvider = FutureProvider.autoDispose<List<Transaction>>((ref) async {
  final range = ref.watch(dateRangeProvider);
  final filter = ref.watch(filterTypeProvider);
  final sort = ref.watch(sortOrderProvider);
  final repo = ref.watch(transactionRepositoryProvider);
  
  var list = await repo.watchByDateRange(range.start, range.end).first;
  
  if (filter != 'all') {
    list = list.where((t) => t.type == filter).toList();
  }
  
  switch (sort) {
    case 'oldest':
      list.sort((a, b) => a.date.compareTo(b.date));
      break;
    case 'highest':
      list.sort((a, b) => b.amount.compareTo(a.amount));
      break;
    case 'lowest':
      list.sort((a, b) => a.amount.compareTo(b.amount));
      break;
    case 'newest':
    default:
      list.sort((a, b) => b.date.compareTo(a.date));
  }
  return list;
});
