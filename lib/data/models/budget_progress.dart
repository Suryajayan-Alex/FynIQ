import '../database/app_database.dart';

class BudgetProgress {
  final Budget budget;
  final Category category;
  final double spentAmount;
  final double percentage;

  bool get isOverBudget => spentAmount > budget.limitAmount;
  double get remainingAmount => budget.limitAmount - spentAmount;

  const BudgetProgress({
    required this.budget,
    required this.category,
    required this.spentAmount,
    required this.percentage,
  });
}
