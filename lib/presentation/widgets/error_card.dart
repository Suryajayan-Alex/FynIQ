import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';

class ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  
  const ErrorCard({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Iconsax.warning_2, color: FyniqColors.warning, size: 32),
          const SizedBox(height: 12),
          Text("Something went wrong", style: FyniqTextStyles.headingM, textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(message, style: FyniqTextStyles.caption.copyWith(color: FyniqColors.textSecondary), textAlign: TextAlign.center),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              child: const Text("Tap to retry", style: TextStyle(color: FyniqColors.primaryAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        ],
      ),
    );
  }
}
