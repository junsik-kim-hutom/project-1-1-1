import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Modern Coral & Rose
  static const Color primary = Color(0xFFFF6B9D); // Soft Coral Pink
  static const Color primaryLight = Color(0xFFFFB3C6);
  static const Color primaryDark = Color(0xFFC2185B);

  // Secondary Colors - Elegant Purple
  static const Color secondary = Color(0xFF7C4DFF); // Modern Purple
  static const Color secondaryLight = Color(0xFFB47CFF);
  static const Color secondaryDark = Color(0xFF5E35B1);

  // Accent Colors
  static const Color accent = Color(0xFFFF4081); // Pink Accent
  static const Color accentLight = Color(0xFFFF80AB);

  // Gradient Colors - Softer & More Modern
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF6B9D), Color(0xFFBF59CF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFF5F7), Color(0xFFF8F4FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Neutral Colors - Clean & Modern
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color background = Color(0xFFFBFBFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF7F7F7);

  // Text Colors - Better Contrast
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textHint = Color(0xFFA8A8A8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Border & Divider - Softer
  static const Color border = Color(0xFFE8E8E8);
  static const Color divider = Color(0xFFF2F2F2);

  // Shadow - Subtle
  static const Color shadow = Color(0x12000000);
  static const Color shadowLight = Color(0x08000000);

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
