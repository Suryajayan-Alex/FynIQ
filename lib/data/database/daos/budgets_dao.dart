import 'package:drift/drift.dart';
import '../app_database.dart';

part 'budgets_dao.g.dart';

@DriftAccessor(tables: [Budgets])
class BudgetsDao extends DatabaseAccessor<AppDatabase>
    with _$BudgetsDaoMixin {
  BudgetsDao(super.db);

  Stream<List<Budget>> watchAllBudgets() =>
    (select(budgets)..where((b) => b.isActive.equals(true))).watch();

  Future<List<Budget>> getActiveBudgets() =>
    (select(budgets)..where((b) => b.isActive.equals(true))).get();

  Future<Budget?> getBudgetByCategory(String categoryId) =>
    (select(budgets)
      ..where((b) => b.categoryId.equals(categoryId))
      ..where((b) => b.isActive.equals(true)))
    .getSingleOrNull();

  Future<void> insertBudget(BudgetsCompanion entry) =>
    into(budgets).insert(entry);

  Future<void> updateBudget(Budget entry) =>
    update(budgets).replace(entry);

  Future<void> deleteBudget(String id) =>
    (delete(budgets)..where((b) => b.id.equals(id))).go();
}
