import 'package:flutter/material.dart';

/// Centralized color definitions for BillMate
/// These colors are used to build comprehensive light and dark themes
class AppColors {
  // ==================== LIGHT THEME COLORS ====================

  // Primary colors
  static const Color primary = Color(0xFF1565C0); // Strong blue
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFBBDEFB);
  static const Color onPrimaryContainer = Color(0xFF0D47A1);

  // Secondary colors
  static const Color secondary = Color(0xFF00897B); // Teal
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFB2DFDB);
  static const Color onSecondaryContainer = Color(0xFF004D40);

  // Background & Surface (Light)
  static const Color background = Color(
    0xFFF5F5F5,
  ); // Light grey, NOT pure white
  static const Color onBackground = Color(0xFF121212);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF1E1E1E);

  // Status colors (Light)
  static const Color error = Color(0xFFD32F2F);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF1976D2);

  // Borders & Dividers (Light)
  static const Color outline = Color(0xFFBDBDBD);
  static const Color divider = Color(0xFFE0E0E0);

  // ==================== DARK THEME COLORS ====================

  // Primary colors (Dark)
  static const Color primaryDark = Color(0xFF90CAF9); // Muted blue
  static const Color onPrimaryDark = Color(0xFF0B1727);
  static const Color primaryContainerDark = Color(0xFF0D47A1);
  static const Color onPrimaryContainerDark = Color(0xFFE3F2FD);

  // Secondary colors (Dark)
  static const Color secondaryDark = Color(0xFF80CBC4);
  static const Color onSecondaryDark = Color(0xFF06201D);
  static const Color secondaryContainerDark = Color(0xFF004D40);
  static const Color onSecondaryContainerDark = Color(0xFFE0F2F1);

  // Background & Surface (Dark)
  static const Color backgroundDark = Color(0xFF121212); // True dark background
  static const Color onBackgroundDark = Color(0xFFE0E0E0);
  static const Color surfaceDark = Color(
    0xFF1E1E1E,
  ); // Slightly lighter for elevation
  static const Color onSurfaceDark = Color(0xFFE0E0E0);

  // Status colors (Dark)
  static const Color errorDark = Color(0xFFEF9A9A);
  static const Color onErrorDark = Color(0xFF3B0000);
  static const Color successDark = Color(0xFF81C784);
  static const Color warningDark = Color(0xFFFFB74D);
  static const Color infoDark = Color(0xFF64B5F6);

  // Borders & Dividers (Dark)
  static const Color outlineDark = Color(0xFF424242);
  static const Color dividerDark = Color(0xFF2C2C2C);

  // ==================== LEGACY COLORS - Kept for backward compatibility ====================
  // These are legacy colors for existing screens that haven't migrated to the new design system yet
  static const Color primaryDarkOld = Color(0xFF1976D2);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color borderColor = Color(0xFFE0E0E0);
  static const Color dividerColor = Color(0xFFBDBDBD);

  // Adjusted colors for dark theme
  static const Color primaryLight = Color(0xFF64B5F6);
  static const Color errorLight = Color(0xFFEF5350);
  static const Color successLight = Color(0xFF66BB6A);
  static const Color warningLight = Color(0xFFFFB74D);

  static const Color textPrimaryDark = Color(0xFFE8EAED);
  static const Color textSecondaryDark = Color(0xFF9AA0A6);
  static const Color textHintDark = Color(0xFF6C7275);
  static const Color cardBackgroundDark = Color(0xFF1A2142);
  static const Color borderColorDark = Color(0xFF2A3454);
  static const Color dividerColorDark = Color(0xFF2A3454);

  // Context-aware color getters for legacy screens
  static Color getBackground(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  static Color getSurface(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  static Color getTextPrimary(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  static Color getTextSecondary(BuildContext context) {
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }

  static Color getTextHint(BuildContext context) {
    return Theme.of(context).colorScheme.outline;
  }

  static Color getCardBackground(BuildContext context) {
    return Theme.of(context).cardColor;
  }

  static Color getBorderColor(BuildContext context) {
    return Theme.of(context).colorScheme.outline;
  }

  static Color getDividerColor(BuildContext context) {
    return Theme.of(context).dividerColor;
  }
}

class AppGradients {
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [AppColors.primary, Color(0xFF0D47A1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradientDark = LinearGradient(
    colors: [AppColors.primaryDark, AppColors.primaryContainerDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
