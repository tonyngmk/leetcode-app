# Settings Screen Design Specification

## Overview

The Settings screen provides user preference management for the AlgoFlow app. It follows the app's GitHub-inspired dark palette with a clean, list-based layout using section headers. The screen is accessible from the Profile screen via the settings icon in the app bar.

---

## Screen Layout

### App Bar
- Title: `"Settings"` — `titleLarge` style
- Back button (automatic via `Scaffold` / navigation shell)
- No actions in the app bar (clean, minimal)

### Body
- `SingleChildScrollView` with `EdgeInsets.all(AppSpacing.m)` padding
- Vertical column of settings sections
- Each section separated by a `Gap(AppSpacing.l)`

---

## Settings Sections

### Section 1: Appearance

**Night Mode** — 3-state segmented control

A `SegmentedButton<int>` with three options:

| Index | Label       | Icon                        |
|-------|-------------|-----------------------------|
| 0     | Dark        | `Icons.dark_mode_outlined`  |
| 1     | Light       | `Icons.light_mode_outlined` |
| 2     | System      | `Icons.brightness_auto`     |

- Default selection: 2 (System)
- Selected state: `AppColors.primary` background, white text
- Unselected state: `AppColors.card` background, `AppColors.textSecondary` text
- Container: full width, `AppSpacing.radiusMedium` border radius
- Visual: a pill-shaped container with `AppColors.surface` background, containing three equal-width segments

```
Container(
  decoration: BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
    border: Border.all(color: AppColors.divider),
  ),
  child: SegmentedButton<int>(
    segments: [...],
    selected: {...},
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return Colors.transparent;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white;
        }
        return AppColors.textSecondary;
      }),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSmall)),
      ),
    ),
  ),
)
```

---

### Section 2: Notifications

**Daily Challenge Reminder** — Toggle row with conditional time display

A `SettingsTile` widget (see Components below) with:
- Leading icon: `Icons.notifications_outlined`
- Title: `"Daily Challenge Reminder"`
- Trailing: `Switch` widget

When the switch is **on**, an additional row appears below the toggle with:
- Indent: `AppSpacing.xl` (to visually nest under the parent)
- Leading icon: `Icons.access_time_outlined` (smaller, `AppColors.textSecondary`)
- Title: Shows the selected time in 24-hour format: `"00:00 UTC"` — `titleMedium` style, `AppColors.textPrimary`
- Trailing: A tappable `Icons.chevron_right` that opens a time picker
- The time picker uses `showTimePicker` with initial time `TimeOfDay(hour: 0, minute: 0)` (midnight UTC)

```
// Time display row (shown when switch is on)
Gap(AppSpacing.s),
Padding(
  padding: const EdgeInsets.only(left: AppSpacing.xl),
  child: SettingsTile(
    leading: const Icon(Icons.access_time_outlined, color: AppColors.textSecondary, size: 20),
    title: '00:00 UTC',
    trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
    onTap: () => _showTimePicker(context),
  ),
),
```

---

## Reusable Components

### `SettingsSectionHeader`

A text label that precedes each settings group.

```
class SettingsSectionHeader extends StatelessWidget {
  final String title;

  const SettingsSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}
```

### `SettingsTile`

A tappable list item row used throughout settings.

