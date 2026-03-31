import 'package:flutter/material.dart';

/// Abstract repository interface for settings.
/// Defines the contract for managing app preferences.
abstract class SettingsRepository {
  /// Get the current theme mode.
  ThemeMode getThemeMode();

  /// Save the theme mode preference.
  Future<void> setThemeMode(ThemeMode mode);

  /// Get daily challenge reminder preference.
  bool getDailyReminder();

  /// Save daily challenge reminder preference.
  Future<void> setDailyReminder(bool enabled);

  /// Get stored username.
  String? getUsername();

  /// Save username.
  Future<void> setUsername(String username);

  /// Clear all settings.
  Future<void> clearSettings();
}
