import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

Future<void> showSuccessOverlay(BuildContext context, String message) async {
  final overlay = OverlayEntry(
    builder: (ctx) => Material(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [FyniqColors.success, FyniqColors.primaryAccent],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: FyniqColors.success.withOpacity(0.5),
                    blurRadius: 24,
                  ),
                ],
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 40),
            ).animate().scale(begin: const Offset(0.3, 0.3), curve: Curves.elasticOut, duration: 600.ms),
            const SizedBox(height: 16),
            Text(
              message,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ).animate().fadeIn(delay: 300.ms),
          ],
        ),
      ),
    ),
  );

  Overlay.of(context).insert(overlay);
  await Future.delayed(const Duration(milliseconds: 1200));
  overlay.remove();
}
