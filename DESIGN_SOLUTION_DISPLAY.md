# Solution Display UI/UX Design

## Overview

This document specifies how community solutions from the local solution cache appear inside the Problem Detail screen's **Solutions tab**.

---

## 1. Where Solutions Live

The Solutions tab is already integrated as the third tab in `ProblemDetailScreen` (`SolutionTabView`). The design below extends the existing widget to add:

- **Spoiler protection** before any solution content is revealed
- **Multiple approach selector** (horizontal chip strip)
- **Language selector** (compact pill row)
- **Complexity badges** (time + space)
- **Copy-to-editor action** (send code to the Code Editor)

---

## 2. Color & Typography

| Element | Value |
|---|---|
| Background | `#0D1117` (AppColors.background) |
| Card/Surface | `#161B22` (AppColors.surface) |
| Code block bg | `#161B22` with `#30363D` border |
| Primary accent | `#58A6FF` (AppColors.primary) |
| Text primary | `#E6EDF3` (AppColors.textPrimary) |
| Text secondary | `#8B949E` (AppColors.textSecondary) |
| Body font | Inter (via theme) |
| Code font | JetBrains Mono (AppTypography.code) |

---

## 3. Layout & Visual States

### 3.1 Spoiler Gate

When the user first lands on the Solutions tab, all approach content is hidden behind a single "View Solutions" prompt:

```
┌──────────────────────────────────────────────┐
│                                              │
│         [lock icon]                          │
│                                              │
│       Solutions are hidden by default        │
│    LeetCode hides solutions until you try.  │
│                                              │
│         [  View Solutions  ]  (primary btn)  │
│                                              │
└──────────────────────────────────────────────┘
```

- The gate covers the entire tab content area.
- One tap reveals all content permanently for that session.
- No per-approach unlock needed — LeetCode shows all approaches together.
- Haptic feedback on tap.

### 3.2 Approach Selector (Horizontal Chip Strip)

Shown only when `solution.approaches.length > 1`.

```
┌────────────────────────────────────────────────────────┐
│ [Approach 1 ▼]  Approach 2  Approach 3               │
└────────────────────────────────────────────────────────┘
```

- Horizontal `ListView` with `Scrollbar`.
- Selected chip: `primary` bg at 15% opacity + `primary` border.
- Unselected chip: `card` bg + `divider` border.
- Selected name is shown in full; long names truncated with ellipsis.
- On tap, content below updates instantly (no animation needed).

### 3.3 Approach Header

Immediately below the chip strip, showing the selected approach's metadata:

```
┌────────────────────────────────────────────────────────┐
│ Sort + Two Pointers                                     │
│                                                        │
│ [Time: O(n²)]  [Space: O(1)]  [Python ✓]               │
└────────────────────────────────────────────────────────┘
```

- Approach **name** in `titleMedium` / semibold.
- **Complexity badges** as compact pill chips (same style as existing `_ComplexityBadge`):
  - Background: `surface`, border: `divider`, text: label in `textSecondary`, value in `primary`.
- **Preferred language tag**: shows the first available language with a checkmark — purely informational.

### 3.4 Language Selector

Compact horizontal row of language pills. Supported languages:

| Key | Display Name |
|---|---|
| `python` | Python |
| `java` | Java |
| `cpp` | C++ |
| `javascript` | JavaScript |
| `go` | Go |

```
┌────────────────────────────────────────────────────────┐
│  Python    Java    C++    JavaScript    Go            │
└────────────────────────────────────────────────────────┘
```

- Selected pill: `surface` bg + `primary` border + `primary` text.
- Unselected pill: transparent bg, `textSecondary` text.
- Height: 32px (same as current implementation).
- If a language has no code for the current approach, show it dimmed (opacity 0.4) and disable tap.

### 3.5 Explanation Block

```
┌────────────────────────────────────────────────────────┐
│ Sort the array and fix one number, then use two        │
│ pointers to scan the remaining range for the best     │
│ pair...                                               │
└────────────────────────────────────────────────────────┘
```

