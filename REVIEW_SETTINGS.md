# Settings Feature Architecture & Design Review

## Status: ARCHITECTURE_SETTINGS.md Not Created

The architecture document was never created. This review is based on DESIGN_SETTINGS.md and the actual implementation files.

---

## Critical Issues

### 1. Settings Changes Do Not Propagate to MaterialApp (CRITICAL BUG)

**File:** `lib/features/settings/presentation/screens/settings_screen.dart` (lines 15-18)

```dart
return BlocProvider(
  create: (_) => SettingsCubit(repository: sl<SettingsRepository>()),
  child: const _SettingsBody(),
);
```

**Problem:** `SettingsScreen` creates a brand-new `SettingsCubit` instance via its own `BlocProvider`. But the root of the widget tree in `app.dart` already has:

```dart
return BlocProvider(
  create: (_) => SettingsCubit(repository: sl()),
  child: BlocBuilder<SettingsCubit, SettingsState>(
    builder: (context, state) {
      return MaterialApp.router(
        themeMode: state.themeMode,  // <-- reads from ROOT cubit
        ...
      );
    },
  ),
);
```

Since `SettingsScreen` is navigated to via `go_router` (outside the settings subtree), the `BlocProvider` it creates is a **sibling** of the app router's navigator, not a parent. The new cubit instance is completely isolated from the root cubit.

**Effect:** When the user changes the theme in Settings, the local `SettingsCubit` updates and the UI re-renders with the new theme choice. However, the root `SettingsCubit` in `app.dart` never sees the change, so the theme is visually correct on the settings screen but will reset to the original on the next app restart. The persistence via Hive works, but the app-level `MaterialApp.router` does not reflect live changes because `BlocBuilder` is listening to the root cubit's state, not the settings screen's local cubit.

**Fix:** Remove the `BlocProvider` from `SettingsScreen` and instead rely on the root cubit. The `BlocProvider<SettingsCubit>` in `app.dart` must be above the `RouterDelegate`/`GoRouter` in the widget tree (it already is), and `SettingsScreen` should simply call `context.read<SettingsCubit>()` directly:

```dart
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // No BlocProvider here -- use root cubit from app.dart
    return const _SettingsBody();
  }
}
```

This requires verifying that `app.dart`'s `BlocProvider<SettingsCubit>` wraps the entire app (including the router). With `go_router` and `StatefulShellRoute`, the BlocProvider at the app level should suffice.

---

### 2. Daily Challenge Reminder Is Non-Functional

**Files:** DESIGN_SETTINGS.md (lines 88-91, 276-313), `settings_cubit.dart` (line 55)

**Problem:** The design specifies a time picker for a "Daily Challenge Reminder" and the implementation stores the preference via `setDailyReminder(bool enabled)`. However, there is no push notification backend anywhere in the codebase. The app:

- Does not use `flutter_local_notifications` or any notification package
- Has no background task / scheduler registered
- Has no server-side component for scheduled notifications
- The Hive key `daily_reminder` is written but never read by any notification service

**Effect:** The toggle does nothing. Enabling it stores `true` in Hive and shows UI feedback, but the user receives no notification at the scheduled (or any) time.

**Recommendation:** Either remove the feature until a notification backend is implemented, or add `flutter_local_notifications` with proper iOS/Android foreground service configuration. The time picker UI should be gated behind a "coming soon" badge or removed entirely.

---

### 3. Hive Is Overkill for 3 Simple Key-Value Preferences

**Files:** `lib/features/settings/data/datasources/settings_local_datasource.dart`, `lib/injection.dart` (line 30)

The implementation creates a dedicated Hive box (`'settings'`) with 4 keys (`theme_mode`, `daily_reminder`, `username`) to persist simple preferences.

**Why this is disproportionate:**

| Preference | Storage Type | Hive Overhead |
|---|---|---|
| `theme_mode` (string) | 1 key | Separate box + adapter |
| `daily_reminder` (bool) | 1 key | Separate box + adapter |
| `username` (string) | 1 key | Separate box + adapter |

Hive is designed for structured, typed data (problem lists, solution caches, user data). For a handful of key-value strings and booleans, `shared_preferences` is the standard Flutter choice:

```dart
// With SharedPreferences:
final prefs = await SharedPreferences.getInstance();
await prefs.setString('theme_mode', 'dark');
final theme = prefs.getString('theme_mode') ?? 'dark';
```

