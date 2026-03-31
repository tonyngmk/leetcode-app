import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:algoflow/features/settings/domain/repositories/settings_repository.dart';
import 'package:algoflow/features/settings/presentation/cubits/settings_cubit.dart';

void main() {
  late MockSettingsRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(ThemeMode.dark);
  });

  setUp(() {
    mockRepository = MockSettingsRepository();
  });

  SettingsCubit buildCubit() {
    return SettingsCubit(repository: mockRepository);
  }

  group('SettingsCubit initial state', () {
    test('emits state with repository values on construction', () {
      when(() => mockRepository.getThemeMode()).thenReturn(ThemeMode.light);
      when(() => mockRepository.getDailyReminder()).thenReturn(true);
      when(() => mockRepository.getUsername()).thenReturn('testuser');

      final cubit = buildCubit();

      expect(cubit.state.themeMode, ThemeMode.light);
      expect(cubit.state.dailyReminder, true);
      expect(cubit.state.username, 'testuser');
    });

    test('uses dark theme and no reminder when repo returns defaults', () {
      when(() => mockRepository.getThemeMode()).thenReturn(ThemeMode.dark);
      when(() => mockRepository.getDailyReminder()).thenReturn(false);
      when(() => mockRepository.getUsername()).thenReturn(null);

      final cubit = buildCubit();

      expect(cubit.state.themeMode, ThemeMode.dark);
      expect(cubit.state.dailyReminder, false);
      expect(cubit.state.username, isNull);
    });
  });

  group('SettingsCubit setThemeMode', () {
    blocTest<SettingsCubit, SettingsState>(
      'emits new state with light theme after setThemeMode',
      setUp: () {
        when(() => mockRepository.getThemeMode()).thenReturn(ThemeMode.dark);
        when(() => mockRepository.getDailyReminder()).thenReturn(false);
        when(() => mockRepository.getUsername()).thenReturn(null);
        when(() => mockRepository.setThemeMode(any())).thenAnswer((_) async {});
      },
      build: buildCubit,
      act: (cubit) => cubit.setThemeMode(ThemeMode.light),
      expect: () => [
        isA<SettingsState>().having((s) => s.themeMode, 'themeMode', ThemeMode.light),
      ],
      verify: (_) {
        verify(() => mockRepository.setThemeMode(ThemeMode.light)).called(1);
      },
    );

    blocTest<SettingsCubit, SettingsState>(
      'emits new state with system theme after setThemeMode',
      setUp: () {
        when(() => mockRepository.getThemeMode()).thenReturn(ThemeMode.dark);
        when(() => mockRepository.getDailyReminder()).thenReturn(false);
        when(() => mockRepository.getUsername()).thenReturn(null);
        when(() => mockRepository.setThemeMode(any())).thenAnswer((_) async {});
      },
      build: buildCubit,
      act: (cubit) => cubit.setThemeMode(ThemeMode.system),
      expect: () => [
        isA<SettingsState>().having((s) => s.themeMode, 'themeMode', ThemeMode.system),
      ],
      verify: (_) {
        verify(() => mockRepository.setThemeMode(ThemeMode.system)).called(1);
      },
    );

    blocTest<SettingsCubit, SettingsState>(
      'persists theme mode via repository',
      setUp: () {
        when(() => mockRepository.getThemeMode()).thenReturn(ThemeMode.dark);
        when(() => mockRepository.getDailyReminder()).thenReturn(false);
        when(() => mockRepository.getUsername()).thenReturn(null);
        when(() => mockRepository.setThemeMode(any())).thenAnswer((_) async {});
      },
      build: buildCubit,
      act: (cubit) => cubit.setThemeMode(ThemeMode.dark),
      expect: () => [
        isA<SettingsState>().having((s) => s.themeMode, 'themeMode', ThemeMode.dark),
      ],
      verify: (_) {
        verify(() => mockRepository.setThemeMode(ThemeMode.dark)).called(1);
      },
    );
  });

  group('SettingsCubit setDailyReminder', () {
    blocTest<SettingsCubit, SettingsState>(
      'emits new state with daily reminder enabled',
      setUp: () {
        when(() => mockRepository.getThemeMode()).thenReturn(ThemeMode.dark);
        when(() => mockRepository.getDailyReminder()).thenReturn(false);
        when(() => mockRepository.getUsername()).thenReturn(null);
        when(() => mockRepository.setDailyReminder(any())).thenAnswer((_) async {});
      },
      build: buildCubit,
      act: (cubit) => cubit.setDailyReminder(true),
      expect: () => [
        isA<SettingsState>().having((s) => s.dailyReminder, 'dailyReminder', true),
      ],
      verify: (_) {
        verify(() => mockRepository.setDailyReminder(true)).called(1);
      },
    );

    blocTest<SettingsCubit, SettingsState>(
      'emits new state with daily reminder disabled',
      setUp: () {
        when(() => mockRepository.getThemeMode()).thenReturn(ThemeMode.dark);
        when(() => mockRepository.getDailyReminder()).thenReturn(false);
        when(() => mockRepository.getUsername()).thenReturn(null);
        when(() => mockRepository.setDailyReminder(any())).thenAnswer((_) async {});
      },
      build: buildCubit,
      act: (cubit) => cubit.setDailyReminder(false),
      expect: () => [
        isA<SettingsState>().having((s) => s.dailyReminder, 'dailyReminder', false),
      ],
      verify: (_) {
        verify(() => mockRepository.setDailyReminder(false)).called(1);
      },
    );
  });

  group('SettingsCubit setUsername', () {
    blocTest<SettingsCubit, SettingsState>(
      'emits new state with updated username',
      setUp: () {
        when(() => mockRepository.getThemeMode()).thenReturn(ThemeMode.dark);
        when(() => mockRepository.getDailyReminder()).thenReturn(false);
        when(() => mockRepository.getUsername()).thenReturn(null);
        when(() => mockRepository.setUsername(any())).thenAnswer((_) async {});
      },
      build: buildCubit,
      act: (cubit) => cubit.setUsername('alice'),
      expect: () => [
        isA<SettingsState>().having((s) => s.username, 'username', 'alice'),
      ],
      verify: (_) {
        verify(() => mockRepository.setUsername('alice')).called(1);
      },
    );
  });

  group('SettingsCubit clearSettings', () {
    blocTest<SettingsCubit, SettingsState>(
      'resets state to defaults and clears repository',
      setUp: () {
        when(() => mockRepository.getThemeMode()).thenReturn(ThemeMode.light);
        when(() => mockRepository.getDailyReminder()).thenReturn(true);
        when(() => mockRepository.getUsername()).thenReturn('olduser');
        when(() => mockRepository.clearSettings()).thenAnswer((_) async {});
      },
      build: buildCubit,
      act: (cubit) => cubit.clearSettings(),
      expect: () => [
        const SettingsState(
          themeMode: ThemeMode.dark,
          dailyReminder: false,
          username: null,
        ),
      ],
      verify: (_) {
        verify(() => mockRepository.clearSettings()).called(1);
      },
    );
  });
}

class MockSettingsRepository extends Mock implements SettingsRepository {}