- Plain `Text` widget (bodyMedium), wrapping enabled.
- ` selectable: false` — explanations are not selectable (reduces tap-noise).
- No background, no border — blends with the scroll container.

### 3.6 Code Block

```
┌────────────────────────────────────────────────────────┐
│ Python                                     [Copy] [Edit]│
├────────────────────────────────────────────────────────┤
│ class Solution:                                        │
│     def threeSumClosest(self, nums, target):          │
│         nums.sort()                                   │
│         ...                                           │
│                                                         │
└────────────────────────────────────────────────────────┘
```

- Container: `surface` bg, `divider` border, `radiusMedium` corners, 12px padding.
- Header bar: language name (bodySmall, semibold) + `Copy` icon button + `Edit` icon button.
  - **Copy**: copies code string to clipboard; icon briefly switches to a checkmark for 1.5s.
  - **Edit**: pushes `/problem/$slug/editor` with the selected code pre-filled. The editor needs a new parameter `initialCode: String?` to accept pre-filled starter code.
- Code text: `SelectableText` with `JetBrains Mono`, 13px, `textPrimary`.
- Horizontal scroll enabled; vertical scroll via parent `SingleChildScrollView`.

### 3.7 Copy-to-Editor Flow

When "Edit" is tapped:

1. The selected code snippet is passed as `extra` to `context.push('/problem/$slug/editor', extra: problem)`.
2. The `CodeEditorScreen` reads the extra and, if code is present, pre-populates the editor.
3. The user can then run or modify the code.

---

## 4. Scroll Behavior

- The entire tab content (`SolutionTabView`) is wrapped in a `SingleChildScrollView`.
- No nested scrollables — the approach and language selectors are fixed-height widgets above the scrollable content.
- On keyboard show / landscape, content scrolls under the selectors.

---

## 5. Empty & Error States

| State | UI |
|---|---|
| No solution for this problem | Centered message: "No solutions cached yet. Start coding to contribute!" with a small icon. |
| Loading | Show skeleton loaders matching the layout above (approach chips skeleton, code block skeleton). |
| Error | Show `ErrorView` (existing shared widget) with retry. |

---

## 6. Animation & Micro-interactions

| Trigger | Animation |
|---|---|
| Approach chip tap | Instant (no transition needed — content swap is immediate). |
| Language pill tap | Instant. |
| Copy button tap | Icon swaps to `Icons.check`, returns after 1500ms. |
| Spoiler gate tap | 300ms `AnimatedOpacity` fade-out of gate, fade-in of content. |
| Tab switch | Default `TabBarView` physics. |

---

## 7. Accessibility

- All interactive elements have minimum 48×48dp touch targets (expand pill hit areas).
- Code blocks use `SelectableText` for screen reader support.
- Language pills and approach chips use `Semantics` labels (e.g., "Python, selected", "Approach 1 of 3").

---

## 8. Component Inventory

| Component | File | Description |
|---|---|---|
| `SolutionTabView` | `features/problems/presentation/widgets/solution_tab_view.dart` | Root widget — already exists, needs spoiler gate + header update |
| `_SpoilerGate` | (new, private inner widget of `SolutionTabView`) | Full-tab overlay shown before first reveal |
| `_ApproachChip` | (new, private inner widget) | Single approach chip |
| `_ComplexityBadge` | Already exists | Reused as-is |
| `_LanguagePill` | (new, private inner widget) | Single language pill |
| `_CodeBlock` | (new, private inner widget) | Code display with header, copy, edit |

---

## 9. Summary of Changes

1. **`SolutionTabView`**: Add spoiler gate state, approach header, copy-to-editor button.
2. **`CodeEditorScreen`**: Accept optional `initialCode: String?` in extra and pre-populate editor.
3. No new files required; all changes contained in existing files.
4. Follows existing dark theme tokens and 8pt spacing grid exactly.
