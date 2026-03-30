You are an expert Flutter/Dart developer and mobile UI/UX designer. Your task is to produce a complete, 
detailed plan and starter code scaffold for a LeetCode-inspired coding challenge mobile app built in 
Flutter/Dart. The app should have a premium, modern aesthetic and follow all established mobile UI/UX 
principles used by top-tier apps (Duolingo, Linear, Notion, GitHub Mobile, etc.).

---

## 🎯 App Overview
- App Name: [YOUR APP NAME, e.g., "AlgoFlow"]
- Platform: iOS + Android (Flutter cross-platform)
- Theme: Dark mode primary, light mode supported
- Inspiration: LeetCode's problem-solving flow, but with a more polished, gamified, and mobile-native feel
- Target Users: Software engineers practicing DSA / interview prep

---

## 🏗️ Architecture Requirements

Use Clean Architecture with the following layers:
1. **Presentation Layer** – Widgets, Screens, BLoC/Cubit for state management
2. **Domain Layer** – Use Cases, Entities, Repository Interfaces
3. **Data Layer** – Repository Implementations, Remote/Local Data Sources

State Management: flutter_bloc (Cubit preferred for simplicity)
Navigation: go_router with named routes and deep linking support
Dependency Injection: get_it + injectable
Local Storage: Hive or Isar for offline problem caching
Network: Dio with interceptors (auth token, error handling, retry logic)
Code Editor Widget: Use flutter_code_editor or a custom monospace widget

Folder structure:
lib/
├── core/           # theme, constants, errors, extensions, utils
├── features/
│   ├── auth/
│   ├── problems/   # problem list, filters, difficulty tags
│   ├── editor/     # code editor screen
│   ├── profile/    # user stats, streak, badges
│   └── explore/    # topic-based learning paths
├── shared/         # reusable widgets, design system components
└── main.dart

---

## 🎨 Design System (Implement as AppTheme)

### Color Palette (Dark Mode Base)
- Background:     #0D1117  (deep dark, GitHub-style)
- Surface:        #161B22
- Card:           #21262D
- Primary:        #58A6FF  (electric blue accent)
- Success/Easy:   #3FB950  (green)
- Warning/Medium: #D29922  (amber)
- Error/Hard:     #F85149  (red)
- Text Primary:   #E6EDF3
- Text Secondary: #8B949E
- Divider:        #30363D

### Typography
- Font: Inter (primary), JetBrains Mono (code blocks)
- Scale: Display (32sp), Headline (24sp), Title (18sp), Body (14sp), Caption (12sp), Code (13sp)
- Always use ThemeData text styles — never hardcode font sizes

### Spacing System (8pt grid)
- xs: 4, s: 8, m: 16, l: 24, xl: 32, xxl: 48

### Border Radius
- Small: 6px (chips, tags)
- Medium: 12px (cards)
- Large: 20px (bottom sheets, modals)

---

## 📱 Core Screens & UI/UX Spec

### 1. Splash / Onboarding Screen
- Animated logo with Lottie
- 3-step swipeable onboarding with PageView
- Progress dots indicator
- "Get Started" CTA with haptic feedback

### 2. Home / Problem Feed Screen
- Sticky header with greeting ("Good morning, [Name] 👋") + streak badge
- Daily Challenge card with gradient background and countdown timer
- Horizontal scrollable topic filter chips (All, Arrays, Trees, DP, Graphs…)
- Vertical problem list with:
  - Problem title + number
  - Difficulty badge (Easy/Medium/Hard) with color coding
  - Tags (e.g., "Array", "Hash Map")
  - Acceptance rate bar
  - Bookmark icon (toggle with animation)
  - Solved checkmark with green fill
- Pull-to-refresh with custom animation
- Skeleton loading shimmer while fetching (shimmer package)
- Floating Action Button for "Random Problem"

### 3. Problem Detail Screen
- Top: problem title, difficulty badge, stats row (Acceptance %, Submissions)
- Tabbed layout (go_router nested navigation):
  - 📄 Description tab – rich HTML/Markdown renderer (flutter_markdown)
  - 💡 Hints tab – progressive reveal with blur overlay
  - 💬 Discussion tab – community posts with upvotes
  - 📊 Solutions tab – top-voted editorial solutions
- Sticky "Start Coding" bottom CTA button with shimmer effect
- Hero animation from list card to detail screen

