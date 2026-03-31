import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Local data source for app settings using Hive.
/// Persists theme mode, daily challenge reminder, and other preferences.
class SettingsLocalDataSource {
  static const String _themeModeKey = 'theme_mode';
  static const String _dailyReminderKey = 'daily_reminder';
  static const String _usernameKey = 'username';

  final Box<dynamic> _box;

  SettingsLocalDataSource({required Box<dynamic> box}) : _box = box;

  /// Get the stored theme mode. Defaults to dark.
  ThemeMode getThemeMode() {
    final value = _box.get(_themeModeKey, defaultValue: 'dark');
    return switch (value) {
      'light' => ThemeMode.light,
      'system' => ThemeMode.system,
      _ => ThemeMode.dark,
    };
  }

  /// Save the theme mode preference.
  Future<void> setThemeMode(ThemeMode mode) async {
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.system => 'system',
      _ => 'dark',
    };
    await _box.put(_themeModeKey, value);
  }

  /// Get daily challenge reminder preference.
  bool getDailyReminder() {
    return _box.get(_dailyReminderKey, defaultValue: false) as bool;
  }

  /// Save daily challenge reminder preference.
  Future<void> setDailyReminder(bool enabled) async {
    await _box.put(_dailyReminderKey, enabled);
  }

  /// Get stored username (for profile sync).
  String? getUsername() {
    return _box.get(_usernameKey) as String?;
  }

  /// Save username.
  Future<void> setUsername(String username) async {
    await _box.put(_usernameKey, username);
  }

  /// Clear all settings.
  Future<void> clear() async {
    await _box.clear();
  }
}
