import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF5E6B56);      // Dark forest green
  static const Color primaryLight = Color(0xFF829079);
  static const Color primaryDark = Color(0xFF3C4636);
  static const Color accent = Color(0xFF5E6B56);
  static const Color accentGold = Color(0xFF8B9B82);   // Sagey gold
  static const Color accentGreen = Color(0xFF5E6B56);
  static const Color accentOrange = Color(0xFF829079);

  // Backgrounds
  static const Color background = Color(0xFFF2EFEA);   // Warm cream background
  static const Color surface = Color(0xFFFFFFFF);      // Card surface
  static const Color surfaceLight = Color(0xFFA8B5A2); // Light surface / sage green
  static const Color gridBg = Color(0xFFF2EFEA);       // Grid background

  // Arrow direction colors — solid dark green for maximum legibility
  static const Color arrowUp    = Color(0xFF3C4636);
  static const Color arrowDown  = Color(0xFF3C4636);
  static const Color arrowLeft  = Color(0xFF3C4636);
  static const Color arrowRight = Color(0xFF3C4636);

  // Difficulty colors
  static const Color easy = Color(0xFF829079);
  static const Color medium = Color(0xFF708066);
  static const Color hard = Color(0xFF5E6B56);
  static const Color expert = Color(0xFF4C5745);
  static const Color master = Color(0xFF3C4636);

  // Text
  static const Color textPrimary = Color(0xFF3C4636);
  static const Color textSecondary = Color(0xFF5E6B56);
  static const Color textMuted = Color(0xFF829079);

  // UI Elements
  static const Color heartRed = Color(0xFF5E6B56);
  static const Color heartEmpty = Color(0xFFD3CFC9);
  static const Color streakFire = Color(0xFF5E6B56);
  static const Color coinGold = Color(0xFF829079);
  static const Color starYellow = Color(0xFF5E6B56);
  static const Color borderGlow = Color(0xFF5E6B56);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF5E6B56), Color(0xFF7A8972)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFFA8B5A2), Color(0xFFC0CDC0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFFF2EFEA), Color(0xFFE2DFDA)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF5E6B56), Color(0xFF708066)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dangerGradient = LinearGradient(
    colors: [Color(0xFF8B5E56), Color(0xFFA27870)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