### 4. Code Editor Screen
- Full-screen immersive mode (hide system nav on Android)
- Language selector dropdown (Python, Java, C++, JavaScript, Go)
- Syntax-highlighted code editor (JetBrains Mono font, line numbers)
- Resizable split pane: editor (top) + console/test output (bottom)
  - Drag handle to resize panes
- Bottom action bar:
  - Run (▶) – sends to judge API, shows loading indicator
  - Submit (✓) – confirm dialog before submit
  - Reset code – with undo confirmation snackbar
- Test Cases panel:
  - Tab per test case
  - Expected vs. Actual output with color diff highlight
- Results overlay (slides up from bottom):
  - ✅ Accepted: confetti animation + stats (Runtime %, Memory %)
  - ❌ Wrong Answer: diff highlighting of failed case

### 5. Profile / Stats Screen
- Avatar + username + rank badge (top section with subtle gradient)
- Stats grid: Problems Solved, Streak 🔥, Submissions, Acceptance Rate
- Progress rings (Easy / Medium / Hard solved counts) using custom painter or fl_chart
- Calendar heatmap for activity (like GitHub contribution graph)
- Achievement badges row (horizontal scroll)
- Recent submissions list with status chips

### 6. Explore / Learning Paths Screen
- Card grid of topic modules (Arrays, Trees, Dynamic Programming…)
- Each card: topic icon, title, progress bar, completion %
- Tap → nested problem list for that topic

### 7. Search Screen
- Prominent search bar (autofocus on tab switch)
- Real-time filtering with debounce (300ms)
- Recent searches with dismiss chips
- Results categorized by difficulty with SliverList

---

## ✨ UI/UX Principles to Enforce (Reference These in Code Comments)

1. **Fitts's Law** – All tap targets ≥ 48×48dp; primary CTAs full-width or large
2. **Progressive Disclosure** – Hints revealed on demand; complexity hidden until needed
3. **Skeleton Screens** – Show shimmer skeletons during ALL async loads (never raw spinners alone)
4. **Haptic Feedback** – HapticFeedback.lightImpact() on all primary actions
5. **Optimistic UI** – Bookmarks/likes update instantly, rollback on error
6. **Micro-animations** – Lottie for empty states, AnimatedSwitcher for state transitions, Hero for screen transitions
7. **Error States** – Every screen must have: Loading, Error (with retry), Empty, and Populated states
8. **Accessibility** – All icons have Semantics labels; text scales with system font; contrast ratio ≥ 4.5:1
9. **One-handed Usage** – Primary actions in thumb reach zone (bottom 40% of screen)
10. **Consistent Motion** – Use Flutter's Curves.easeInOutCubic for all animations; duration 200–350ms

---

## 📦 Required Packages (pubspec.yaml)

dependencies:
  flutter_bloc: ^8.x          # state management
  go_router: ^14.x            # navigation
  get_it: ^7.x                # DI
  injectable: ^2.x            # DI code gen
  dio: ^5.x                   # HTTP client
  hive_flutter: ^1.x          # local storage
  flutter_markdown: ^0.x      # markdown rendering
  shimmer: ^3.x               # skeleton loading
  lottie: ^3.x                # animations
  fl_chart: ^0.x              # charts/graphs
  flutter_code_editor: ^0.x   # code editor
  google_fonts: ^6.x          # Inter + JetBrains Mono
  flutter_animate: ^4.x       # micro-animations
  cached_network_image: ^3.x  # image caching
  gap: ^3.x                   # spacing utility

dev_dependencies:
  injectable_generator: ^2.x
  build_runner: ^2.x
  flutter_lints: ^4.x

---

## 🔧 Implementation Instructions

For each screen above, provide:
1. Full widget tree with proper separation (Screen → Body → Components)
2. BLoC/Cubit class with all states (Loading, Loaded, Error, Empty)
3. Repository interface + mock implementation
4. Reusable component widgets extracted to /shared/widgets/
5. Proper use of const constructors wherever possible
6. No business logic inside build() methods
7. All colors/spacing from AppTheme — zero hardcoded values

Start with:
1. AppTheme (dark + light ThemeData)
2. AppRouter (go_router config)
3. DI setup (get_it)
4. Problem List screen (full implementation as reference)
5. Problem Detail screen
6. Code Editor screen

Generate clean, production-ready Flutter/Dart code with meaningful comments 
only where architectural decisions need clarification.
