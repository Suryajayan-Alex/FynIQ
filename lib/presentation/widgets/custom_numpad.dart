import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

class CustomNumpad extends StatelessWidget {
  final Function(String) onDigitPressed;
  final VoidCallback onBackspacePressed;

  const CustomNumpad({
    super.key,
    required this.onDigitPressed,
    required this.onBackspacePressed,
  });

  @override
  Widget build(BuildContext context) {
    final keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '0', '⌫'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: keys.length,
        itemBuilder: (context, index) {
          final key = keys[index];
          final isBackspace = key == '⌫';
          
          return Semantics(
            label: isBackspace ? 'Backspace' : 'Digit $key',
            button: true,
            child: GestureDetector(
              onTap: () {
                if (isBackspace) {
                  HapticFeedback.selectionClick();
                  onBackspacePressed();
                } else {
                  HapticFeedback.lightImpact();
                  onDigitPressed(key);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isBackspace ? FyniqColors.highlightCTA.withOpacity(0.15) : FyniqColors.cardSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: FyniqColors.divider.withOpacity(0.5), width: 0.5),
                ),
                child: Center(
                  child: isBackspace
                      ? const Icon(Icons.backspace_rounded, color: FyniqColors.highlightCTA)
                      : Text(
                          key,
                          style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w600, color: FyniqColors.textPrimary),
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
