import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/theme/app_theme.dart';

class FyniqSnackbar {
  static void show(BuildContext context, String message, {bool isError = false, bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Iconsax.warning_2 : isSuccess ? Iconsax.tick_circle : Iconsax.info_circle,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message, style: FyniqTextStyles.body.copyWith(color: Colors.white))),
          ],
        ),
        backgroundColor: isError ? FyniqColors.warning : isSuccess ? FyniqColors.success : FyniqColors.cardSurface,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: 2500.ms,
      ),
    );
  }
}
