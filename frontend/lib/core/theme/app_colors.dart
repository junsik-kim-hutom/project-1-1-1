import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Warm Coral
  static const Color primary = Color(0xFFFF6B6B); // Warm Coral
  static const Color primaryLight = Color(0xFFFFB3A9);
  static const Color primaryDark = Color(0xFFCC4B42);

  // Secondary Colors - Calm Teal
  static const Color secondary = Color(0xFF2BB0A0);
  static const Color secondaryLight = Color(0xFF7CD9C9);
  static const Color secondaryDark = Color(0xFF1F7F74);

  // Accent Colors
  static const Color accent = Color(0xFF3B82F6); // Clean Blue Accent
  static const Color accentLight = Color(0xFF93C5FD);

  // Gradient Colors - Contemporary & Soft
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFFB86B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFF4F0), Color(0xFFFFFBF4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Neutral Colors - Clean & Modern
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color background = Color(0xFFF7F6F4);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF3F1ED);

  // Dark Theme Neutrals
  static const Color darkBackground = Color(0xFF0F1115);
  static const Color darkSurface = Color(0xFF161A23);
  static const Color darkSurfaceVariant = Color(0xFF1E2432);
  static const Color darkBorder = Color(0xFF2B3244);

  // Text Colors - Better Contrast
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textHint = Color(0xFFA8A8A8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  static const Color darkTextPrimary = Color(0xFFE9ECF2);
  static const Color darkTextSecondary = Color(0xFFB4BBC9);
  static const Color darkTextHint = Color(0xFF7E879B);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Border & Divider - Softer
  static const Color border = Color(0xFFE5E1DA);
  static const Color divider = Color(0xFFF0EDE7);

  // Shadow - Subtle
  static const Color shadow = Color(0x11000000);
  static const Color shadowLight = Color(0x07000000);
  static const Color darkShadow = Color(0x66000000);

  // Shimmer Colors (for loading states)
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // Online Status
  static const Color online = Color(0xFF4CAF50);
  static const Color offline = Color(0xFF9E9E9E);

  // Match Score Colors
  static Color getMatchScoreColor(int score) {
    if (score >= 80) return const Color(0xFF4CAF50); // Green
    if (score >= 60) return const Color(0xFF8BC34A); // Light Green
    if (score >= 40) return const Color(0xFFFF9800); // Orange
    return const Color(0xFFFF5722); // Red Orange
  }
}
