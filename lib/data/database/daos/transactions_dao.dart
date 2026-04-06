import 'package:drift/drift.dart';
import '../app_database.dart';

part 'transactions_dao.g.dart';

@DriftAccessor(tables: [Transactions])
class TransactionsDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionsDaoMixin {
  TransactionsDao(super.db);

  Stream<List<Transaction>> watchAllTransactions() =>
    (select(transactions)..orderBy([(t) =>
      OrderingTerm.desc(t.date)])).watch();

  Stream<List<Transaction>> watchTransactionsByDateRange(
    DateTime from, DateTime to) =>
    (select(transactions)
      ..where((t) => t.date.isBetweenValues(
        from.millisecondsSinceEpoch, to.millisecondsSinceEpoch))
      ..orderBy([(t) => OrderingTerm.desc(t.date)])).watch();

  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime from, DateTime to) =>
    (select(transactions)
      ..where((t) => t.date.isBetweenValues(
        from.millisecondsSinceEpoch, to.millisecondsSinceEpoch))).get();

  Future<List<Transaction>> getRecentTransactions(int limit) =>
    (select(transactions)
      ..orderBy([(t) => OrderingTerm.desc(t.date)])
      ..limit(limit)).get();

  Future<Transaction?> getTransactionById(String id) =>
    (select(transactions)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<Transaction>> getRecurringTransactions() =>
    (select(transactions)
      ..where((t) => t.isRecurring.equals(true))).get();

  Future<void> insertTransaction(TransactionsCompanion entry) =>
    into(transactions).insert(entry);

  Future<void> updateTransaction(Transaction entry) =>
    update(transactions).replace(entry);

  Future<void> deleteTransaction(String id) =>
    (delete(transactions)..where((t) => t.id.equals(id))).go();

  Future<double> getTotalByTypeAndRange(
    String type, DateTime from, DateTime to) async {
    final rows = await getTransactionsByDateRange(from, to);
    // Explicitly casting sum to double to avoid FutureOr inference
    return rows
      .where((t) => t.type == type)
      .fold<double>(0.0, (double sum, Transaction t) => sum + t.amount);
  }
}
