import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static TextTheme _textTheme(Color base) {
    final display = GoogleFonts.soraTextTheme();
    final body = GoogleFonts.plusJakartaSansTextTheme();

    return body.copyWith(
      displayLarge: display.displayLarge?.copyWith(color: base, fontWeight: FontWeight.w700),
      displayMedium: display.displayMedium?.copyWith(color: base, fontWeight: FontWeight.w700),
      headlineLarge: display.headlineLarge?.copyWith(color: base, fontWeight: FontWeight.w700),
      headlineMedium: display.headlineMedium?.copyWith(color: base, fontWeight: FontWeight.w700, letterSpacing: -0.5),
      headlineSmall: display.headlineSmall?.copyWith(color: base, fontWeight: FontWeight.w600),
      titleLarge: display.titleLarge?.copyWith(color: base, fontWeight: FontWeight.w600),
      titleMedium: body.titleMedium?.copyWith(color: base, fontWeight: FontWeight.w600),
      titleSmall: body.titleSmall?.copyWith(color: base, fontWeight: FontWeight.w600),
      bodyLarge: body.bodyLarge?.copyWith(color: base),
      bodyMedium: body.bodyMedium?.copyWith(color: base),
      bodySmall: body.bodySmall?.copyWith(color: base.withOpacity(0.64)),
      labelLarge: body.labelLarge?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.2),
      labelSmall: body.labelSmall?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.6),
    );
  }

  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.paper,
    colorScheme: const ColorScheme.light(
      primary: AppColors.brand,
      onPrimary: Colors.white,
      secondary: AppColors.brandDeep,
      surface: AppColors.surface,
      onSurface: AppColors.ink,
      error: Color(0xFFB3261E),
    ),
    textTheme: _textTheme(AppColors.ink),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.paper,
      foregroundColor: AppColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.sora(
        color: AppColors.ink,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: const IconThemeData(color: AppColors.ink),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.line, thickness: 1, space: 32),

    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 3,
      shadowColor: AppColors.ink.withOpacity(0.08),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.brand,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.brand.withOpacity(0.4),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        elevation: 0,
        textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, letterSpacing: 0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.brand,
        side: const BorderSide(color: AppColors.brand),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.brand,
        textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.brand, width: 1.6),
      ),
      labelStyle: GoogleFonts.plusJakartaSans(color: AppColors.inkMuted),
      hintStyle: GoogleFonts.plusJakartaSans(color: AppColors.inkMuted.withOpacity(0.7)),
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: AppColors.brand,
      tileColor: Colors.transparent,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.brand,
      foregroundColor: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) => Colors.white),
      trackColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected) ? AppColors.brand : AppColors.line),
    ),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.inkDarkBg,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF1565C0),
      onPrimary: Colors.black,
      secondary: AppColors.brandTint,
      surface: AppColors.inkDarkSurface,
      onSurface: Color(0xFFEDEDED),
      error: Color(0xFFFFB4AB),
    ),
    textTheme: _textTheme(const Color(0xFFEDEDED)),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.inkDarkBg,
      foregroundColor: const Color(0xFFEDEDED),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.sora(
        color: const Color(0xFFEDEDED),
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.inkDarkLine, thickness: 1, space: 32),

    cardTheme: CardThemeData(
      color: AppColors.inkDarkSurface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.inkDarkLine),
      ),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4FA593),
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inkDarkSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.inkDarkLine),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.inkDarkLine),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF4FA593), width: 1.6),
      ),
    ),
  );
}
