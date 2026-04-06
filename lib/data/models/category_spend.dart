class CategorySpend {
  final String categoryId;
  final String categoryName;
  final String emoji;
  final String colorHex;
  final double totalAmount;
  final double percentage;
  const CategorySpend({
    required this.categoryId,
    required this.categoryName,
    required this.emoji,
    required this.colorHex,
    required this.totalAmount,
    required this.percentage,
  });
}
