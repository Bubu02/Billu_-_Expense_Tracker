import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Pilu Inter-based typographic scale with OpenType tabular figures support.
class AppTypography {
  AppTypography._();

  static TextStyle displayCurrency(Color color) => GoogleFonts.inter(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        height: 52 / 48,
        letterSpacing: -1.92, // -0.04em
        color: color,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static TextStyle displayCurrencyMobile(Color color) => GoogleFonts.inter(
        fontSize: 38,
        fontWeight: FontWeight.w700,
        height: 42 / 38,
        letterSpacing: -1.14, // -0.03em
        color: color,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static TextStyle headlineLg(Color color) => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 30 / 24,
        letterSpacing: -0.48, // -0.02em
        color: color,
      );

  static TextStyle headlineMd(Color color) => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 26 / 20,
        letterSpacing: -0.2, // -0.01em
        color: color,
      );

  static TextStyle bodyLg(Color color) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        letterSpacing: -0.16, // -0.01em
        color: color,
      );

  static TextStyle bodyMd(Color color) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
        letterSpacing: 0,
        color: color,
      );

  static TextStyle numericTabular(Color color) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 20 / 16,
        letterSpacing: -0.16,
        color: color,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static TextStyle numericSm(Color color) => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 16 / 13,
        letterSpacing: 0,
        color: color,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static TextStyle labelCaps(Color color) => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 14 / 11,
        letterSpacing: 0.66, // 0.06em
        color: color,
      );

  static TextStyle labelSubtle(Color color) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 16 / 12,
        letterSpacing: 0,
        color: color,
      );
}

