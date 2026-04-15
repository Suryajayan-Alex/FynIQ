import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class FyniqColors {
  FyniqColors._();

  // ── Logo-Based Premium Dark Palette ──
  static const background = Color(0xFF0F172A);      // Deep Slate/Navy (Logo Dark)
  static const backgroundAlt = Color(0xFF1E293B);   // Slate 800 for cards
  static const cardSurface = Color(0xFF1E293B);      // Consistent surfaces
  
  static const primaryAccent = Color(0xFF22D3EE);    // Cyber Cyan (Logo F)
  static const secondaryAccent = Color(0xFFA855F7);  // Electric Purple (Logo Q)
  static const highlightCTA = Color(0xFFF59E0B);     // Amber/Gold (Logo $)
  
  static const warning = Color(0xFFFB7185);          // Rose for expenses
  static const success = Color(0xFF34D399);          // Emerald for income
  
  static const textPrimary = Color(0xFFF8FAFC);      // White/Slate 50
  static const textSecondary = Color(0xFF94A3B8);    // Slate 400
  static const divider = Color(0xFF334155);          // Slate 700 divider

  // ── Gradient helpers (Logo style) ──
  static const gradientCyan = [Color(0xFF22D3EE), Color(0xFF06B6D4)];
  static const gradientPurple = [Color(0xFFA855F7), Color(0xFFD946EF)];
  static const gradientDark = [Color(0xFF0F172A), Color(0xFF1E293B)];
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
      canvasColor: FyniqColors.background,
      colorScheme: const ColorScheme.dark(
        primary: FyniqColors.primaryAccent,
        secondary: FyniqColors.secondaryAccent,
        surface: FyniqColors.cardSurface,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: FyniqColors.textPrimary,
        error: FyniqColors.warning,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: FyniqColors.textPrimary,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: FyniqColors.background,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: FyniqTextStyles.headingXL,
        headlineLarge: FyniqTextStyles.headingL,
        headlineMedium: FyniqTextStyles.headingM,
        bodyLarge: FyniqTextStyles.body,
        labelSmall: FyniqTextStyles.caption,
      ).apply(
        bodyColor: FyniqColors.textPrimary,
        displayColor: FyniqColors.textPrimary,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: FyniqColors.cardSurface,
        titleTextStyle: FyniqTextStyles.headingM,
        contentTextStyle: FyniqTextStyles.body,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: FyniqColors.background,
        headerBackgroundColor: FyniqColors.primaryAccent,
        headerForegroundColor: Colors.black,
        surfaceTintColor: Colors.transparent,
        dayStyle: FyniqTextStyles.body,
        yearStyle: FyniqTextStyles.body,
        weekdayStyle: FyniqTextStyles.caption.copyWith(color: FyniqColors.primaryAccent),
        dividerColor: FyniqColors.divider,
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: FyniqColors.background,
        hourMinuteColor: FyniqColors.backgroundAlt,
        hourMinuteTextColor: FyniqColors.textPrimary,
        dayPeriodColor: FyniqColors.backgroundAlt,
        dayPeriodTextColor: FyniqColors.textPrimary,
        dialBackgroundColor: FyniqColors.backgroundAlt,
        dialHandColor: FyniqColors.primaryAccent,
        dialTextColor: FyniqColors.textPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: FyniqColors.cardSurface,
        modalBackgroundColor: FyniqColors.cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        elevation: 8,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: FyniqColors.backgroundAlt,
        selectedColor: FyniqColors.primaryAccent.withValues(alpha: 0.2),
        secondarySelectedColor: FyniqColors.primaryAccent,
        labelStyle: FyniqTextStyles.caption.copyWith(color: FyniqColors.textPrimary),
        secondaryLabelStyle: FyniqTextStyles.caption.copyWith(color: Colors.black),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: FyniqColors.divider),
      ),
      dividerTheme: const DividerThemeData(
        color: FyniqColors.divider,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: FyniqColors.textSecondary,
        textColor: FyniqColors.textPrimary,
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: FyniqColors.backgroundAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: FyniqColors.divider, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: FyniqColors.primaryAccent, width: 2),
        ),
        contentPadding: const EdgeInsets.all(20),
        hintStyle: FyniqTextStyles.caption.copyWith(color: FyniqColors.textSecondary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF0F172A),
        elevation: 10,
        selectedItemColor: FyniqColors.primaryAccent,
        unselectedItemColor: FyniqColors.textSecondary,
        type: BottomNavigationBarType.fixed,
      ),
      cardTheme: CardThemeData(
        color: FyniqColors.cardSurface,
        elevation: 4,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: FyniqColors.primaryAccent,
        foregroundColor: Colors.black,
        elevation: 6,
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
        contentTextStyle: const TextStyle(color: FyniqColors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
