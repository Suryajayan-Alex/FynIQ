import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CategoryChip extends StatelessWidget {
  final String emoji;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  const CategoryChip({
    super.key,
    required this.emoji,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color = FyniqColors.primaryAccent,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: isSelected
              ? LinearGradient(colors: [color, FyniqColors.highlightCTA])
              : null,
          color: isSelected ? null : FyniqColors.cardSurface,
          border: Border.all(
            color: isSelected ? Colors.transparent : FyniqColors.divider,
            width: 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8)]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? FyniqColors.textPrimary : FyniqColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
