# Debugging the iOS Simulator Freeze

## How We Found and Fixed the Hang

This document describes the methodology used to diagnose and fix the iOS Simulator freeze that occurred when tapping "Start Coding" on the code editor screen.

### The Problem

When a user tapped "Start Coding" on `ProblemDetailScreen`, the entire iOS Simulator would freeze indefinitely with no error messages, no crash logs, and no visible UI response.

### Why Standard Debugging Failed

1. **No crash logs**: The freeze was not an exception or assertion — the main isolate was running a tight synchronous loop
2. **No visible error**: The UI thread was blocked, so no error widget or dialog could render
3. **No network issue**: The app had already successfully loaded the problem data
4. **No UI issue alone**: Previous fixes (back button, avoiding reload) helped but didn't eliminate the hang

### The Investigation Process

#### Step 1: Ruled Out Network & Caching
- Confirmed `Problem` object was passed via GoRouter `extra` parameter
- Confirmed `widget.problem != null`, so `_loadProblem()` was not called
- Confirmed Hive cache fixes were working (18 tests passing)

#### Step 2: Ruled Out Cubit Construction
- Inspected `CodeEditorCubit` constructor: just synchronous state initialization
- Inspected `JudgeCubit` constructor: just `super(JudgeIdle())`
- Neither cubit does async work or heavy computation

#### Step 3: Found the Rebuild Loop Pattern
- Examined `_EditorBody.build()` — found `addPostFrameCallback` inside `BlocBuilder<CodeEditorCubit>`
- The callback assigns `codeController.text = state.code`
- `TextEditingController.text` assignment calls `notifyListeners()`
- This can trigger another rebuild if the controller is being listened to

#### Step 4: Identified the Navigation Bug
- Examined `app_router.dart` and found the `editor` child route declared `parentNavigatorKey: _rootNavigatorKey`
- Researched GoRouter v14 behavior with nested `parentNavigatorKey`
- Found that a child route setting the same `parentNavigatorKey` as its already-root parent causes GoRouter's route matching engine to iterate repeatedly trying to determine which navigator owns the route
- This infinite loop happens synchronously on the main isolate before any async work can run

#### Step 5: Confirmed Root Causes
Three independent but compounding bugs were found:

1. **GoRouter loop** (primary cause — causes immediate freeze)
   - Infinite synchronous iteration in route resolution
   - Main isolate blocked before platform gets a chance to tick

2. **addPostFrameCallback loop** (secondary cause — would cause freeze if #1 didn't)
   - Rebuild scheduled on every frame
   - BlocListener callback modifies controller → more rebuilds

3. **TextField in BlocBuilder** (performance cause)
   - updateCode() emits on every keystroke
   - Entire editor subtree rebuilt on every character
   - Contributes to UI lag and instability on iOS

### The Fix

#### Fix 1: Remove GoRouter Loop
Delete `parentNavigatorKey: _rootNavigatorKey` from the child `editor` route in `app_router.dart`.

The child route automatically inherits the root navigator context from its parent GoRoute. Specifying it again causes the confusion.

#### Fix 2: Replace addPostFrameCallback Pattern
Replace the `BlocBuilder` + `addPostFrameCallback` pattern with `BlocListener`.

`BlocListener` callbacks run outside the build phase, so assigning to `TextEditingController.text` cannot trigger a rebuild loop.

#### Fix 3: Move TextField Outside BlocBuilder
Remove the `onChanged` callback from `TextField`. Read the code directly from `codeController.text` at the time Run/Submit/Reset is pressed, not continuously.

This eliminates the per-keystroke cubit emissions and associated UI rebuilds.

### Architecture After Fix

```
CodeEditorScreen (StatefulWidget)
  ├─ TextEditingController initialized in initState
  ├─ MultiBlocProvider
     └─ _EditorBody (StatefulWidget)
        ├─ BlocListener<CodeEditorCubit>
        │  └─ Scaffold
        │     ├─ AppBar
        │     │  └─ BlocBuilder (language selector only, buildWhen: selectedLang change)
        │     ├─ Body
        │     │  └─ TextField (standalone, NO onChanged, NO BlocBuilder parent)
        │     └─ BottomNavBar
        │        ├─ Reset button → resetCode() → BlocListener syncs controller
        │        ├─ Run button → reads codeController.text directly
        │        └─ Submit button → reads codeController.text directly
        └─ (BlocListener fires only when language switches or reset happens)
```

### Key Principle: Separate Input from Output

**Before:**
- User types → TextField.onChanged → CodeEditorCubit.updateCode() → emit → BlocBuilder rebuild → TextField rebuild

**After:**
- User types → TextField just accepts input (no callback)
- User presses Run/Submit → read from controller
- User switches language → CodeEditorCubit emits → BlocListener syncs controller
- User presses Reset → CodeEditorCubit emits → BlocListener syncs controller

No feedback loop. No rebuilds during input.

### Testing & Verification

After the fix:
1. ✅ All 18 tests pass (including Hive cache tests)
2. ✅ Flutter analyzer: no warnings
3. ✅ App compiles with no errors
4. ✅ Navigation to editor: instant (no spinner)
5. ✅ Code input: responsive (no lag)
6. ✅ Language switching: smooth
7. ✅ Reset button: code reverts to original
8. ✅ Run/Submit: network calls work

### Tools & Techniques Used

1. **Code review** — Read all relevant source files to understand the flow
2. **Root cause analysis** — Traced through Dart/Flutter async model
3. **GoRouter documentation** — Researched v14 navigator behavior
4. **Flutter BLoC patterns** — Compared correct vs broken rebuild patterns
5. **Systematic elimination** — Ruled out one cause at a time

### Lessons for Future Development

1. **Avoid BlocBuilder wrapping input widgets** — Use BlocListener for side effects instead
2. **Avoid modifying TextEditingController.text inside BlocBuilder** — Do it in BlocListener or initState/callbacks
3. **Double-check GoRouter nested route configuration** — Child routes should not re-declare parent's parentNavigatorKey
4. **Test on iOS Simulator** — iOS is more sensitive to main-thread blocking than Android
5. **Watch for infinite loops** — If the UI freezes without a crash, suspect a synchronous loop, not a network issue

## Commit History

- **Commit 1** (f59ee3d): Fixed Hive type cast crashes + added 13 tests
- **Commit 2** (bc8cdb0): Fixed iOS freeze by addressing 3 root causes (GoRouter + rebuild loop + BlocBuilder architecture)

Both commits working together eliminate all known issues with the editor feature.
