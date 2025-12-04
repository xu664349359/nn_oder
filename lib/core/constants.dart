import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFFF9EB3); // Soft Pink
  static const Color background = Color(0xFFFFF9FA); // Warm White
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF4A4A4A);
  static const Color textSecondary = Color(0xFF8E8E8E);
  static const Color accent = Color(0xFFFF6B6B); // Heart Red
  static const Color success = Color(0xFF81C784);
  static const Color error = Color(0xFFE57373);
  
  static const Color softPurple = Color(0xFFE0D4FC);
  static const Color warmPink = Color(0xFFFFD6E1);
  static const Color creamyWhite = Color(0xFFFFF9FA);
  
  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFFF3E5F5), Color(0xFFFFEBEE), Color(0xFFFFF3E0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient romanticGradient = LinearGradient(
    colors: [Color(0xFFFF9EB3), Color(0xFFFFD6E1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Dark 3D Theme Colors
  static const Color darkBackground = Color(0xFF1A1F25); // Deep Navy/Black
  static const Color glassWhite = Color(0x33FFFFFF); // Translucent white
  static const Color glassBorder = Color(0x66FFFFFF); // More opaque white for borders
  static const Color cardSurface = Color(0xFFF5F5F7); // Off-white for cards
  
  static const LinearGradient peachGradient = LinearGradient(
    colors: [Color(0xFFFF9A8B), Color(0xFFFF6A88), Color(0xFFFF99AC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [Color(0x4DFFFFFF), Color(0x1AFFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppConstants {
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 16.0;
  static const Duration defaultDuration = Duration(milliseconds: 300);
}
