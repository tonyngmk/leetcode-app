import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/settings_repository.dart';

// --- State ---

/// Settings state containing all user preferences.
class SettingsState {
  final ThemeMode themeMode;
  final bool dailyReminder;
  final String? username;

  const SettingsState({
    required this.themeMode,
    required this.dailyReminder,
    this.username,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    bool? dailyReminder,
    String? Function()? username,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      dailyReminder: dailyReminder ?? this.dailyReminder,
      username: username != null ? username() : this.username,
    );
  }
}

// --- Cubit ---

/// Cubit for managing app settings.
/// Theme changes are reactive - MaterialApp rebuilds when themeMode changes.
class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _repository;

  SettingsCubit({required SettingsRepository repository})
      : _repository = repository,
        super(SettingsState(
          themeMode: repository.getThemeMode(),
          dailyReminder: repository.getDailyReminder(),
          username: repository.getUsername(),
        ));

  /// Change the app theme mode.
  /// This triggers a rebuild of MaterialApp.router via BlocBuilder in app.dart.
  Future<void> setThemeMode(ThemeMode mode) async {
    await _repository.setThemeMode(mode);
    emit(state.copyWith(themeMode: mode));
  }

  /// Toggle daily challenge reminder.
  Future<void> setDailyReminder(bool enabled) async {
    await _repository.setDailyReminder(enabled);
    emit(state.copyWith(dailyReminder: enabled));
  }

  /// Update username in settings.
  Future<void> setUsername(String username) async {
    await _repository.setUsername(username);
    emit(state.copyWith(username: () => username));
  }

  /// Clear all settings and reset to defaults.
  Future<void> clearSettings() async {
    await _repository.clearSettings();
    emit(const SettingsState(
      themeMode: ThemeMode.dark,
      dailyReminder: false,
      username: null,
    ));
  }
}
