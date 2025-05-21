import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primaryBlue = Color(0xFF1E88E5);
  static const Color primaryDarkBlue = Color(0xFF1565C0);
  static const Color primaryLightBlue = Color(0xFF64B5F6);
  static const Color successLight =
      Color(0xFFA5D6A7); // Light green for success
  // Secondary colors
  static const Color secondaryBlue = Color(0xFF2979FF);
  static const Color secondaryLightBlue = Color(0xFF82B1FF);

  // Neutral colors
  static const Color black = Color(0xFF000000);
  static const Color darkGrey = Color(0xFF424242);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const Color white = Color(0xFFFFFFFF);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);

  // Background colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Gradient colors
  static const List<Color> blueGradient = [
    primaryLightBlue,
    primaryBlue,
    primaryDarkBlue,
  ];
}
