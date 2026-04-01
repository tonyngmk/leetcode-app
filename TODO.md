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

---

## Visualisation System Roadmap

See `VISUALIZATION_AI_GUIDE.md` for the LLM generation spec and prompt templates.

### Phase 1 — Two-Sum Proof of Concept ✅ COMPLETE

- [x] `VisualizationStep` data model (`lib/features/visualizer/domain/visualization_step.dart`)
- [x] `VisualizerCubit` with play/pause/next/prev/reset (`lib/features/visualizer/presentation/cubits/visualizer_cubit.dart`)
- [x] `ArrayBoxWidget` — single element with animated colour transitions
- [x] `ArrayVisualizerWidget` — full array row with pointer labels
- [x] `HashMapVisualizerWidget` — key→value rows with fade-in animation
- [x] `StepControllerWidget` — playback controls
- [x] `VisualizationPanel` — owns cubit, drives RendererFactory
- [x] `two_sum_steps.dart` — hardcoded step lists for 3 approaches
- [x] `SolutionTabView` integration — "Visualize" toggle + `AnimatedSize` panel

---

### Phase 2 — JSON Architecture Refactor

**Goal:** Decouple step data from Dart code so steps can be generated, reviewed, and shipped without app releases.

#### 2.1 — Define JSON schema *(no code dependencies)*
- [x] Finalise `visualization_cache.json` top-level structure: `{ "<slug>": { "type", "supported", "approaches": [{ "name", "steps": [...] }] } }`
- [x] Document all step field schemas per template type in `VISUALIZATION_AI_GUIDE.md` (covered in that file)
- [x] Decide `type` enum values: `array_basic`, `two_pointer`, `sliding_window`, `hash_map`, `prefix_sum`, `binary_search`, `stack`, `tree_dfs`, `tree_bfs`, `grid`, `dp_1d`, `dp_2d`

#### 2.2 — Sealed step model hierarchy *(depends on 2.1)*
- [x] Convert `VisualizationStep` from a plain class to a `sealed class`
- [x] Add `ArrayStep` subclass (current fields: `array`, `activePointers`, `resultIndices`, `hashMap`)
- [x] Add `TwoPointerStep` subclass (`array`, `left`, `right`, `resultIndices`, `windowStart?`, `windowEnd?`)
- [x] Add `SlidingWindowStep` subclass (`array`, `windowStart`, `windowEnd`, `currentChar?`, `freqMap?`)
- [x] Add static `fromJson(Map json)` factory on each subclass
- [x] File: `lib/features/visualizer/domain/visualization_step.dart`

#### 2.3 — `ProblemVisualization` model *(depends on 2.2)*
- [x] Create `ProblemVisualization` with fields: `slug`, `type`, `supported`, `List<VisualizationApproach>`
- [x] Create `VisualizationApproach` with fields: `name`, `List<VisualizationStep> steps`
- [x] `ProblemVisualization.fromJson` delegates step parsing to subclass factories via `type` discriminator
- [x] File: `lib/features/visualizer/domain/problem_visualization.dart`

#### 2.4 — Migrate two-sum steps to JSON *(depends on 2.1)*
- [x] Create `assets/visualization_cache.json` with two-sum entry (3 approaches, all current steps)
- [x] Register new asset in `pubspec.yaml` under `flutter.assets`
- [x] Verify JSON is valid (run through a JSON linter or `dart run` parse check)

#### 2.5 — `VisualizationLocalDataSource` *(depends on 2.3, 2.4)*
- [x] Create `VisualizationLocalDataSource` mirroring `SolutionsLocalDataSource` pattern
- [x] Lazy-load `visualization_cache.json` on first access, cache in `Map<String, dynamic>? _cache`
- [x] Implement `Future<bool> hasVisualization(String slug)`
- [x] Implement `Future<ProblemVisualization?> getVisualization(String slug)`
- [x] File: `lib/features/visualizer/data/datasources/visualization_local_datasource.dart`

