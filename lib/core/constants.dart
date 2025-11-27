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
  
  static const LinearGradient romanticGradient = LinearGradient(
    colors: [Color(0xFFFF9EB3), Color(0xFFFFD6E1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppConstants {
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 16.0;
  static const Duration defaultDuration = Duration(milliseconds: 300);
}
