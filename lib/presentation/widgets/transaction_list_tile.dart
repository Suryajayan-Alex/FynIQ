import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/amount_text.dart';
import '../../core/utils/formatter.dart';
import '../../data/database/app_database.dart';

class TransactionListTile extends StatelessWidget {
  final Transaction transaction;
  final Category category;
  final VoidCallback onTap;

  const TransactionListTile({
    super.key,
    required this.transaction,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse(category.colorHex.replaceAll('#', '0xFF')));

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: GlassCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(category.emoji, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: FyniqTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${category.name} · ${FyniqFormatter.formatRelativeTime(DateTime.fromMillisecondsSinceEpoch(transaction.date))}",
                    style: FyniqTextStyles.caption.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            AmountText(
              amount: transaction.amount,
              fontSize: 16,
              showSign: true,
              color: transaction.type == 'expense' ? FyniqColors.highlightCTA : FyniqColors.success,
            ),
          ],
        ),
      ),
    );
  }
}
