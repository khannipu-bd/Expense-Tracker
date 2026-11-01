import 'package:flutter/material.dart';

class AppColors {
  // Light Theme Colors
  static const Color primaryLight = Color(0xFF0D9488); // Emerald / Teal 600
  static const Color primaryContainerLight = Color(0xFFCCFBF1);
  static const Color backgroundLight = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF1F5F9); // Slate 100
  static const Color textPrimaryLight = Color(0xFF0F172A); // Slate 900
  static const Color textSecondaryLight = Color(0xFF64748B); // Slate 500
  static const Color borderLight = Color(0xFFE2E8F0); // Slate 200

  // Dark Theme Colors
  static const Color primaryDark = Color(0xFF14B8A6); // Teal 500
  static const Color primaryContainerDark = Color(0xFF115E59);
  static const Color backgroundDark = Color(0xFF0F172A); // Slate 900
  static const Color surfaceDark = Color(0xFF1E293B); // Slate 800
  static const Color surfaceVariantDark = Color(0xFF334155); // Slate 700
  static const Color textPrimaryDark = Color(0xFFF8FAFC); // Slate 50
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Slate 400
  static const Color borderDark = Color(0xFF334155); // Slate 700

  // Transaction Colors (Both Themes)
  static const Color incomeGreen = Color(0xFF10B981); // Emerald 500
  static const Color incomeBg = Color(0xFFECFDF5); // Emerald 50
  static const Color expenseRed = Color(0xFFEF4444); // Red 500
  static const Color expenseBg = Color(0xFFFEF2F2); // Red 50

  // Accent & Category Palette
  static const List<Color> categoryPalette = [
    Color(0xFF3B82F6), // Blue
    Color(0xFF8B5CF6), // Purple
    Color(0xFFEC4899), // Pink
    Color(0xFFF59E0B), // Amber
    Color(0xFF10B981), // Emerald
    Color(0xFF06B6D4), // Cyan
    Color(0xFF6366F1), // Indigo
    Color(0xFFF97316), // Orange
    Color(0xFF14B8A6), // Teal
    Color(0xFF64748B), // Slate
  ];
}
