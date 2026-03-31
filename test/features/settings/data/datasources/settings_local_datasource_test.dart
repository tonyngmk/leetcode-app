import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:algoflow/features/settings/data/datasources/settings_local_datasource.dart';

void main() {
  group('SettingsLocalDataSource theme mode', () {
    late Box<dynamic> box;
    late SettingsLocalDataSource ds;

    setUp(() {
      box = FakeHiveBox();
      ds = SettingsLocalDataSource(box: box);
    });

    tearDown(() async {
      await box.close();
    });

    test('defaults to dark ThemeMode', () {
      expect(ds.getThemeMode(), ThemeMode.dark);
    });

    test('setThemeMode persists light mode', () async {
      await ds.setThemeMode(ThemeMode.light);
      expect(ds.getThemeMode(), ThemeMode.light);
    });

    test('setThemeMode persists system mode', () async {
      await ds.setThemeMode(ThemeMode.system);
      expect(ds.getThemeMode(), ThemeMode.system);
    });

    test('setThemeMode persists dark mode', () async {
      await ds.setThemeMode(ThemeMode.dark);
      expect(ds.getThemeMode(), ThemeMode.dark);
    });
  });

  group('SettingsLocalDataSource daily reminder', () {
    late Box<dynamic> box;
    late SettingsLocalDataSource ds;

    setUp(() {
      box = FakeHiveBox();
      ds = SettingsLocalDataSource(box: box);
    });

    tearDown(() async {
      await box.close();
    });

    test('defaults to false', () {
      expect(ds.getDailyReminder(), false);
    });

    test('setDailyReminder persists true', () async {
      await ds.setDailyReminder(true);
      expect(ds.getDailyReminder(), true);
    });

    test('setDailyReminder persists false', () async {
      await ds.setDailyReminder(false);
      expect(ds.getDailyReminder(), false);
    });
  });

  group('SettingsLocalDataSource username', () {
    late Box<dynamic> box;
    late SettingsLocalDataSource ds;

    setUp(() {
      box = FakeHiveBox();
      ds = SettingsLocalDataSource(box: box);
    });

    tearDown(() async {
      await box.close();
    });

    test('getUsername returns null when not set', () {
      expect(ds.getUsername(), isNull);
    });

    test('setUsername persists the value', () async {
      await ds.setUsername('testuser');
      expect(ds.getUsername(), 'testuser');
    });

    test('setUsername overwrites previous value', () async {
      await ds.setUsername('user1');
      await ds.setUsername('user2');
      expect(ds.getUsername(), 'user2');
    });
  });

  group('SettingsLocalDataSource clear', () {
    late Box<dynamic> box;
    late SettingsLocalDataSource ds;

    setUp(() {
      box = FakeHiveBox();
      ds = SettingsLocalDataSource(box: box);
    });

    tearDown(() async {
      await box.close();
    });

    test('clear resets all settings to defaults', () async {
      await ds.setThemeMode(ThemeMode.light);
      await ds.setDailyReminder(true);
      await ds.setUsername('testuser');

      await ds.clear();

      expect(ds.getThemeMode(), ThemeMode.dark);
      expect(ds.getDailyReminder(), false);
      expect(ds.getUsername(), isNull);
    });
  });
}

/// Fake Hive Box backed by an in-memory Map.
/// Implements only the members used by SettingsLocalDataSource.
class FakeHiveBox implements Box<dynamic> {
  final Map<dynamic, dynamic> _data = {};

  @override
  dynamic get(dynamic key, {dynamic defaultValue}) {
    return _data.containsKey(key) ? _data[key] : defaultValue;
  }

  @override
  Future<void> put(dynamic key, dynamic value) async {
    _data[key] = value;
  }

  @override
  Future<int> clear() async {
    final count = _data.length;
    _data.clear();
    return count;
  }

  @override
  bool containsKey(dynamic key) => _data.containsKey(key);

  @override
  Future<void> close() async {}

  // Stub all other Box members not used by SettingsLocalDataSource.
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
