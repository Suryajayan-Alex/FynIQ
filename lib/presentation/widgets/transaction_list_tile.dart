import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
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
    final isIncome = transaction.type == 'income';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: FyniqColors.cardSurface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Category Emoji Circle
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(category.emoji, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 14),

              // Title + Category + Time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: FyniqColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "${category.name} · ${FyniqFormatter.formatRelativeTime(DateTime.fromMillisecondsSinceEpoch(transaction.date))}",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: FyniqColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${isIncome ? '+' : '-'}₹${FyniqFormatter.formatAmount(transaction.amount)}",
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isIncome ? FyniqColors.success : const Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
