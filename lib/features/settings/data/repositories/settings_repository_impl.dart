import 'package:flutter/material.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';

/// Implementation of SettingsRepository using Hive local storage.
class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource _localDataSource;

  SettingsRepositoryImpl({required SettingsLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  @override
  ThemeMode getThemeMode() => _localDataSource.getThemeMode();

  @override
  Future<void> setThemeMode(ThemeMode mode) => _localDataSource.setThemeMode(mode);

  @override
  bool getDailyReminder() => _localDataSource.getDailyReminder();

  @override
  Future<void> setDailyReminder(bool enabled) => _localDataSource.setDailyReminder(enabled);

  @override
  String? getUsername() => _localDataSource.getUsername();

  @override
  Future<void> setUsername(String username) => _localDataSource.setUsername(username);

  @override
  Future<void> clearSettings() => _localDataSource.clear();
}