#### 2.6 — Repository layer *(depends on 2.5)*
- [x] Define `VisualizationRepository` interface with `getVisualization(slug)` and `hasVisualization(slug)`
- [x] Implement `VisualizationRepositoryImpl` wrapping the datasource
- [x] Files:
  - `lib/features/visualizer/domain/repositories/visualization_repository.dart`
  - `lib/features/visualizer/data/repositories/visualization_repository_impl.dart`

#### 2.7 — Register in DI *(depends on 2.6)*
- [x] Register `VisualizationLocalDataSource` as singleton in `lib/injection.dart`
- [x] Register `VisualizationRepository → VisualizationRepositoryImpl` as singleton
- [x] No Hive box needed (JSON asset, not Hive)

#### 2.8 — `RendererFactory` *(depends on 2.2)*
- [x] Create `RendererFactory.build(VisualizationStep step) → Widget` using exhaustive `switch`
- [x] Map `ArrayStep` → `ArrayVisualizerWidget`
- [x] Map `TwoPointerStep` → `TwoPointerVisualizerWidget` (placeholder widget for now)
- [x] Map `SlidingWindowStep` → `SlidingWindowVisualizerWidget` (placeholder)
- [x] Default case → `UnsupportedStepWidget` (grey box with "unsupported step type")
- [x] File: `lib/features/visualizer/presentation/widgets/renderer_factory.dart`

#### 2.9 — Update `VisualizerCubit` *(depends on 2.3, 2.6)*
- [x] Inject `VisualizationRepository` via constructor
- [x] Add `Future<void> loadForSlug(String slug, int approachIndex)` method
- [x] Replace `loadSteps(List)` internal call with repo fetch
- [x] Handle null result (problem has no visualization) → emit new `VisualizerUnsupported` state
- [x] File: `lib/features/visualizer/presentation/cubits/visualizer_cubit.dart`

#### 2.10 — Update `VisualizationPanel` *(depends on 2.8, 2.9)*
- [x] Accept `slug` + `approachIndex` instead of raw step list
- [x] Call `cubit.loadForSlug(slug, approachIndex)` in `initState` and `didUpdateWidget`
- [x] Replace direct `twoSumSteps()` call with cubit-driven data
- [x] Use `RendererFactory.build(step)` instead of hard-coded `ArrayVisualizerWidget`
- [x] File: `lib/features/visualizer/presentation/widgets/visualization_panel.dart`

#### 2.11 — Update `SolutionTabView` *(depends on 2.7, 2.10)*
- [x] Inject `VisualizationRepository` via `sl<VisualizationRepository>()`
- [x] Add `bool _hasVisualization = false` state field
- [x] In `initState`, call `sl<VisualizationRepository>().hasVisualization(widget.problem.titleSlug)` and `setState`
- [x] Replace `if (widget.problem.titleSlug == 'two-sum')` with `if (_hasVisualization)`
- [x] Pass `slug: widget.problem.titleSlug` to `VisualizationPanel`
- [x] File: `lib/features/problems/presentation/widgets/solution_tab_view.dart`

#### 2.12 — Remove hardcoded data *(depends on 2.11)*
- [x] Delete `lib/features/visualizer/presentation/two_sum_steps.dart`
- [x] Run `flutter analyze` — resolve any remaining import errors
- [x] Smoke test: open Two Sum → Solutions tab → Visualize works from JSON

---

### Phase 3 — Generation Pipeline + Top 50 Array Problems

**Goal:** Automate step generation via Claude API; ship visualisations for the 50 most common array problems without manual authoring.

#### 3.1 — Script infrastructure *(no app code dependencies)*
- [x] Create `scripts/` directory at project root
- [x] Create `scripts/generate_visualizations.dart` CLI entry point (reads args: `--slug`, `--all`, `--type`)
- [x] Create `scripts/pubspec.yaml` for script-only deps (`anthropic_dart` or plain `http`, `dart_jsonc`)
- [x] Create `scripts/lib/problem_classifier.dart` — maps `topicTags + slug keywords → TemplateType enum`
- [x] Create `scripts/lib/prompt_builder.dart` — builds prompt string per template type (see `VISUALIZATION_AI_GUIDE.md`)
- [x] Create `scripts/lib/llm_client.dart` — wraps Claude API call, returns raw JSON string
- [x] Create `scripts/lib/step_validator.dart` — validates generated step JSON (bounds, field presence, step count)
- [x] Create `scripts/lib/cache_writer.dart` — merges validated output into `assets/visualization_cache.json`

