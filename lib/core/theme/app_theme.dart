import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class FyniqColors {
  FyniqColors._();
  static const background = Color(0xFF0D0D1A);
  static const backgroundAlt = Color(0xFF1A1A2E);
  static const cardSurface = Color(0xFF16213E);
  static const primaryAccent = Color(0xFF7C3AED);
  static const secondaryAccent = Color(0xFFA3E635);
  static const highlightCTA = Color(0xFFEC4899);
  static const warning = Color(0xFFF97316);
  static const success = Color(0xFF22C55E);
  static const textPrimary = Color(0xFFF8FAFC);
  static const textSecondary = Color(0xFF94A3B8);
  static const divider = Color(0xFF1E293B);
}

class FyniqTextStyles {
  FyniqTextStyles._();
  static TextStyle get headingXL => GoogleFonts.plusJakartaSans(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: FyniqColors.textPrimary,
        letterSpacing: -0.5,
      );
  static TextStyle get headingL => GoogleFonts.plusJakartaSans(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: FyniqColors.textPrimary,
      );
  static TextStyle get headingM => GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: FyniqColors.textPrimary,
      );
  static TextStyle get body => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: FyniqColors.textPrimary,
      );
  static TextStyle get caption => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w300,
        color: FyniqColors.textSecondary,
      );

  static TextStyle get amountStyle => GoogleFonts.spaceGrotesk(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        color: FyniqColors.textPrimary,
      );
}

class FyniqTheme {
  FyniqTheme._();
  static ThemeData darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: FyniqColors.background,
      primaryColor: FyniqColors.primaryAccent,
      colorScheme: const ColorScheme.dark(
        primary: FyniqColors.primaryAccent,
        secondary: FyniqColors.highlightCTA,
        surface: FyniqColors.cardSurface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: FyniqColors.textPrimary,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: FyniqTextStyles.headingXL,
        headlineLarge: FyniqTextStyles.headingL,
        headlineMedium: FyniqTextStyles.headingM,
        bodyLarge: FyniqTextStyles.body,
        labelSmall: FyniqTextStyles.caption,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: FyniqColors.cardSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: FyniqColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: FyniqColors.primaryAccent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: Colors.transparent,
        elevation: 0,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? FyniqColors.primaryAccent
                : null),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? FyniqColors.primaryAccent.withOpacity(0.5)
                : null),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: FyniqColors.cardSurface,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
