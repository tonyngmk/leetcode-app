# TODO List

## Home Screen & Explore Tab Fixes

### 1. Add spacing between Daily Challenge and Categories
- [x] Add Gap widget between daily challenge and filter chips
- [x] File: `lib/features/problems/presentation/screens/home_screen.dart`

### 2. Redesign difficulty filter buttons
- [x] Replace Wrap with Row + Expanded for stretching
- [x] Add colored icons (green Easy, orange Medium, red Hard)
- [x] Update visual styling
- [x] File: `lib/features/problems/presentation/screens/home_screen.dart`

### 3. Fix Explore tab category navigation
- [x] Modify filterByTag to handle initial ProblemFeedLoading state
- [x] Files:
  - `lib/features/problems/presentation/cubits/problem_feed_cubit.dart`
  - `lib/features/explore/presentation/screens/topic_problems_screen.dart`

### 4. Prevent full app refresh on category/difficulty click
- [x] Add `isFiltering` flag to `ProblemFeedLoaded` state
- [x] Replace full `ProblemFeedLoading()` emit with subtle in-list loading indicator
- [x] File: `lib/features/problems/presentation/cubits/problem_feed_cubit.dart`

### 5. Add search button to top AppBar
- [x] Added magnifying glass icon to HomeScreen SliverAppBar
- [x] File: `lib/features/problems/presentation/screens/home_screen.dart`

### 6. Add settings gear icon to Profile tab
- [x] Added settings icon to ProfileScreen AppBar
- [x] Added `/settings` route to router
- [x] Files:
  - `lib/features/profile/presentation/screens/profile_screen.dart`
  - `lib/router/app_router.dart`

## Solution Cache Integration (leetcode-bot)

- [x] Architecture designed
- [x] Design spec created (spoiler-gated UI)
- [x] Data model, datasource, repository implemented
- [x] `SolutionTabView` widget with spoiler protection
- [x] Integrated into problem detail screen
- [x] Fixed cold-start: lazy-load on demand (not 42MB at startup)
- [x] Fixed null safety in JSON parsing
- [x] Copied `solution_cache.json` to assets/
- [x] Files:
  - `lib/features/solutions/` (data/domain/presentation layers)
  - `lib/features/problems/presentation/screens/problem_detail_screen.dart`

## Settings Feature (Night Mode + More)

- [x] SettingsCubit with reactive ThemeMode
- [x] SettingsLocalDataSource (Hive-based)
- [x] SettingsRepository
- [x] Full settings screen UI (Appearance, Notifications, Account, About, Data sections)
- [x] Integrated into app.dart (MaterialApp rebuilds on theme change)
- [x] Registered in injection.dart
- [x] Design spec at `DESIGN_SETTINGS.md`
- [x] Files:
  - `lib/features/settings/`
  - `lib/app.dart` (updated)
  - `lib/injection.dart` (updated)

## Still Pending

### Daily Challenge Notification Reminder
- [ ] Push notification backend needed (local notifications? Firebase?)
- [ ] The UI (checkbox in settings) is built; the actual scheduling/triggering is not implemented
