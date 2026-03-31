# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**AlgoFlow** is a LeetCode-inspired mobile coding challenge app built with Flutter. It enables software engineers to practice data structures and algorithms (DSA) with a premium, modern UI/UX inspired by top-tier apps like Duolingo, Linear, and GitHub Mobile.

- **Platform**: iOS & Android (Flutter cross-platform)
- **Min SDK**: Dart 3.11.4+
- **Primary Theme**: Dark mode (light mode supported)
- **Data Source**: LeetCode GraphQL API

## Architecture

The app follows **Clean Architecture** with three distinct layers:

### Layer Structure
```
lib/
├── core/               # Shared, cross-cutting concerns
│   ├── constants/      # API queries, app constants
│   ├── errors/         # Failure definitions
│   ├── network/        # Dio client, auth interceptors
│   ├── theme/          # AppTheme, colors, typography, spacing
│   └── utils/          # HTML parsing, date utilities
├── features/           # Feature modules (auth, problems, editor, profile, etc.)
│   └── {feature}/
│       ├── domain/     # Use cases, repository interfaces, entities
│       ├── data/       # Repository implementations, models, data sources (remote/local)
│       └── presentation/ # Cubits/BloCs, screens, widgets
├── router/             # GoRouter configuration & navigation setup
└── shared/             # Reusable widgets, design system components
```

### Key Patterns

**State Management**: `flutter_bloc` with Cubit (for simplicity over full BLoC)
- Each feature has a Cubit (e.g., `ProblemFeedCubit`, `ProblemDetailCubit`) managing feature state
- States use sealed classes for type safety
- Example: `lib/features/problems/presentation/cubits/problem_feed_cubit.dart`

**Navigation**: `go_router` with named routes and deep linking
- Main shell using `StatefulShellRoute.indexedStack` for bottom nav
- Problem detail → code editor uses nested routes: `/problem/:slug` → `/problem/:slug/editor`
- See `lib/router/app_router.dart`

**Dependency Injection**: `get_it` singleton service locator
- All repos, data sources, and services registered in `lib/injection.dart`
- Network client (`DioClient`) and auth interceptor are singletons
- Hive boxes for local storage are initialized in `initDependencies()`

**Data Fetching**: Dio HTTP client with custom auth interceptor
- All API calls go through LeetCode GraphQL endpoint
- `AuthInterceptor` handles token management
- Queries defined in `lib/core/constants/api_constants.dart`

**Local Storage**: Hive for offline problem caching
- Separate boxes: `problems`, `solutions`, `user_data`
- Models are serialized to/from `Map<dynamic, dynamic>`
- Initialize boxes in `initDependencies()` before using

## Common Development Commands

### Run the App
```bash
# Run on default device/emulator (debug mode)
flutter run

# Run with verbose logging
flutter run -v

# Run in release mode (optimized)
flutter run --release
```

### Code Generation & Build Setup
```bash
# Generate files (injectable, hive adapters, etc.)
flutter pub run build_runner build

# Clean and rebuild generated files
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate on file changes)
flutter pub run build_runner watch
```

### Analysis & Linting
```bash
# Analyze code for issues
flutter analyze

# Format code
dart format lib/

# Run lints
flutter pub run flutter_lints
```

### Testing
```bash
# Run all tests
flutter test

# Run tests with verbose output
flutter test -v

# Run tests for a specific file
flutter test test/features/problems/presentation/cubits/problem_feed_cubit_test.dart
```

### Build & Distribution
```bash
# Clean build artifacts
flutter clean

# Build iOS app
flutter build ios --release

# Build Android APK
flutter build apk --release

# Build Android App Bundle
flutter build appbundle --release
```

## Design System Reference

The app enforces a strict design system defined in `lib/core/theme/`:

- **Colors**: GitHub-inspired dark palette (see `app_colors.dart`)
  - Background: `#0D1117`, Surface: `#161B22`, Primary: `#58A6FF`
  - Difficulty colors: Easy (green), Medium (amber), Hard (red)
- **Typography**: Inter (body) + JetBrains Mono (code) via `google_fonts`
- **Spacing**: 8pt grid (xs=4, s=8, m=16, l=24, xl=32, xxl=48)
- **Border Radius**: 6px (small), 12px (medium), 20px (large)
- **Never hardcode**: All colors, fonts, spacing via `AppColors`, `AppTypography`, `AppSpacing`

For complete design specs including color palettes, motion curves, and UI/UX principles, see `STARTER.md`.

## Feature Modules

### Auth (`features/auth`)
- Onboarding & login screens
- `AuthCubit` for authentication state

### Problems (`features/problems`)
- **Home Screen**: Problem feed with filters, daily challenge, streak badge
- **Cubits**: `ProblemFeedCubit` (list), `ProblemDetailCubit` (detail)
- **Data Sources**: LeetCode GraphQL for remote, Hive for local caching
- **Models**: Problem, ProblemListItem, DailyChallenge, CodeSnippet, TopicTag

### Editor (`features/editor`)
- Full-screen code editor with syntax highlighting
- Language selector, test case runner
- `JudgeRemoteDataSource` for code submission/execution

