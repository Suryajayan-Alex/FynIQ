import 'package:intl/intl.dart';

class FyniqFormatter {
  static String formatCurrency(double amount) {
    if (amount >= 10000000) return '₹${(amount/10000000).toStringAsFixed(1)}Cr';
    if (amount >= 100000) return '₹${(amount/100000).toStringAsFixed(1)}L';
    return NumberFormat.currency(locale:'en_IN',symbol:'₹',
      decimalDigits:0).format(amount);
  }

  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days:1));
    final d = DateTime(date.year, date.month, date.day);
    if (d == today) return 'Today';
    if (d == yesterday) return 'Yesterday';
    if (now.difference(date).inDays < 7) {
      return DateFormat('EEEE').format(date); // Monday
    }
    if (date.year == now.year) {
      return DateFormat('d MMM').format(date); // 3 Apr
    }
    return DateFormat('d MMM y').format(date); // 3 Apr 2024
  }

  static String formatRelativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  static String formatPeriodLabel(String period) {
    switch(period) {
      case 'today': return 'Today';
      case 'week': return 'This Week';
      case 'month': return 'This Month';
      case 'year': return 'This Year';
      default: return 'This Month';
    }
  }

  /// Formats amount without currency symbol (for cases where ₹ is added separately)
  static String formatAmount(double amount) {
    if (amount >= 10000000) return '${(amount / 10000000).toStringAsFixed(1)}Cr';
    if (amount >= 100000) return '${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000) return NumberFormat('#,##,###', 'en_IN').format(amount.round());
    return amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2);
  }
}
