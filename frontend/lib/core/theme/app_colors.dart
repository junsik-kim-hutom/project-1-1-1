import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors - Warm Coral
  static const Color primary = Color(0xFFFF6B6B); // Warm Coral
  static const Color primaryLight = Color(0xFFFFB3A9);
  static const Color primaryDark = Color(0xFFCC4B42);

  // Secondary Colors - Calm Teal
  static const Color secondary = Color(0xFF2BB0A0);
  static const Color secondaryLight = Color(0xFF7CD9C9);
  static const Color secondaryDark = Color(0xFF1F7F74);

  // Premium / Special Accents
  static const Color premium = Color(0xFFFFD700); // Gold
  static const Color premiumLight = Color(0xFFFFE57F);
  static const Color premiumDark = Color(0xFFFFC107);

  // Accent Colors
  static const Color accent = Color(0xFF3B82F6); // Clean Blue Accent
  static const Color accentLight = Color(0xFF93C5FD);
  static const Color accentDark = Color(0xFF2563EB);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFFB86B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFF4F0), Color(0xFFFFFBF4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [Colors.white24, Colors.white10],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Neutral Colors - Clean & Modern
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // Light Theme Neutrals
  static const Color background = Color(0xFFF8F9FA); // Slightly cooler gray
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F3F5);
  static const Color border = Color(0xFFE9ECEF);
  static const Color divider = Color(0xFFF1F3F5);
  static const Color inputBackground = Color(0xFFF8F9FA); // Easy on the eyes
  static const Color surfaceExposed = Color(0xFFF1F3F5);

  // Dark Theme Neutrals
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2C2C2C);
  static const Color darkBorder = Color(0xFF333333);
  static const Color darkDivider = Color(0xFF2C2C2C);

  // Text Colors
  static const Color textPrimary = Color(0xFF212529); // Nearly Black
  static const Color textSecondary = Color(0xFF868E96); // Gray
  static const Color textHint = Color(0xFFADB5BD); // Light Gray
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  static const Color darkTextPrimary = Color(0xFFF8F9FA);
  static const Color darkTextSecondary = Color(0xFFADB5BD);
  static const Color darkTextHint = Color(0xFF495057);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFFA5252);
  static const Color warning = Color(0xFFFAB005);
  static const Color info = Color(0xFF228BE6);

  // Shadow
  static const Color shadow = Color(0x1A000000); // 10% Black
  static const Color shadowLight = Color(0x0D000000); // 5% Black
  static const Color darkShadow = Color(0x80000000); // 50% Black

  // Shimmer Colors (for loading states)
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // Match Score Colors
  static Color getMatchScoreColor(int score) {
    if (score >= 90) return const Color(0xFFFF4081); // Pink Accent
    if (score >= 80) return const Color(0xFF4CAF50); // Green
    if (score >= 60) return const Color(0xFFFAB005); // Yellow
    return const Color(0xFF868E96); // Gray
  }
}