### Profile (`features/profile`)
- User stats, streaks, achievements
- Activity calendar, recent submissions
- Syncs with LeetCode via GraphQL

### Explore (`features/explore`)
- Topic-based learning paths (Arrays, Trees, DP, etc.)
- Filtered problem lists per topic

### Search (`features/search`)
- Real-time problem search with debouncing
- Recent searches, difficulty-grouped results

### Solutions (`features/solutions`)
- Community solutions & discussions
- Cached locally via Hive

## Important Development Notes

### Working with Cubits
1. Define sealed states (Loading, Loaded, Error, Empty)
2. Create Cubit methods that emit new states
3. Handle failures from repositories gracefully
4. Always include error state with message for debugging

Example pattern:
```dart
class ProblemFeedCubit extends Cubit<ProblemFeedState> {
  ProblemFeedCubit(this._problemsRepository) : super(ProblemFeedLoading());

  Future<void> fetchProblems() async {
    emit(ProblemFeedLoading());
    final result = await _problemsRepository.getProblems(...);
    result.fold(
      (failure) => emit(ProblemFeedError(failure.message)),
      (problems) => emit(ProblemFeedLoaded(problems)),
    );
  }
}
```

### Adding New API Queries
1. Add GraphQL query to `lib/core/constants/api_constants.dart`
2. Add to `ProblemsRemoteDataSource` (or appropriate data source)
3. Map response to model in `lib/features/{feature}/data/models/`
4. Create repository method in domain layer
5. Use in Cubit/screen via BlocBuilder/BlocListener

### Working with Hive
```dart
// Getting a box
final box = Hive.box<Map>('problems');

// Storing data
box.put('problem_slug', problemData);

// Retrieving data
final data = box.get('problem_slug');

// Clearing
box.clear();
```

### Navigation Examples
```dart
// Push new screen (problem detail)
context.push('/problem/$problemSlug');

// Navigate to editor from detail
context.push('/problem/$problemSlug/editor');

// Bottom nav switching (home, explore, search, profile)
navigationShell.goBranch(index);

// Named route (onboarding)
context.push('/onboarding');
```

### Responsive Design & Constraints
- Use `LayoutBuilder` for responsive layouts
- Minimum tap targets: 48×48dp (follow Material guidelines)
- Primary CTAs should be full-width or large
- One-handed usage: primary actions in bottom 40% of screen

## Frequently Needed Files

| Task | File |
|------|------|
| Add new colors/theme | `lib/core/theme/app_colors.dart` |
| Adjust spacing/layout | `lib/core/theme/app_spacing.dart` |
| Change fonts/text styles | `lib/core/theme/app_typography.dart` |
| Add routes/navigation | `lib/router/app_router.dart` |
| Register new services/repos | `lib/injection.dart` |
| Add API queries | `lib/core/constants/api_constants.dart` |
| Global error handling | `lib/core/errors/failures.dart` |
| Common widgets | `lib/shared/` |

## Testing Strategy

- Unit test Cubits and repositories
- Widget tests for reusable components in `lib/shared/`
- Integration tests for critical user flows (auth, problem submission)
- Mock data sources using `Mockito` or similar
- See `flutter test --help` for testing options

## Key Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_bloc` | State management (Cubit) |
| `go_router` | Navigation with deep linking |
| `get_it` | Service locator / DI |
| `dio` | HTTP client with interceptors |
| `hive_flutter` | Local storage (offline caching) |
| `flutter_secure_storage` | Secure credential storage |
| `flutter_widget_from_html_core` | Render LeetCode problem HTML |
| `shimmer` | Skeleton loading states |
| `lottie` | Micro-animations & empty states |
| `fl_chart` | Charts & progress rings |
| `google_fonts` | Inter & JetBrains Mono |
| `flutter_animate` | Advanced animations |
| `gap` | Spacing widget utility |
| `flutter_code_editor` | Code syntax highlighting |

## Performance Tips

- Use `const` constructors everywhere possible
- Lazy-load screens via `go_router` branches
- Cache network responses locally with Hive
- Use `BlocBuilder` selectively (only rebuild what changes)
- Implement pagination for long lists (problem feed uses `currentPage`)
- Use `RepaintBoundary` for expensive custom paint operations

## Debugging & Common Issues

**App won't run?**
- Run `flutter clean` then `flutter pub get`
- Ensure `initDependencies()` is called in `main()`

**Generated files missing?**
- Run `flutter pub run build_runner build --delete-conflicting-outputs`
- Check that models have required annotations

**State not updating?**
- Ensure Cubit emits new state instances (not mutations)
- Check that BlocListener/BlocBuilder is listening to correct Cubit
- Verify Cubit is provided via `BlocProvider` higher in widget tree

**Hive box access errors?**
- Ensure box is opened in `initDependencies()` before use
- Check box name matches registered name
- For type safety, boxes should be `Box<Map>` not `dynamic`

For more architectural details, design system specs, and UI/UX principles, refer to `STARTER.md`.
