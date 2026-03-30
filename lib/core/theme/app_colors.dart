import 'package:flutter/material.dart';

abstract final class AppColors {
  // Dark mode base
  static const background = Color(0xFF0D1117);
  static const surface = Color(0xFF161B22);
  static const card = Color(0xFF21262D);
  static const divider = Color(0xFF30363D);

  // Accent
  static const primary = Color(0xFF58A6FF);

  // Difficulty / status
  static const easy = Color(0xFF3FB950);
  static const medium = Color(0xFFD29922);
  static const hard = Color(0xFFF85149);

  // Text
  static const textPrimary = Color(0xFFE6EDF3);
  static const textSecondary = Color(0xFF8B949E);

  // Light mode
  static const lightBackground = Color(0xFFF6F8FA);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFF6F8FA);
  static const lightDivider = Color(0xFFD0D7DE);
  static const lightTextPrimary = Color(0xFF1F2328);
  static const lightTextSecondary = Color(0xFF656D76);

  static Color difficultyColor(String difficulty) {
    return switch (difficulty.toLowerCase()) {
      'easy' => easy,
      'medium' => medium,
      'hard' => hard,
      _ => textSecondary,
    };
  }
}
