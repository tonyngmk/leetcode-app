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