**Benefits of SharedPreferences:**
- No box initialization at startup (lazy, automatic)
- No separate Hive adapter registration
- Native platform persistence (UserDefaults on iOS, SharedPreferences on Android)
- Much faster for single-key reads/writes
- Standard practice in Flutter for app settings

**Note:** The DESIGN_SETTINGS.md itself hedges with "SharedPreferences or Hive" (line 338), acknowledging this ambiguity. Given the app already uses Hive for complex data (problems, solutions), using SharedPreferences for settings would be more appropriate and consistent with Flutter best practices.

---

### 4. `username` Field Duplicates Profile Data

**Files:** `settings_repository.dart`, `settings_local_datasource.dart`, `settings_cubit.dart`, `injection.dart` (line 30), profile feature

**Problem:** The settings feature stores a `username` field in its Hive box. However, the profile feature (`ProfileLocalDataSource` using `user_data` box) also stores user data including the LeetCode username. This creates:

1. **Data duplication**: Two places to update username
2. **Potential inconsistency**: Profile might have a different username than settings
3. **Confusion**: Which one is authoritative?

**Recommendation:** Remove `username` from settings entirely. The profile feature should be the single source of truth for user identity. If the design intent was to allow setting the username before authentication, this is a pre-auth flow concern that belongs in the onboarding feature, not settings.

---

## Design Issues

### 5. Deviation from DESIGN_SETTINGS.md

The implementation diverges from the design in significant ways:

| Design | Implementation |
|---|---|
| `SegmentedButton<int>` for night mode | `ListTile` radio-style theme selector with check icons |
| Time picker for daily reminder (00:00 UTC) | No time picker UI -- just a toggle |
| `SettingsTile` reusable component | `_SettingsCard` and `_SectionHeader` private widgets |
| `AnimatedOpacity` for time row reveal | Not implemented |
| Time picker code in design (lines 293-312) | Not in implementation |

The implementation added features NOT in the design: **Account section** (username dialog, LeetCode username) and **Data section** (clear settings). The design only had Appearance and Notifications sections.

---

### 6. `username` Storage Key Missing from DataSource

**File:** `settings_local_datasource.dart` (line 9)

The data source declares `static const String _usernameKey = 'username'` but the Hive box is registered as `Box<dynamic>` with no type adapter for a custom model. Since username is just a `String?`, this works fine. However, this field should be removed (see issue #4 above).

---

### 7. Cubit State Lacks Sealed Class Pattern

**File:** `settings_cubit.dart` (lines 8-30)

The app's established pattern (per CLAUDE.md and other cubits) uses sealed class states:

```dart
// App convention (from CLAUDE.md):
sealed class ProblemFeedState {}
class ProblemFeedLoading extends ProblemFeedState {}
class ProblemFeedLoaded extends ProblemFeedState { ... }
```

But `SettingsState` is a plain class, not a sealed hierarchy. While this is functionally fine for a single-state cubit, it's inconsistent with the codebase convention. Consider:

```dart
sealed class SettingsState {
  ThemeMode get themeMode;
  bool get dailyReminder;
  String? get username;
}

class SettingsLoaded extends SettingsState { ... }
```

---

## Minor Issues

### 8. Theme Option Subtitles Are Redundant

**File:** `settings_screen.dart` (lines 270, 278, 286)

The theme options include subtitles ("Easy on the eyes at night", "Classic daytime look", "Follow device settings"). For dark/light/system, the icon + title is already self-explanatory. The subtitles add visual noise without information value.

### 9. "Version 1.0.0" Hardcoded

**File:** `settings_screen.dart` (line 95)

The version is hardcoded as a string in the UI. This should come from `package_info_plus` or `pubspec.yaml` to stay in sync.

---

## Summary Table

| # | Severity | Issue | Recommendation |
|---|---|---|---|
| 1 | **Critical** | Settings changes don't propagate to root cubit / MaterialApp | Remove BlocProvider from SettingsScreen; use root cubit |
| 2 | **High** | Daily reminder is non-functional (no notification backend) | Remove or implement `flutter_local_notifications` |
| 3 | **Medium** | Hive is overkill for simple key-value prefs | Migrate to SharedPreferences |
| 4 | **Medium** | `username` duplicates profile feature data | Remove from settings; use profile as sole source of truth |
| 5 | **Low** | Implementation diverges from DESIGN_SETTINGS.md | Align implementation with design, or update design doc |
| 6 | **Low** | SettingsState not a sealed class | Follow codebase convention |
| 7 | **Low** | Hardcoded version string | Use `package_info_plus` |
| 8 | **Low** | Redundant theme subtitles | Remove subtitles |
