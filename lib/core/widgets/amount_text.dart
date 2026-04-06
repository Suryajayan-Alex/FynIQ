import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class AmountText extends StatelessWidget {
  final double amount;
  final double fontSize;
  final Color color;
  final bool showSign;
  final bool isHidden;

  const AmountText({
    super.key,
    required this.amount,
    this.fontSize = 24,
    this.color = FyniqColors.textPrimary,
    this.showSign = false,
    this.isHidden = false,
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
      if (showSign && amount > 0) {
        formatted = "+$formatted";
      }
    }

    return Semantics(
      label: isHidden ? 'Hidden Amount' : 'Amount: $formatted',
      excludeSemantics: false,
      child: Text(
        formatted,
        style: GoogleFonts.spaceGrotesk(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