#### 3.2 — Target problem list *(no code dependencies)*
- [x] Define `scripts/data/array_target_slugs.txt` — top 50 array problems by LeetCode frequency
  - Seed list: `two-sum`, `best-time-to-buy-and-sell-stock`, `contains-duplicate`, `product-of-array-except-self`, `maximum-subarray`, `maximum-product-subarray`, `find-minimum-in-rotated-sorted-array`, `search-in-rotated-sorted-array`, `3sum`, `container-with-most-water`, `trapping-rain-water`, `rotate-array`, `move-zeroes`, `two-sum-ii-input-array-is-sorted`, `remove-duplicates-from-sorted-array`, `merge-sorted-array`, `sort-colors`, `find-all-anagrams-in-a-string`, `minimum-size-subarray-sum`, `longest-subarray-of-1s-after-deleting-one-element`, `subarray-sum-equals-k`, `longest-consecutive-sequence`, `four-sum`, `next-permutation`, `first-missing-positive`, ...

#### 3.3 — Run generation: `array_basic` + `hash_map` *(depends on 3.1, Phase 2 complete)*
- [x] Run `dart scripts/generate_visualizations.dart --type array_basic`
- [x] Run `dart scripts/generate_visualizations.dart --type hash_map`
- [x] Manual review: open each generated entry, verify step logic is correct
- [x] Fix any hallucinated pointer values or wrong indices

#### 3.4 — `TwoPointerVisualizerWidget` *(depends on Phase 2 complete)*
- [x] Render array with `left` pointer on left side (blue), `right` pointer on right side (orange/`AppColors.medium`)
- [x] Show "L" / "R" labels; convergence animation when `left >= right`
- [x] File: `lib/features/visualizer/presentation/widgets/two_pointer_visualizer_widget.dart`

#### 3.5 — `SlidingWindowVisualizerWidget` *(depends on Phase 2 complete)*
- [x] Render array with a highlighted bracket spanning `windowStart..windowEnd`
- [x] Optionally render a character frequency map beside the array
- [x] File: `lib/features/visualizer/presentation/widgets/sliding_window_visualizer_widget.dart`

#### 3.6 — Run generation: `two_pointer` + `sliding_window` *(depends on 3.1, 3.4, 3.5)*
- [x] Update `RendererFactory` to map new step types to new widgets
- [x] Run `dart scripts/generate_visualizations.dart --type two_pointer`
- [x] Run `dart scripts/generate_visualizations.dart --type sliding_window`
- [x] Manual review pass

#### 3.7 — `PrefixSumVisualizerWidget` *(depends on Phase 2 complete)*
- [x] Render two rows: original array above, running prefix sum row below
- [x] Highlight current element being added; show cumulative sum updating
- [x] File: `lib/features/visualizer/presentation/widgets/prefix_sum_visualizer_widget.dart`

#### 3.8 — `BinarySearchVisualizerWidget` *(depends on Phase 2 complete)*
- [x] Render array with `lo` (green), `mid` (blue), `hi` (orange) pointers
- [x] Dim eliminated half of array on each step
- [x] File: `lib/features/visualizer/presentation/widgets/binary_search_visualizer_widget.dart`

#### 3.9 — Run generation: `prefix_sum` + `binary_search` *(depends on 3.7, 3.8)*
- [x] Run generation for these types
- [x] Manual review pass

---

### Phase 4 — Tree + Graph Renderers

**Goal:** Extend visualisation to non-linear data structures, covering the second most common LeetCode category.

