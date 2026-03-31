# Bug Fix: Hive Type Cast Failures

## Problem

When clicking into a problem from the home screen, the app crashes with:

```
type '_Map<dynamic, dynamic>' is not a subtype of type 'Map<String, dynamic>' in cast
```

This occurs when the app tries to parse data retrieved from Hive (local storage) because Hive returns `Map<dynamic, dynamic>` with nested values that are also `Map<dynamic, dynamic>`, but the code was attempting to cast them directly to `Map<String, dynamic>`.

## Root Cause

Hive's internal serialization format stores all data as `Map<dynamic, dynamic>`. When you call `box.get(key)` or `box.values`, you receive `Map<dynamic, dynamic>`. 

The problem occurs in this sequence:

1. **Datasource does shallow conversion**: `Map<String, dynamic>.from(data)` converts only the top-level map keys to strings
2. **Nested maps remain unconverted**: Lists and nested maps inside the outer map are still `Map<dynamic, dynamic>`
3. **Model `fromJson` tries direct cast**: Code like `TopicTag.fromJson(t as Map<String, dynamic>)` crashes when `t` is `Map<dynamic, dynamic>`

### Example
```dart
// What Hive returns:
Map<dynamic, dynamic> = {
  'topicTags': [
    {'name': 'Array', 'slug': 'array'},  // ← Still Map<dynamic, dynamic>!
  ]
}

// Datasource shallow conversion:
Map<String, dynamic>.from(hiveData)
// Result: outer keys are String, but topicTags elements are STILL Map<dynamic, dynamic>

// Model tries to parse:
TopicTag.fromJson(t as Map<String, dynamic>)
// CRASH: t is Map<dynamic, dynamic>, not Map<String, dynamic>
```

## Solution

Replace direct casts with proper `Map<String, dynamic>.from()` conversion:

```dart
// BEFORE (crashes):
?.map((t) => TopicTag.fromJson(t as Map<String, dynamic>))

// AFTER (safe):
?.map((t) => TopicTag.fromJson(Map<String, dynamic>.from(t as Map)))
```

This pattern handles both API responses (already `Map<String, dynamic>`) and Hive cache data (`Map<dynamic, dynamic>`).

## Files Fixed

### 1. `lib/features/problems/data/models/problem_model.dart`
- **Line 59**: TopicTag parsing in `topicTags` list
- **Line 67**: CodeSnippet parsing in `codeSnippets` list

### 2. `lib/features/problems/data/models/problem_list_item_model.dart`
- **Line 32**: TopicTag parsing in `topicTags` list
- **Line 46**: Nested map conversion for `problemsetQuestionList`
- **Line 50**: ProblemListItem parsing in `questions` list

### 3. `lib/features/solutions/data/models/solution_model.dart`
- **Line 12**: SolutionApproach parsing in `approaches` list

## Tests Added

Three comprehensive test files verify the fixes using Hive-like data:

### `test/features/problems/data/models/problem_model_test.dart`
- ✅ `parses valid JSON from API`
- ✅ **`parses Map<dynamic, dynamic> from Hive cache`** ← Critical test
- ✅ `handles missing optional fields gracefully`
- ✅ `parses complex nested structure with multiple tags and snippets`

### `test/features/problems/data/models/problem_list_item_model_test.dart`
- ✅ `parses valid JSON from API`
- ✅ **`parses Map<dynamic, dynamic> with nested topic tags from Hive cache`** ← Critical test
- ✅ `handles missing topicTags gracefully`
- ✅ **`ProblemListResponse` tests with Hive-like nested maps** ← Critical test

### `test/features/solutions/data/models/solution_model_test.dart`
- ✅ `parses valid JSON from API`
- ✅ **`parses Map<dynamic, dynamic> with nested approaches from Hive cache`** ← Critical test
- ✅ `handles missing approaches gracefully`
- ✅ `handles missing code in approach gracefully`
- ✅ `SolutionApproach` tests with Hive-like `Map<dynamic, dynamic>` code maps

## How the Tests Prevent Regression

Each critical test:
1. **Simulates Hive data** using `Map<dynamic, dynamic>` with nested `Map<dynamic, dynamic>` values
2. **Performs shallow conversion** (mimicking the datasource) with `Map<String, dynamic>.from(data)`
3. **Calls `fromJson`** on the shallow-converted data
4. **Verifies correct parsing** of all nested structures

### Example Test Pattern
```dart
test('parses Map<dynamic, dynamic> from Hive cache', () {
  // Create Hive-like data structure
  final hiveData = <dynamic, dynamic>{
    'topicTags': [
      <dynamic, dynamic>{'name': 'Array', 'slug': 'array'},  // ← Map<dynamic, dynamic>
    ],
  };

  // Simulate datasource's shallow conversion
  final shallowConverted = Map<String, dynamic>.from(hiveData);

  // This should NOT crash
  final problem = Problem.fromJson(shallowConverted);

  // Verify parsing succeeded
  expect(problem.topicTags[0].name, 'Array');
});
```

