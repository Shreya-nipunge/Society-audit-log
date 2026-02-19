import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// App text style presets using Poppins (headings) + Inter (body)
class AppTextStyles {
  AppTextStyles._();

  // Headings — Poppins
  static TextStyle get h1 => GoogleFonts.poppins(
    fontSize: 32, // Increased
    fontWeight: FontWeight.bold, // Bold for better readability
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static TextStyle get h2 => GoogleFonts.poppins(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static TextStyle get h3 => GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static TextStyle get h4 => GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // Body — Inter
  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 20, // Increased from 16
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 18, // Increased from 14
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 16, // Minimum 16
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // Labels
  static TextStyle get labelLarge => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
  );

  static TextStyle get labelMedium => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
  );

  // Button Text
  static TextStyle get button => GoogleFonts.poppins(
    fontSize: 18, // Large buttons
    fontWeight: FontWeight.bold,
    letterSpacing: 1.0,
  );

  // Caption
  static TextStyle get caption => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textHint,
    height: 1.4,
  );

  // AppBar Title
  static TextStyle get appBarTitle => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textOnPrimary,
  );

  // Card Title
  static TextStyle get cardTitle => GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  // Card Value (large number)
  static TextStyle get cardValue => GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );
}