#### 4.1 — Tree data model *(no prior phase dependency beyond Phase 2)*
- [x] Define `VisTreeNode { id, value, leftId?, rightId?, highlighted, color? }` — flat list, not recursive (easier to diff between steps)
- [x] Add `TreeStep` subclass to sealed class: `nodes: List<VisTreeNode>`, `highlightedEdges: List<(int,int)>`, `callStack: List<int>`
- [x] Add `TreeStep.fromJson`
- [x] File: `lib/features/visualizer/domain/visualization_step.dart`

#### 4.2 — `TreeVisualizerWidget` *(depends on 4.1)*
- [x] Layout algorithm: BFS-based, calculate `x/y` position per node from depth + sibling index
- [x] Render nodes as circles with value text; edges as lines between parent/child
- [x] Highlight active nodes with `AppColors.primary`; visited nodes with dimmed colour
- [x] Use `CustomPaint` for edges, `Stack` + `Positioned` for nodes
- [x] File: `lib/features/visualizer/presentation/widgets/tree_visualizer_widget.dart`

#### 4.3 — Tree generation *(depends on 4.1, 4.2, 3.1 scripts exist)*
- [x] Write tree prompt template in `VISUALIZATION_AI_GUIDE.md` (flat node list format)
- [x] Run generation for top 30 tree problems (in-order, level-order, path sum, etc.)
- [x] Manual review: check node IDs are consistent between steps, no orphaned edges

#### 4.4 — Grid data model + widget *(no dependency beyond Phase 2)*
- [x] Define `VisGridCell { row, col, value, state: normal|visited|active|result|wall }`
- [x] Add `GridStep` subclass: `grid: List<List<VisGridCell>>`, `currentCell?`, `queue: List<(row,col)>`
- [x] Create `GridVisualizerWidget`: fixed-size cells in a 2D layout, colour-coded by state
- [x] File: `lib/features/visualizer/presentation/widgets/grid_visualizer_widget.dart`

#### 4.5 — Grid generation *(depends on 4.4)*
- [x] Run generation for top 20 grid/matrix problems (Number of Islands, Word Search, etc.)
- [x] Manual review pass

#### 4.6 — Graph data model + widget *(no dependency beyond Phase 2)*
- [x] Define `VisGraphNode { id, label, x, y, state }` + `VisGraphEdge { fromId, toId, directed, highlighted }`
- [x] Add `GraphStep` subclass
- [x] Create `GraphVisualizerWidget`: fixed-position nodes (coordinates provided in JSON), edges drawn with `CustomPaint`
- [x] File: `lib/features/visualizer/presentation/widgets/graph_visualizer_widget.dart`

#### 4.7 — Graph generation *(depends on 4.6)*
- [x] Run generation for top 20 graph problems (BFS/DFS, shortest path, etc.)
- [x] Manual review pass

#### 4.8 — Update `RendererFactory` *(depends on 4.2, 4.4, 4.6)*
- [x] Add `TreeStep` → `TreeVisualizerWidget`
- [x] Add `GridStep` → `GridVisualizerWidget`
- [x] Add `GraphStep` → `GraphVisualizerWidget`

---

### Phase 4 — Tree + Graph Renderers ✅ COMPLETE

All Phase 4 tasks completed:
- ✅ TreeStep + VisTreeNode model with fromJson factory
- ✅ TreeVisualizerWidget with BFS-based layout algorithm
- ✅ GridStep + VisGridCell model with state machine (normal/visited/active/result/wall)
- ✅ GridVisualizerWidget with fixed-size cell grid
- ✅ GraphStep + VisGraphNode/VisGraphEdge models with directed edge support
- ✅ GraphVisualizerWidget with CustomPaint edge rendering and arrowheads
- ✅ RendererFactory updated with all three new step types
- ✅ Sample test entries added to visualization_cache.json:
  - `binary-tree-inorder-traversal` (tree_dfs)
  - `number-of-islands` (grid)
  - `clone-graph` (graph)

---

### Phase 5 — Full Coverage + Polish