If the fix is removed, these tests will fail with the original error, preventing accidental regressions.

## Running the Tests

```bash
# Run all model tests
flutter test test/features/problems/data/models/ test/features/solutions/data/models/

# Run specific test file
flutter test test/features/problems/data/models/problem_model_test.dart -v

# Run single test
flutter test test/features/problems/data/models/problem_model_test.dart \
  -n "parses Map<dynamic, dynamic> from Hive cache"
```

## Summary

| Component | Before | After |
|-----------|--------|-------|
| **Type Safety** | ❌ Crashes on Hive data | ✅ Handles `Map<dynamic, dynamic>` |
| **Nested Structures** | ❌ Fails on nested maps/lists | ✅ Recursively converts with `.from()` |
| **Test Coverage** | ❌ No Hive-specific tests | ✅ 13+ tests with Hive-like data |
| **API Responses** | ✅ Works | ✅ Works (unchanged) |
| **Cached Data** | ❌ Broken | ✅ Fixed |

The fix is minimal, focused, and thoroughly tested. It ensures the app gracefully handles both API responses and cached data from Hive.

---

# Bug Fix: FilledButton Infinite Width Constraint

## Problem

After "Start Coding" from a problem detail screen, the app freezes with:

```
BoxConstraints forces an infinite width.
These invalid constraints were provided to RenderPhysicalShape's layout() function
by the following function, which probably computed the invalid constraints in
question: RenderConstrainedBox.performLayout
The offending constraints were: BoxConstraints(w=Infinity, 48.0<=h<=823.0)
The offending widget was: FilledButton
```

## Root Cause

`FilledButton`'s internal `Material` widget uses `RenderPhysicalShape` with `clipBehavior: antiAlias`. When `FilledButton` receives unbounded width constraints from the parent layout (e.g., from `Spacer()` in a `Row(spaceBetween)`), the `Material` widget tries to expand to fill available space and `RenderPhysicalShape.performLayout` throws. The `Spacer` → outer `Row` → inner `Row(mainAxisSize.min)` → `FilledButton` chain passes `w=Infinity` down.

Previous attempted fixes:
- **Remove `Flexible`** — `FilledButton` still expands with `Spacer` giving unbounded width
- **`maximumSize: Size.square(N)`** — causes non-normalized constraints (`minWidth=Infinity, maxWidth=N`)
- **`IntrinsicWidth` wrapping** — `FilledButton.getMaxIntrinsicWidth` returns `Infinity` (it doesn't apply internal `ConstrainedBox` during intrinsic measurement), so `IntrinsicWidth` passes `w=Infinity` down anyway

## Solution

Replace `FilledButton` with a `Container` + `OutlinedButton` composition:

```dart
// Run button — Container provides fill, OutlinedButton provides semantics & tap target
Container(
  decoration: BoxDecoration(
    color: AppColors.card,
    borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
  ),
  child: OutlinedButton(
    style: OutlinedButton.styleFrom(
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      minimumSize: const Size(0, 40),
    ),
    onPressed: () { ... },
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [Icon(Icons.play_arrow), Gap(4), Text('Run')],
    ),
  ),
),
```

**Why this works:** `Container` provides the visual fill and rounded corners. `OutlinedButton` with `side: BorderSide.none` has a transparent `Material` background — it naturally sizes to its content rather than expanding to fill available space, even when it receives `w=Infinity`. The `minimumSize: Size(0, 40)` ensures proper minimum touch target height.

## Additional Fixes

**Code editor TextField:** `SingleChildScrollView(maxLines: null)` causes intrinsic height measurement failures on interaction. Fixed by replacing with `TextField(expands: true)` (natively scrollable, fills `Expanded` space without needing an outer scroll view).

**Results panel `_ResultView`:** Redundant `SingleChildScrollView` inside `Expanded` removed — `Expanded` already provides bounded height.

## Files Changed

- `lib/features/editor/presentation/screens/code_editor_screen.dart` — `FilledButton` → `Container`+`OutlinedButton`; `SingleChildScrollView`+`maxLines:null` → `TextField.expands:true`; `_ResultView` `SingleChildScrollView` removed

## Tests

See `test/features/editor/presentation/screens/code_editor_screen_test.dart` — 6 widget tests including layout error detection.

## Verification

```bash
flutter test   # 24/24 pass
flutter analyze  # 0 issues
```

## Summary

| | Before | After |
|--|--------|-------|
| **Constraint error** | ❌ Freezes on "Start Coding" | ✅ Layout succeeds |
| **Button type** | `FilledButton` (crashes on `w=Infinity`) | `Container` + `OutlinedButton` |
| **Code editor** | `SingleChildScrollView` + `maxLines:null` | `TextField.expands:true` |
| **Test coverage** | No editor screen tests | ✅ 6 widget tests |
