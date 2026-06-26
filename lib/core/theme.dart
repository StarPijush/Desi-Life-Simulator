import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'design_system.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(
        Brightness.light,
        colorSeed: AppColors.primary,
        surface: AppColors.surface,
        background: AppColors.background,
        onSurface: AppColors.textPrimary,
        onSurfaceVariant: AppColors.textSecondary,
        outline: AppColors.outline,
        error: AppColors.error,
      );

  static ThemeData get dark => _build(
        Brightness.dark,
        colorSeed: AppColors.primary,
        surface: const Color(0xFF1C1C1E),
        background: const Color(0xFF000000),
        onSurface: const Color(0xFFF5F5F5),
        onSurfaceVariant: const Color(0xFF9E9E9E),
        outline: const Color(0xFF3A3A3C),
        error: AppColors.error,
      );

  static ThemeData _build(
    Brightness brightness, {
    required Color colorSeed,
    required Color surface,
    required Color background,
    required Color onSurface,
    required Color onSurfaceVariant,
    required Color outline,
    required Color error,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: colorSeed,
      brightness: brightness,
      surface: surface,
      error: error,
      outline: outline,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,

      // ─── Card ───────────────────────────────────────────
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.xl),
          side: BorderSide(color: outline, width: 1),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),

      // ─── AppBar ──────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTextStyles.displayMd,
        centerTitle: false,
      ),

      // ─── Text ────────────────────────────────────────────
      textTheme: _withEmojiFallback(
        GoogleFonts.interTextTheme(ThemeData(brightness: brightness).textTheme),
      ).copyWith(
        displayLarge: AppTextStyles.displayLg,
        displayMedium: AppTextStyles.displayMd,
        headlineSmall: AppTextStyles.headlineSm,
        bodyLarge: AppTextStyles.bodyLg,
        bodyMedium: AppTextStyles.bodyMd,
        labelLarge: AppTextStyles.labelBold,
        labelSmall: AppTextStyles.labelSm,
      ),

      // ─── Input ───────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
          borderSide: BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
          borderSide: BorderSide(color: outline),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm * 1.5,
        ),
      ),

      // ─── Divider ─────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: outline.withValues(alpha: 0.5),
        thickness: 1,
        space: 1,
      ),

      // ─── Bottom Nav ──────────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        elevation: 0,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
      ),

      // ─── Dialog ──────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.xl),
        ),
      ),

      // ─── Progress Indicator ──────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: Color(0xFFE0E0E0),
      ),
    );
  }
}

const _emojiFallback = [
  'Segoe UI Emoji',
  'Apple Color Emoji',
  'Noto Color Emoji',
];

TextTheme _withEmojiFallback(TextTheme t) {
  return TextTheme(
    displayLarge: t.displayLarge?.copyWith(fontFamilyFallback: _emojiFallback),
    displayMedium: t.displayMedium?.copyWith(fontFamilyFallback: _emojiFallback),
    displaySmall: t.displaySmall?.copyWith(fontFamilyFallback: _emojiFallback),
    headlineLarge: t.headlineLarge?.copyWith(fontFamilyFallback: _emojiFallback),
    headlineMedium: t.headlineMedium?.copyWith(fontFamilyFallback: _emojiFallback),
    headlineSmall: t.headlineSmall?.copyWith(fontFamilyFallback: _emojiFallback),
    titleLarge: t.titleLarge?.copyWith(fontFamilyFallback: _emojiFallback),
    titleMedium: t.titleMedium?.copyWith(fontFamilyFallback: _emojiFallback),
    titleSmall: t.titleSmall?.copyWith(fontFamilyFallback: _emojiFallback),
    bodyLarge: t.bodyLarge?.copyWith(fontFamilyFallback: _emojiFallback),
    bodyMedium: t.bodyMedium?.copyWith(fontFamilyFallback: _emojiFallback),
    bodySmall: t.bodySmall?.copyWith(fontFamilyFallback: _emojiFallback),
    labelLarge: t.labelLarge?.copyWith(fontFamilyFallback: _emojiFallback),
    labelMedium: t.labelMedium?.copyWith(fontFamilyFallback: _emojiFallback),
    labelSmall: t.labelSmall?.copyWith(fontFamilyFallback: _emojiFallback),
  );
}
