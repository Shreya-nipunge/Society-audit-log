import 'package:flutter/material.dart';

/// App color constants for Society Audit Log
/// Theme: "Corporate FinTech" - Midnight Blue, Muted Gold, and Slate Greys
class AppColors {
  AppColors._();

  // Primary Brand Colors (Professional Navy)
  static const Color primary = Color(0xFF0F2040); // Deep Midnight Blue
  static const Color primaryLight = Color(0xFF1E3A66); // Lighter Navy
  static const Color primaryDark = Color(0xFF071228); // Almost Black-Blue

  // Secondary Brand Colors (Premium Gold)
  static const Color secondary = Color(0xFFC5A065); // Muted Metallic Gold
  static const Color secondaryLight = Color(0xFFE5C48A); // Champagne Gold
  static const Color secondaryDark = Color(0xFF967635); // Bronze Gold

  // Surface & Backgrounds
  static const Color surface = Color(0xFFFFFFFF); // Pure White
  static const Color background = Color(0xFFF8F9FB); // Very subtle cool grey
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Status Colors (Desaturated for professionalism)
  static const Color success = Color(0xFF2E7D32); // Standard Emerald
  static const Color warning = Color(0xFFED6C02); // Burnt Orange
  static const Color error = Color(0xFFD32F2F); // Standard Red
  static const Color info = Color(0xFF0288D1); // Standard Blue

  // Typography
  static const Color textPrimary = Color(
    0xFF000000,
  ); // Pure Black for max contrast
  static const Color textSecondary = Color(0xFF2C2F33); // Very Dark Grey
  static const Color textHint = Color(0xFF636C7A); // Darker Hint Grey
  static const Color textOnSecondary = Color(0xFF000000);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Borders & Dividers
  static const Color divider = Color(0xFFEEEEEE);
  static const Color border = Color(0xFFE0E2E7); // Cool Grey Border

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0F2040), // Primary
      Color(0xFF223E68), // Primary Light
    ],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFC5A065), Color(0xFFE5C48A)],
  );

  // Box Shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0D000000), // 5% Opacity Black
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];
}
