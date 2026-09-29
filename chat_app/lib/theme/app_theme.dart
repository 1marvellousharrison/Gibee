import 'package:flutter/material.dart';

/// Colour palette kept identical to the web build.
/// Coral accents from the spec are deliberately mapped to purple.
abstract final class AppColors {
  // Dark
  static const Color bgBlack = Color(0xFF000000);
  static const Color bgCard = Color(0xFF120826);
  static const Color bgSurface = Color(0xFF171129);
  static const Color overlay = Color(0xFF1E1B4B);
  static const Color primary = Color(0xFF7C3AED);
  static const Color midPurple = Color(0xFF5B21B6);
  static const Color lightPurple = Color(0xFFC4B5FD);
  static const Color softLight = Color(0xFFEDE9FE);

  // Light
  static const Color lightBg = Color(0xFFF5F3FF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF0ECFB);
  static const Color lightOverlay = Color(0xFFEDE9FE);
  static const Color lightPrimary = Color(0xFF6D28D9);
  static const Color lightMid = Color(0xFF7C3AED);
  static const Color lightPurpleText = Color(0xFF5B21B6);
  static const Color lightSoft = Color(0xFF1E1B4B);

  // Shared
  static const Color error = Color(0xFFDC2626);
  static const Color success = Color(0xFF059669);
  static const Color amber = Color(0xFFF59E0B);
}

/// Neumorphic shadows in the app's own tones.
abstract final class NeuShadows {
  /// Raised surface: soft highlight top-left, deep shadow bottom-right.
  static List<BoxShadow> outer(BuildContext context, {double radius = 14}) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: dark ? const Color(0x73000000) : const Color(0x1A31145B),
        offset: const Offset(8, 8),
        blurRadius: radius,
      ),
      BoxShadow(
        color: dark ? const Color(0x0DC4B5FD) : const Color(0xE6FFFFFF),
        offset: const Offset(-6, -6),
        blurRadius: radius - 2,
      ),
    ];
  }

  /// Inset well (inputs, search).
  static List<BoxShadow> inset(BuildContext context, {double radius = 10}) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: dark ? const Color(0x61000000) : const Color(0x1A31145B),
        offset: const Offset(5, 5),
        blurRadius: radius,
      ),
      BoxShadow(
        color: dark ? const Color(0x0DC4B5FD) : const Color(0xD9FFFFFF),
        offset: const Offset(-4, -4),
        blurRadius: radius - 1,
      ),
    ];
  }
}

/// Shared text scale from the design spec (Title 22 / Body 15 / Body 14 /
/// Caption 12 / Timestamp 11).
abstract final class AppText {
  static const TextStyle title1 = TextStyle(fontSize: 22, fontWeight: FontWeight.w700);
  static const TextStyle name = TextStyle(fontSize: 15, fontWeight: FontWeight.w600);
  static const TextStyle body = TextStyle(fontSize: 14, fontWeight: FontWeight.w400);
  static const TextStyle caption = TextStyle(fontSize: 12, fontWeight: FontWeight.w400);
  static const TextStyle stamp = TextStyle(fontSize: 11, fontWeight: FontWeight.w600);
  static const TextStyle nameBar = TextStyle(fontSize: 16, fontWeight: FontWeight.w700);
}

abstract final class AppTheme {
  /// Dark neumorphic theme (default).
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData light() => _build(Brightness.light);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
      primary: isDark ? AppColors.primary : AppColors.lightPrimary,
      surface: isDark ? AppColors.bgCard : AppColors.lightCard,
    );
    final textColor = isDark ? AppColors.softLight : AppColors.lightSoft;
    final secondary = isDark ? AppColors.lightPurple : AppColors.lightPurpleText;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark ? AppColors.bgBlack : AppColors.lightBg,
      fontFamilyFallback: const ['Segoe UI', 'Roboto', 'Arial'],
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? AppColors.bgSurface : AppColors.lightSurface,
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppText.title1.copyWith(color: textColor),
        scrolledUnderElevation: 0,
      ),
      textTheme: const TextTheme().apply(
        bodyColor: textColor,
        displayColor: textColor,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        fillColor: isDark ? AppColors.bgSurface : AppColors.lightSurface,
        hintStyle: TextStyle(fontSize: 14, color: secondary.withValues(alpha: .6)),
      ),
      dividerTheme: DividerThemeData(color: secondary.withValues(alpha: .12), thickness: 1),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStatePropertyAll(isDark ? AppColors.softLight : Colors.white),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? AppColors.primary : secondary.withValues(alpha: .25),
        ),
      ),
      listTileTheme: ListTileThemeData(textColor: textColor, iconColor: secondary),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? AppColors.bgSurface : AppColors.lightSurface,
        contentTextStyle: TextStyle(color: textColor, fontSize: 13),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}