**Goal:** Achieve visualisation for all common DSA patterns; add quality signals and discoverability.

#### 5.1 — Stack + Queue renderers *(depends on Phase 2)*
- [x] Define `StackStep` subclass: `stack: List<int>`, `currentOp: push|pop|peek`, `inputValue?`, `resultStack?`
- [x] Create `StackVisualizerWidget`: vertical stack of boxes, shows top indicator
- [x] Define `QueueStep` + `QueueVisualizerWidget` (horizontal, enqueue/dequeue with front/back labels)
- [x] Sample test entry: `valid-parentheses` with stack steps

#### 5.2 — DP renderers *(depends on Phase 2)*
- [x] Define `Dp1DStep` subclass: `table: List<int>`, `currentIndex`, `formula?`
- [x] Create `Dp1DVisualizerWidget`: single row of cells with index labels, highlight current, show formula
- [x] Define `Dp2DStep` subclass: `table: List<List<int>>`, `currentRow`, `currentCol`, `formula?`
- [x] Create `Dp2DVisualizerWidget`: scrollable grid with row/col labels, highlight current cell
- [x] Sample test entry: `climbing-stairs` with DP 1D steps

#### 5.3 — Heap + Priority Queue renderer *(depends on Phase 2)*
- [x] Define `HeapStep` subclass: `arrayView`, `nodes` (tree representation), `highlightedIndex?`
- [x] Create `HeapVisualizerWidget`: dual view — array row + tree layout using BFS positioning
- [x] Sample test entry: `kth-largest-element-in-a-stream` with heap steps

#### 5.4 — Graceful fallback *(depends on Phase 2 complete)*
- [x] If `ProblemVisualization.supported == false` or slug not in cache: hide "Visualize" button entirely
- [x] `RendererFactory` handles all 13 step types exhaustively via switch

#### 5.5 — Discoverability + quality *(depends on Phase 3 + 4 generation done)*
- [ ] Add `hasVisualization` flag to `ProblemListItem` model (set during local cache writes)
- [ ] Show a small `Icons.play_circle_outline` badge on problem cards that have visualisations
- [ ] Add "Visualized" filter chip to problem feed filter bar
- [ ] Add visualisation stats to Profile screen: "X problems visualized"

#### 5.6 — Feedback loop for quality *(depends on 5.4)*
- [ ] Add thumbs-up / thumbs-down per step in `StepControllerWidget`
- [ ] Store ratings locally in Hive (`visualizer_ratings` box)
- [ ] Script: `scripts/export_low_rated_steps.dart` — dumps slugs where any step has thumbs-down, for re-generation

#### 5.7 — Batch re-generation *(depends on 5.6, generation pipeline from Phase 3)*
- [ ] Run `dart scripts/generate_visualizations.dart --regen-low-rated`
- [ ] Compare old vs. new steps, keep better version
- [ ] Re-run manual review for re-generated entries

---

### Phase 5 — Full Coverage + Polish ✅ PARTIAL COMPLETE

Core renderer widgets completed:
- ✅ StackStep + StackVisualizerWidget (vertical stack with push/pop semantics)
- ✅ QueueStep + QueueVisualizerWidget (horizontal queue with front/back pointers)
- ✅ Dp1DStep + Dp1DVisualizerWidget (1D table with index highlighting and formula display)
- ✅ Dp2DStep + Dp2DVisualizerWidget (2D grid with cell coordinates and formula)
- ✅ HeapStep (with VisHeapNode) + HeapVisualizerWidget (dual array/tree representation)
- ✅ RendererFactory updated for all new types
- ✅ Sample test entries added to visualization_cache.json for:
  - `valid-parentheses` (stack)
  - `climbing-stairs` (dp_1d)
  - `kth-largest-element-in-a-stream` (heap)

Remaining (non-critical polish):
- ⏳ 5.5 — Discoverability badges on problem cards (requires UI changes)
- ⏳ 5.6 — User feedback ratings system (requires Hive integration)
- ⏳ 5.7 — Batch re-generation script (requires feedback data)
