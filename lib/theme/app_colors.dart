import 'package:flutter/material.dart';

/// Design tokens for the Billu Monochrome Precision Wireframe system.
class AppColors {
  AppColors._();

  // --- Light Theme Colors ---
  static const Color lightSurface = Color(0xFFF9F9F9);
  static const Color lightSurfaceDim = Color(0xFFDADADA);
  static const Color lightSurfaceBright = Color(0xFFF9F9F9);
  static const Color lightSurfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color lightSurfaceContainerLow = Color(0xFFF3F3F3);
  static const Color lightSurfaceContainer = Color(0xFFEEEEEE);
  static const Color lightSurfaceContainerHigh = Color(0xFFE8E8E8);
  static const Color lightSurfaceContainerHighest = Color(0xFFE2E2E2);
  static const Color lightOnSurface = Color(0xFF1A1C1C);
  static const Color lightOnSurfaceVariant = Color(0xFF4C4546);
  static const Color lightPrimary = Color(0xFF000000);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightPrimaryContainer = Color(0xFF1B1B1B);
  static const Color lightSecondary = Color(0xFF5E5E5E);
  static const Color lightOutline = Color(0xFF7E7576);
  static const Color lightOutlineVariant = Color(0xFFCFC4C5);
  static const Color lightError = Color(0xFFBA1A1A);
  static const Color lightErrorContainer = Color(0xFFFFDAD6);

  // --- Dark Theme Colors ---
  static const Color darkSurface = Color(0xFF0A0A0A);
  static const Color darkSurfaceDim = Color(0xFF131313);
  static const Color darkSurfaceBright = Color(0xFF3A3939);
  static const Color darkSurfaceContainerLowest = Color(0xFF000000);
  static const Color darkSurfaceContainerLow = Color(0xFF141414);
  static const Color darkSurfaceContainer = Color(0xFF201F1F);
  static const Color darkSurfaceContainerHigh = Color(0xFF2A2A2A);
  static const Color darkSurfaceContainerHighest = Color(0xFF353534);
  static const Color darkOnSurface = Color(0xFFEDEDED);
  static const Color darkOnSurfaceVariant = Color(0xFFA1A1AA);
  static const Color darkPrimary = Color(0xFFFFFFFF);
  static const Color darkOnPrimary = Color(0xFF000000);
  static const Color darkPrimaryContainer = Color(0xFFFFFFFF);
  static const Color darkSecondary = Color(0xFFC8C6C5);
  static const Color darkOutline = Color(0xFF7E7576);
  static const Color darkOutlineVariant = Color(0xFF444748);
  static const Color darkError = Color(0xFFFFB4AB);
  static const Color darkErrorContainer = Color(0xFF93000A);
}

/// ThemeExtension to access surface container tokens flexibly in widgets
@immutable
class BilluColorsExtension extends ThemeExtension<BilluColorsExtension> {
  final Color surface;
  final Color surfaceDim;
  final Color surfaceBright;
  final Color surfaceContainerLowest;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color primary;
  final Color onPrimary;
  final Color secondary;
  final Color outline;
  final Color outlineVariant;
  final Color error;

  const BilluColorsExtension({
    required this.surface,
    required this.surfaceDim,
    required this.surfaceBright,
    required this.surfaceContainerLowest,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.outline,
    required this.outlineVariant,
    required this.error,
  });

  static const BilluColorsExtension light = BilluColorsExtension(
    surface: AppColors.lightSurface,
    surfaceDim: AppColors.lightSurfaceDim,
    surfaceBright: AppColors.lightSurfaceBright,
    surfaceContainerLowest: AppColors.lightSurfaceContainerLowest,
    surfaceContainerLow: AppColors.lightSurfaceContainerLow,
    surfaceContainer: AppColors.lightSurfaceContainer,
    surfaceContainerHigh: AppColors.lightSurfaceContainerHigh,
    surfaceContainerHighest: AppColors.lightSurfaceContainerHighest,
    onSurface: AppColors.lightOnSurface,
    onSurfaceVariant: AppColors.lightOnSurfaceVariant,
    primary: AppColors.lightPrimary,
    onPrimary: AppColors.lightOnPrimary,
    secondary: AppColors.lightSecondary,
    outline: AppColors.lightOutline,
    outlineVariant: AppColors.lightOutlineVariant,
    error: AppColors.lightError,
  );

