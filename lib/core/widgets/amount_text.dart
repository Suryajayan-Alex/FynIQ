import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class AmountText extends StatelessWidget {
  final double amount;
  final double fontSize;
  final Color? color;
  final bool showSign;
  final bool isHidden;
  final String type; // 'expense' or 'income'

  const AmountText({
    super.key,
    required this.amount,
    this.fontSize = 24,
    this.color,
    this.showSign = false,
    this.isHidden = false,
    this.type = 'expense',
  });

  @override
  Widget build(BuildContext context) {
    String formatted;
    if (isHidden) {
      formatted = "₹ ••••";
    } else {
      formatted = NumberFormat.currency(
        locale: 'en_IN',
        symbol: '₹',
        decimalDigits: 2,
      ).format(amount);
      
      if (showSign) {
        if (type == 'income') {
          formatted = "+ $formatted";
        } else {
          formatted = "- $formatted";
        }
      }
    }

    final displayColor = color ?? (type == 'income' ? FyniqColors.success : const Color(0xFFEF4444));

    return Semantics(
      label: isHidden ? 'Hidden Amount' : 'Amount: $formatted',
      excludeSemantics: false,
      child: Text(
        formatted,
        style: GoogleFonts.spaceGrotesk(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: displayColor,
        ),
      ),
    );
  }
}
