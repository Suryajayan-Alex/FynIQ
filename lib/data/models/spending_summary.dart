class SpendingSummary {
  final double totalExpense;
  final double totalIncome;
  final double netBalance;
  final int transactionCount;
  const SpendingSummary({
    required this.totalExpense,
    required this.totalIncome,
    required this.netBalance,
    required this.transactionCount,
  });
}