  static const BilluColorsExtension dark = BilluColorsExtension(
    surface: AppColors.darkSurface,
    surfaceDim: AppColors.darkSurfaceDim,
    surfaceBright: AppColors.darkSurfaceBright,
    surfaceContainerLowest: AppColors.darkSurfaceContainerLowest,
    surfaceContainerLow: AppColors.darkSurfaceContainerLow,
    surfaceContainer: AppColors.darkSurfaceContainer,
    surfaceContainerHigh: AppColors.darkSurfaceContainerHigh,
    surfaceContainerHighest: AppColors.darkSurfaceContainerHighest,
    onSurface: AppColors.darkOnSurface,
    onSurfaceVariant: AppColors.darkOnSurfaceVariant,
    primary: AppColors.darkPrimary,
    onPrimary: AppColors.darkOnPrimary,
    secondary: AppColors.darkSecondary,
    outline: AppColors.darkOutline,
    outlineVariant: AppColors.darkOutlineVariant,
    error: AppColors.darkError,
  );

  @override
  BilluColorsExtension copyWith({
    Color? surface,
    Color? surfaceDim,
    Color? surfaceBright,
    Color? surfaceContainerLowest,
    Color? surfaceContainerLow,
    Color? surfaceContainer,
    Color? surfaceContainerHigh,
    Color? surfaceContainerHighest,
    Color? onSurface,
    Color? onSurfaceVariant,
    Color? primary,
    Color? onPrimary,
    Color? secondary,
    Color? outline,
    Color? outlineVariant,
    Color? error,
  }) {
    return BilluColorsExtension(
      surface: surface ?? this.surface,
      surfaceDim: surfaceDim ?? this.surfaceDim,
      surfaceBright: surfaceBright ?? this.surfaceBright,
      surfaceContainerLowest: surfaceContainerLowest ?? this.surfaceContainerLowest,
      surfaceContainerLow: surfaceContainerLow ?? this.surfaceContainerLow,
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh ?? this.surfaceContainerHigh,
      surfaceContainerHighest: surfaceContainerHighest ?? this.surfaceContainerHighest,
      onSurface: onSurface ?? this.onSurface,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      secondary: secondary ?? this.secondary,
      outline: outline ?? this.outline,
      outlineVariant: outlineVariant ?? this.outlineVariant,
      error: error ?? this.error,
    );
  }

  @override
  BilluColorsExtension lerp(ThemeExtension<BilluColorsExtension>? other, double t) {
    if (other is! BilluColorsExtension) return this;
    return BilluColorsExtension(
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceDim: Color.lerp(surfaceDim, other.surfaceDim, t)!,
      surfaceBright: Color.lerp(surfaceBright, other.surfaceBright, t)!,
      surfaceContainerLowest: Color.lerp(surfaceContainerLowest, other.surfaceContainerLowest, t)!,
      surfaceContainerLow: Color.lerp(surfaceContainerLow, other.surfaceContainerLow, t)!,
      surfaceContainer: Color.lerp(surfaceContainer, other.surfaceContainer, t)!,
      surfaceContainerHigh: Color.lerp(surfaceContainerHigh, other.surfaceContainerHigh, t)!,
      surfaceContainerHighest: Color.lerp(surfaceContainerHighest, other.surfaceContainerHighest, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      onSurfaceVariant: Color.lerp(onSurfaceVariant, other.onSurfaceVariant, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      outlineVariant: Color.lerp(outlineVariant, other.outlineVariant, t)!,
      error: Color.lerp(error, other.error, t)!,
    );
  }
}

extension BuildContextColors on BuildContext {
  BilluColorsExtension get billuColors {
    return Theme.of(this).extension<BilluColorsExtension>() ?? BilluColorsExtension.light;
  }
}