```
class SettingsTile extends StatelessWidget {
  final IconData? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SettingsTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.m,
            vertical: AppSpacing.s + 4,
          ),
          child: Row(
            children: [
              if (leading != null) ...[
                Icon(leading, color: AppColors.textSecondary, size: 22),
                const Gap(AppSpacing.m),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    if (subtitle != null) ...[
                      const Gap(AppSpacing.xs),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## Page Structure (Code Outline)

```dart
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Section 1: Appearance
            const SettingsSectionHeader(title: 'Appearance'),
            const Gap(AppSpacing.s),
            _NightModeSelector(),

            const Gap(AppSpacing.l),

            // Section 2: Notifications
            const SettingsSectionHeader(title: 'Notifications'),
            const Gap(AppSpacing.s),
            _DailyChallengeReminderTile(),

          ],
        ),
      ),
    );
  }
}
```

---

## Color & Spacing Reference

| Token                  | Value                     | Usage                              |
|------------------------|---------------------------|------------------------------------|
| `AppColors.background` | `#0D1117`                 | Page background                    |
| `AppColors.surface`    | `#161B22`                 | Section containers, cards          |
| `AppColors.card`       | `#21262D`                 | List tiles, input backgrounds     |
| `AppColors.divider`    | `#30363D`                 | Borders, separators                |
| `AppColors.primary`    | `#58A6FF`                 | Active selections, toggles on      |
| `AppColors.textPrimary`| `#E6EDF3`                | Main text                          |
| `AppColors.textSecondary`| `#8B949E`              | Subtitles, icons, labels           |
| `AppSpacing.m`         | `16`                      | Page padding, section gaps         |
| `AppSpacing.s`         | `8`                       | Tight spacing within tiles         |
| `AppSpacing.xs`        | `4`                       | Micro spacing                      |
| `AppSpacing.radiusMedium`| `12`                   | Card/tile border radius            |
| `AppSpacing.radiusSmall`| `6`                     | Inner element radius               |

---

## Typography Reference

| Style          | Usage                          |
|----------------|--------------------------------|
| `titleLarge`   | App bar title                  |
| `titleMedium`  | Settings tile titles          |
| `bodySmall`    | Subtitles, secondary labels    |
| `labelSmall`   | Section headers (uppercased)   |

All typography uses the `Inter` font family via `AppTypography.textTheme()`.

---

## Interaction Details

### Night Mode Selector
- Tapping any segment immediately selects it
- State managed via `SettingsCubit` (see below)
- No confirmation dialog needed — instant update

### Daily Challenge Reminder Toggle
- `Switch` thumb: `AppColors.primary` when on
- When toggled **on**: time row animates in with a 200ms `AnimatedOpacity`
- When toggled **off**: time row fades out, time preference is preserved

### Time Picker
- Opens `showTimePicker` dialog
- Returns time in UTC; displays as `"HH:mm UTC"` using 24-hour format
- Default: `00:00` (midnight UTC)
- Uses `MediaQuery.of(context).copyWith(...)` to enforce dark theme in picker

```dart
Future<void> _showTimePicker(BuildContext context) async {
  final TimeOfDay? picked = await showTimePicker(
    context: context,
    initialTime: const TimeOfDay(hour: 0, minute: 0),
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            surface: AppColors.surface,
          ),
        ),
        child: child!,
      );
    },
  );
  if (picked != null) {
    context.read<SettingsCubit>().setReminderTime(picked);
  }
}
```

---

## State Management

### `SettingsCubit`

```dart
// States
sealed class SettingsState {}
class SettingsInitial extends SettingsState {}
class SettingsLoaded extends SettingsState {
  final ThemeMode themeMode;      // dark / light / system
  final bool reminderEnabled;
  final TimeOfDay reminderTime;    // stored in local time, displayed as UTC
}

// Methods
void setThemeMode(ThemeMode mode);
void setReminderEnabled(bool enabled);
void setReminderTime(TimeOfDay time);
```

### Persistence
- All preferences stored locally via `SharedPreferences` or a dedicated Hive box (`settings`)
- Keys: `theme_mode` (string: `"dark"`, `"light"`, `"system"`), `reminder_enabled` (bool), `reminder_hour` (int), `reminder_minute` (int)
- Preferences loaded on app startup via `initDependencies()`

---

## Navigation

- Entry point: Profile screen → settings icon button → `/settings`
- Back: standard back gesture or app bar back button
- No nested navigation within settings

---

## Accessibility

- All `SettingsTile` items use `InkWell` for tap feedback
- `Switch` widgets are fully accessible via Flutter's built-in semantics
- Section headers use `labelSmall` style for visual hierarchy without relying on color alone
- Minimum touch target: 48x48dp per Material guidelines (met by tile padding)
