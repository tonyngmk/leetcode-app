# Visualisation AI Generation Guide

This document is the authoritative reference for using LLMs (Claude) to generate
`assets/visualization_cache.json` — the data file that drives step-by-step algorithm
visualisations in AlgoFlow.

Anyone running the generation pipeline (`scripts/generate_visualizations.dart`) or writing
prompts by hand should read this first.

---

## Table of Contents

1. [Why AI Generation](#1-why-ai-generation)
2. [Data Sources Available as Input](#2-data-sources-available-as-input)
3. [Output File: `visualization_cache.json`](#3-output-file-visualization_cachejson)
4. [Template Type Catalog](#4-template-type-catalog)
5. [Step Field Reference by Type](#5-step-field-reference-by-type)
6. [Prompt Templates](#6-prompt-templates)
7. [Worked Example: Two Sum](#7-worked-example-two-sum)
8. [Validation Rules](#8-validation-rules)
9. [Problem Classifier Heuristics](#9-problem-classifier-heuristics)
10. [Common Failure Modes](#10-common-failure-modes)
11. [Adding a New Template Type](#11-adding-a-new-template-type)

---

## 1. Why AI Generation

Writing step sequences manually for 4,000+ LeetCode problems is not feasible:

- Each problem has 1–3 approaches
- Each approach needs 5–12 pedagogical steps
- Steps must correctly reflect algorithm state (pointer positions, map contents, etc.)

The `solution_cache.json` asset already contains solution explanations and full code for
every problem. An LLM can read these and produce valid step sequences — the same way a
human teacher would annotate an algorithm walkthrough.

**Key constraint**: generation happens *offline* (at build time), not on-device. The output
is committed as `assets/visualization_cache.json` and shipped with the app. This means:

- Steps can be reviewed and corrected before release
- No API latency on the user's device
- Steps can be versioned and improved incrementally

---

## 2. Data Sources Available as Input

The generation script reads from two sources:

### `assets/solution_cache.json`

```json
{
  "two-sum": {
    "approaches": [
      {
        "name": "Brute Force",
        "explanation": "Use two nested loops to check every pair...",
        "time_complexity": "O(n^2)",
        "space_complexity": "O(1)",
        "code": {
          "python": "class Solution:\n    def twoSum(...):\n        ...",
          "java": "...",
          "cpp": "..."
        }
      }
    ]
  }
}
```

### LeetCode problem metadata (from `problems` Hive box or API)

| Field | Example |
|-------|---------|
| `titleSlug` | `"two-sum"` |
| `title` | `"Two Sum"` |
| `difficulty` | `"Easy"` |
| `topicTags` | `[{"slug": "array"}, {"slug": "hash-table"}]` |
| `exampleTestcases` | `"[2,7,11,15]\n9"` |
| `content` (HTML) | Full problem statement |

The generation script uses **topic tags + slug keywords** to classify the problem into a
template type before generating steps (see [§9 Problem Classifier](#9-problem-classifier-heuristics)).

---

## 3. Output File: `visualization_cache.json`

### Top-Level Structure

```json
{
  "<slug>": {
    "type": "<template_type>",
    "supported": true,
    "approaches": [
      {
        "name": "<must match name in solution_cache.json exactly>",
        "steps": [ ...step objects... ]
      }
    ]
  }
}
```

### Rules

- `type` must be one of the values in [§4 Template Type Catalog](#4-template-type-catalog)
- `supported: false` means the Visualize button is hidden for this problem
- `approaches` array order must match the order in `solution_cache.json`
- `name` must match exactly so the UI can correlate by approach index

### Unsupported Entry (hide button, no crash)

```json
{
  "weird-math-problem": {
    "type": "unsupported",
    "supported": false,
    "approaches": []
  }
}
```

---

## 4. Template Type Catalog

Each type corresponds to one renderer widget in the app.

| Type | Renderer Widget | Typical Problems |
|------|-----------------|-----------------|
| `array_basic` | `ArrayVisualizerWidget` | Two Sum, Rotate Array, Move Zeroes |
| `two_pointer` | `TwoPointerVisualizerWidget` | 3Sum, Container With Most Water, Trapping Rain Water |
| `sliding_window` | `SlidingWindowVisualizerWidget` | Longest Substring Without Repeating, Min Size Subarray Sum |
| `hash_map` | `ArrayVisualizerWidget` + `HashMapVisualizerWidget` | Group Anagrams, Subarray Sum Equals K |
| `prefix_sum` | `PrefixSumVisualizerWidget` | Range Sum Query, Product of Array Except Self |
| `binary_search` | `BinarySearchVisualizerWidget` | Search in Rotated Array, Find Peak Element |
| `stack` | `StackVisualizerWidget` | Valid Parentheses, Daily Temperatures, Monotonic Stack |
| `tree_dfs` | `TreeVisualizerWidget` | Max Depth, Path Sum, Diameter of Binary Tree |
| `tree_bfs` | `TreeVisualizerWidget` | Level Order Traversal, Zigzag, Right Side View |
| `grid` | `GridVisualizerWidget` | Number of Islands, Word Search, Shortest Path in Binary Matrix |
| `graph` | `GraphVisualizerWidget` | Course Schedule, Clone Graph, Network Delay Time |
| `dp_1d` | `Dp1DVisualizerWidget` | Climbing Stairs, Coin Change, House Robber |
| `dp_2d` | `Dp2DVisualizerWidget` | Edit Distance, Longest Common Subsequence, Unique Paths |

---

## 5. Step Field Reference by Type

Every step object has a `description` (required, max 120 characters per line, max 3 lines).
Additional fields are type-specific.

---

### `array_basic` / `hash_map`

Used for: single-pass array scans, hash map lookups, brute-force nested loops.

```json
{
  "description": "i = 0: complement = 9 − 2 = 7\nIs 7 in map? No. Insert 2 → 0.",
  "activePointers": { "i": 0 },
  "resultIndices": [],
  "hashMap": { "2": 0 }
}
```

| Field | Type | Description |
|-------|------|-------------|
| `description` | string | What is happening. Newline-separated. |
| `activePointers` | `{ label: index }` | Pointer labels shown above array boxes. Labels: `"i"`, `"j"`, `"curr"`. Max 2 pointers. |
| `resultIndices` | `[int]` | Indices that found the answer — shown in green. |
| `hashMap` | `{ "num": index }` | Current state of the hash map. Keys are string-encoded integers. Empty `{}` if not yet built. |

**Constraints:**
- `activePointers` values must be valid indices into the problem's example array
- `hashMap` keys must be string-encoded integers matching values in the array
- `resultIndices` are only set once the answer is found; they persist to the final step

---

### `two_pointer`

Used for: left/right converging pointers (3Sum, Container With Most Water).

```json
{
  "description": "left = 0, right = 3\nnums[0] + nums[3] = 2 + 15 = 17 > 9.\nMove right left.",
  "left": 0,
  "right": 3,
  "resultIndices": [],
  "windowHighlight": false
}
```

| Field | Type | Description |
|-------|------|-------------|
| `description` | string | |
| `left` | int | Left pointer index (shown in blue / `AppColors.primary`) |
| `right` | int | Right pointer index (shown in orange / `AppColors.medium`) |
| `resultIndices` | `[int]` | Answer indices — shown in green |
| `windowHighlight` | bool | If true, shade the range `[left, right]` lightly |

**Constraints:**
- `left <= right` always. If they cross, the step description should say "pointers crossed, stop"
- For 3Sum, a third fixed pointer `k` can be represented as an `activePointer` in the description text only (no extra field — use description text to explain it)

---

### `sliding_window`

Used for: variable or fixed-size window problems.

```json
{
  "description": "Expand right to index 3 (char 'b').\nWindow: \"abcb\" has duplicate. Shrink left.",
  "windowStart": 1,
  "windowEnd": 3,
  "currentChar": "b",
  "charFreqMap": { "a": 1, "b": 2, "c": 1 }
}
```

| Field | Type | Description |
|-------|------|-------------|
| `description` | string | |
| `windowStart` | int | Inclusive left bound of current window |
| `windowEnd` | int | Inclusive right bound of current window |
| `currentChar` | string? | Character being processed (for string problems). Null for numeric arrays. |
| `charFreqMap` | `{ char: count }` | Current character frequency map. Empty `{}` if not used. |
| `resultIndices` | `[int]`? | Only set on final answer step |

---

### `prefix_sum`

Used for: running sum, range queries.

```json
{
  "description": "Build prefix sum. index 2: prefixSum[2] = prefixSum[1] + nums[2] = 3 + 11 = 14.",
  "prefixArray": [0, 2, 9, 20, 35],
  "currentIndex": 2,
  "highlightedRange": [1, 2]
}
```

| Field | Type | Description |
|-------|------|-------------|
| `description` | string | |
| `prefixArray` | `[int]` | Current state of the prefix sum array (grows each step during build phase) |
| `currentIndex` | int? | Index being processed |
| `highlightedRange` | `[int, int]`? | `[l, r]` range being queried (query phase only) |

---

### `binary_search`

Used for: sorted array search, rotated array search.

```json
{
  "description": "lo=0, mid=2, hi=4. nums[mid]=11 > target=9. Search left half.",
  "lo": 0,
  "mid": 2,
  "hi": 4,
  "eliminatedLeft": false,
  "eliminatedRight": true
}
```

| Field | Type | Description |
|-------|------|-------------|
| `description` | string | |
| `lo` | int | Current low pointer |
| `mid` | int | Current mid pointer |
| `hi` | int | Current high pointer |
| `eliminatedLeft` | bool | If true, dim indices `0..lo-1` |
| `eliminatedRight` | bool | If true, dim indices `hi+1..end` |
| `resultIndex` | int? | Set only when answer is found |

---

### `stack`

Used for: push/pop operations, monotonic stacks.

```json
{
  "description": "Process ')'. Top of stack is '('. Pop — matched pair found.",
  "inputArray": ["(", "(", ")", ")"],
  "currentInputIndex": 2,
  "stackContents": ["("],
  "operation": "pop",
  "resultValid": null
}
```

| Field | Type | Description |
|-------|------|-------------|
| `description` | string | |
| `inputArray` | `[string\|int]` | The input array/string being iterated |
| `currentInputIndex` | int | Current index in the input |
| `stackContents` | `[string\|int]` | Current stack from bottom to top (top = last element) |
| `operation` | `"push"\|"pop"\|"peek"\|null` | What operation just happened |
| `resultValid` | bool? | Set on final step: true/false for problems like Valid Parentheses |

---

### `tree_dfs` / `tree_bfs`

Tree steps use a **flat node list** rather than a recursive structure. This makes diffing between steps straightforward and avoids deep nesting in JSON.

```json
{
  "description": "Visit node 7 (right child of 3).\nCurrent max depth = 2.",
  "nodes": [
    { "id": 1, "value": 4, "leftId": 2, "rightId": 3, "state": "visited" },
    { "id": 2, "value": 2, "leftId": null, "rightId": null, "state": "visited" },
    { "id": 3, "value": 7, "leftId": null, "rightId": null, "state": "active" }
  ],
  "callStack": [1, 3],
  "queue": [],
  "resultValue": null
}
```

| Field | Type | Description |
|-------|------|-------------|
| `description` | string | |
| `nodes` | `[TreeNode]` | All nodes. Each has `id`, `value`, `leftId?`, `rightId?`, `state` |
| `callStack` | `[int]` | Node IDs currently on the DFS call stack (DFS only, empty for BFS) |
| `queue` | `[int]` | Node IDs in BFS queue (BFS only, empty for DFS) |
| `resultValue` | `int\|null` | Final answer if this is the last step |

**TreeNode states:**

| State | Colour |
|-------|--------|
| `normal` | Default (card bg, divider border) |
| `active` | `AppColors.primary` (blue) — currently being processed |
| `visited` | `AppColors.textSecondary` dimmed — already processed |
| `result` | `AppColors.easy` (green) — part of the answer |
| `path` | `AppColors.medium` (amber) — on the current path being explored |

**Constraints:**
- Node IDs must be stable across all steps in the approach (same node = same ID)
- IDs start at 1, assigned by BFS level order (root = 1, root.left = 2, root.right = 3, etc.)
- `leftId` / `rightId` must reference IDs that exist in `nodes`

---

### `grid`

Used for: matrix traversal, island counting, BFS on grids.

```json
{
  "description": "BFS from (0,0). Mark as visited. Add neighbours (0,1) and (1,0) to queue.",
  "grid": [
    [{"value":"1","state":"visited"}, {"value":"1","state":"queued"}, {"value":"0","state":"normal"}],
    [{"value":"1","state":"queued"}, {"value":"1","state":"normal"}, {"value":"0","state":"normal"}],
    [{"value":"0","state":"normal"}, {"value":"0","state":"normal"}, {"value":"0","state":"normal"}]
  ],
  "currentCell": [0, 0],
  "queue": [[0,1],[1,0]],
  "visitedCount": 1
}
```

| Field | Type | Description |
|-------|------|-------------|
| `description` | string | |
| `grid` | `GridCell[][]` | 2D array of `{ value, state }` objects |
| `currentCell` | `[row, col]` | Cell currently being processed |
| `queue` | `[[row,col]]` | BFS queue contents |
| `visitedCount` | int? | Running count for "number of islands" style problems |

**GridCell states:** `normal`, `active`, `visited`, `queued`, `result`, `wall`

---

### `dp_1d`

```json
{
  "description": "dp[3] = dp[2] + dp[1] = 2 + 1 = 3\n(3 ways to reach step 3)",
  "dpTable": [1, 1, 2, 3, 0, 0],
  "currentIndex": 3,
  "dependencyIndices": [1, 2],
  "formula": "dp[i] = dp[i-1] + dp[i-2]"
}
```

| Field | Type | Description |
|-------|------|-------------|
| `description` | string | |
| `dpTable` | `[int]` | Full DP table (unfilled cells show 0 or null) |
| `currentIndex` | int | Cell currently being computed |
| `dependencyIndices` | `[int]` | Cells this cell depends on (highlighted) |
| `formula` | string? | Recurrence relation text, shown above table |

---

### `dp_2d`

```json
{
  "description": "dp[1][2]: edit 'ab' → 'bc'. Match? No.\ndp[1][2] = 1 + min(dp[0][2], dp[1][1], dp[0][1]) = 1 + min(2,1,1) = 2.",
  "dpTable": [[0,1,2],[1,1,2],[2,2,1]],
  "currentRow": 1,
  "currentCol": 2,
  "dependencyCells": [[0,2],[1,1],[0,1]],
  "rowLabel": "ab",
  "colLabel": "bc"
}
```

| Field | Type | Description |
|-------|------|-------------|
| `description` | string | |
| `dpTable` | `[[int]]` | Full 2D table (show partial values during build phase) |
| `currentRow` | int | Row being computed |
| `currentCol` | int | Column being computed |
| `dependencyCells` | `[[row,col]]` | Cells this cell depends on |
| `rowLabel` | string? | String label for row axis (e.g., word1 for Edit Distance) |
| `colLabel` | string? | String label for column axis |

---

## 6. Prompt Templates

### 6.1 System Prompt (shared across all types)

```
You are an algorithm teaching assistant. Your task is to generate a step-by-step
visualisation of an algorithm for use in a mobile app.

You will be given:
- A problem slug and title
- An algorithm approach name and explanation
- The solution code in Python
- An example input and expected output
- The visualisation template type to use

You must output ONLY a valid JSON array of step objects. Do not include any prose,
markdown fences, or explanation outside the JSON.

Rules:
1. 5 to 12 steps per approach. Fewer is better if the algorithm is clear.
2. Every step must have a "description" field (max 3 lines, max 120 chars each).
3. All pointer/index values must be valid indices into the example input array.
4. State must be internally consistent: e.g. hashMap in step N must be a superset
   of hashMap in step N-1 (entries are never removed mid-algorithm unless the
   algorithm explicitly removes them).
5. The final step must show the correct answer and include a complexity summary.
6. Do not hallucinate intermediate states — trace the algorithm faithfully on the
   given example input.
```

---

### 6.2 User Prompt: `array_basic` / `hash_map`

```
Problem: {{title}} ({{slug}})
Approach: {{approach.name}}
Explanation: {{approach.explanation}}
Time: {{approach.time_complexity}}, Space: {{approach.space_complexity}}
Example input: {{example_input}}
Expected output: {{example_output}}
Python code:
{{approach.code.python}}

Template type: array_basic (or hash_map if approach uses a hash table)
Example input array for visualisation: {{visualisation_array}}
Target value (if applicable): {{target}}

Generate a JSON array of steps. Each step object must have:
- "description": string (newline-separated lines)
- "activePointers": object mapping label ("i", "j", "curr") to array index
- "resultIndices": array of integer indices (empty until answer found)
- "hashMap": object mapping string-encoded integer keys to integer index values
             (empty {} if this approach does not use a hash map)

Output only the JSON array.
```

---

### 6.3 User Prompt: `two_pointer`

```
Problem: {{title}} ({{slug}})
Approach: {{approach.name}}
Explanation: {{approach.explanation}}
Python code:
{{approach.code.python}}

Example input array: {{visualisation_array}}
Target sum (if applicable): {{target}}

Template type: two_pointer

Generate a JSON array of steps. Each step object must have:
- "description": string
- "left": integer (left pointer index, 0-based)
- "right": integer (right pointer index, 0-based)
- "resultIndices": array of integers (empty until answer found)
- "windowHighlight": boolean (true if the range [left, right] should be shaded)

Pointer movement rules to follow:
- Start with left=0, right=array.length-1
- If nums[left]+nums[right] < target: move left right (left++)
- If nums[left]+nums[right] > target: move right left (right--)
- If equal: set resultIndices and stop

Output only the JSON array.
```

---

### 6.4 User Prompt: `sliding_window`

```
Problem: {{title}} ({{slug}})
Approach: {{approach.name}}
Explanation: {{approach.explanation}}
Python code:
{{approach.code.python}}

Example input: {{example_input}}

Template type: sliding_window

Generate a JSON array of steps. Each step must have:
- "description": string
- "windowStart": integer (inclusive left bound)
- "windowEnd": integer (inclusive right bound)
- "currentChar": string or null (current character being processed, null for numeric arrays)
- "charFreqMap": object mapping char/number to count (empty {} if not used)
- "resultIndices": array of integers (only on final answer step)

Output only the JSON array.
```

---

### 6.5 User Prompt: `tree_dfs` / `tree_bfs`

```
Problem: {{title}} ({{slug}})
Approach: {{approach.name}}
Explanation: {{approach.explanation}}
Python code:
{{approach.code.python}}

Example tree (BFS level-order values, null for missing nodes): {{tree_values}}
Expected output: {{example_output}}

Template type: {{tree_dfs or tree_bfs}}

Node ID assignment: root = 1, assigned by BFS level order.
(root.left = 2, root.right = 3, root.left.left = 4, root.left.right = 5, etc.)

Generate a JSON array of steps. Each step must have:
- "description": string
- "nodes": array of node objects, each with:
    { "id": int, "value": int, "leftId": int|null, "rightId": int|null,
      "state": "normal"|"active"|"visited"|"result"|"path" }
  Include ALL nodes in every step (even unchanged ones).
- "callStack": array of node IDs (DFS only; empty [] for BFS)
- "queue": array of node IDs (BFS only; empty [] for DFS)
- "resultValue": int|null (set on final step with the answer)

Output only the JSON array.
```

---

### 6.6 User Prompt: `grid`

```
Problem: {{title}} ({{slug}})
Approach: {{approach.name}}
Python code:
{{approach.code.python}}

Example grid: {{example_grid_as_2d_array}}
Expected output: {{example_output}}

Template type: grid

Generate a JSON array of steps. Each step must have:
- "description": string
- "grid": 2D array of cell objects, each with:
    { "value": string, "state": "normal"|"active"|"visited"|"queued"|"result"|"wall" }
  Include the full grid in every step.
- "currentCell": [row, col] or null
- "queue": array of [row, col] pairs (BFS queue; empty [] for DFS)
- "visitedCount": integer count of relevant cells processed (null if not applicable)

Output only the JSON array.
```

---

### 6.7 User Prompt: `dp_1d`

```
Problem: {{title}} ({{slug}})
Approach: {{approach.name}}
Python code:
{{approach.code.python}}

Example input: {{example_input}}
Expected output: {{example_output}}
Array size for visualisation: {{n}} (use a small n like 5 or 6 for clarity)

Template type: dp_1d

Generate a JSON array of steps. Each step must have:
- "description": string (show the recurrence calculation explicitly)
- "dpTable": array of n+1 integers (unfilled cells = 0; show partial fill during build)
- "currentIndex": integer being computed this step
- "dependencyIndices": array of integers this cell depends on
- "formula": string recurrence relation (same for all steps, e.g. "dp[i] = dp[i-1] + dp[i-2]")

Start with a step showing the base cases initialised, then fill left to right.

Output only the JSON array.
```

---

## 7. Worked Example: Two Sum

### Input to Generation Script

```
slug:          two-sum
title:         Two Sum
approach name: One-Pass Hash Map
explanation:   We iterate through the array once. Before inserting nums[i] into
               the map, we check if the complement (target - nums[i]) already
               exists. If it does, we've found our answer immediately.
time:          O(n)
space:         O(n)
python code:
  def twoSum(self, nums, target):
      seen = {}
      for i, num in enumerate(nums):
          complement = target - num
          if complement in seen:
              return [seen[complement], i]
          seen[num] = i
      return []

example input:  nums=[2,7,11,15], target=9
example output: [0,1]
visualisation array: [2, 7, 11, 15]
target: 9
```

### Prompt Sent to Claude

*(System prompt from §6.1 + user prompt from §6.2 with fields substituted)*

### Expected LLM Output

```json
[
  {
    "description": "One-Pass Hash Map: check complement AND insert in a single pass.\nnums = [2, 7, 11, 15],  target = 9",
    "activePointers": {},
    "resultIndices": [],
    "hashMap": {}
  },
  {
    "description": "i = 0: complement = 9 − 2 = 7\nIs 7 in map?  No.  Insert  2 → 0.",
    "activePointers": { "i": 0 },
    "resultIndices": [],
    "hashMap": {}
  },
  {
    "description": "Map after i=0: { 2→0 }",
    "activePointers": { "i": 0 },
    "resultIndices": [],
    "hashMap": { "2": 0 }
  },
  {
    "description": "i = 1: complement = 9 − 7 = 2\nIs 2 in map?  Yes → at index 0.",
    "activePointers": { "i": 1 },
    "resultIndices": [],
    "hashMap": { "2": 0 }
  },
  {
    "description": "Match!  map[2] = 0,  current index = 1\nIndices 2 and 3 never visited.",
    "activePointers": { "i": 1 },
    "resultIndices": [0, 1],
    "hashMap": { "2": 0 }
  },
  {
    "description": "Return [0, 1].\nTime: O(n)   Space: O(n)\nOne-Pass is faster — no second loop.",
    "activePointers": {},
    "resultIndices": [0, 1],
    "hashMap": { "2": 0 }
  }
]
```

### Where this goes in `visualization_cache.json`

```json
{
  "two-sum": {
    "type": "hash_map",
    "supported": true,
    "approaches": [
      {
        "name": "Brute Force",
        "steps": [ ...5 steps... ]
      },
      {
        "name": "Two-Pass Hash Map",
        "steps": [ ...9 steps... ]
      },
      {
        "name": "One-Pass Hash Map",
        "steps": [ ...6 steps above... ]
      }
    ]
  }
}
```

---

## 8. Validation Rules

The `StepValidator` in `scripts/lib/step_validator.dart` enforces these:

### Universal (all types)

| Rule | Check |
|------|-------|
| At least 3 steps | `steps.length >= 3` |
| At most 15 steps | `steps.length <= 15` |
| Description present | `step.description != null && step.description.isNotEmpty` |
| Description line length | Each newline-separated line ≤ 120 characters |
| Description max lines | ≤ 3 lines per step |

### `array_basic` / `hash_map`

| Rule | Check |
|------|-------|
| Pointer indices in bounds | `0 <= index < array.length` for all values in `activePointers` |
| Result indices in bounds | `0 <= index < array.length` for all values in `resultIndices` |
| Result indices stable | Once set, `resultIndices` must remain the same in all subsequent steps |
| Hash map monotone | `hashMap` keys in step N must be a superset of step N-1 (entries only added, never removed) — unless the algorithm explicitly removes entries (e.g. sliding window) |
| Hash map values in bounds | `0 <= value < array.length` |

### `two_pointer`

| Rule | Check |
|------|-------|
| `left <= right` | Always (crossing = stop condition, not a valid state) |
| Pointer progression | `left` only increases; `right` only decreases (for standard two-pointer) |
| Final step has result | Last step must set `resultIndices` or description must explain no solution |

### `tree_dfs` / `tree_bfs`

| Rule | Check |
|------|-------|
| Node IDs stable | Same node must have same ID in every step |
| No orphaned edges | All `leftId` / `rightId` values must reference existing node IDs in same step |
| All nodes present | Node count must be the same in every step |
| At most 1 active node | Only 1 node with state `"active"` per step (for clarity) |

### `grid`

| Rule | Check |
|------|-------|
| Grid dimensions stable | Same number of rows and columns in every step |
| `currentCell` in bounds | `0 <= row < rows`, `0 <= col < cols` |
| Wall cells never change state | Cells with `state: "wall"` stay `"wall"` throughout |

---

## 9. Problem Classifier Heuristics

The classifier maps `(topicTags, slug)` → `TemplateType`. Applied in priority order:

```
1. slug contains "tree" or "binary-tree"          → tree_dfs (default) or tree_bfs
2. topicTags contains "binary-search"              → binary_search
3. topicTags contains "dynamic-programming" AND
   problem is "easy" or "medium" AND
   1D input (single array / single integer)        → dp_1d
4. topicTags contains "dynamic-programming" AND
   2D input (two strings / grid)                   → dp_2d
5. topicTags contains "stack"                      → stack
6. topicTags contains "graph" or "union-find"      → graph
7. topicTags contains "matrix"                     → grid
8. slug contains "island" or "matrix" or "grid"    → grid
9. topicTags contains "sliding-window"             → sliding_window
10. topicTags contains "two-pointers"              → two_pointer
11. topicTags contains "prefix-sum"                → prefix_sum
12. topicTags contains "hash-table"                → hash_map
13. topicTags contains "array"                     → array_basic
14. default                                        → unsupported
```

**Override file**: `scripts/data/classifier_overrides.json`
```json
{
  "trapping-rain-water": "two_pointer",
  "sliding-window-maximum": "sliding_window",
  "serialize-and-deserialize-binary-tree": "tree_bfs"
}
```

Manual overrides take precedence over all heuristics.

---

## 10. Common Failure Modes

| Symptom | Cause | Fix |
|---------|-------|-----|
| Pointer out of bounds (e.g. `"i": 5` for 4-element array) | LLM traces wrong input size | Add explicit `"array length = N"` to prompt |
| Hash map entries disappear between steps | LLM models map incorrectly | Add rule: "hashMap is append-only unless algorithm removes entries" to prompt |
| Too many steps (>12) | LLM over-explains | Add `"Be concise. Prefer 6–8 steps."` to prompt |
| Step description references variable names not in the code | LLM mixes approaches | Include only the specific approach's code, not all approaches |
| Tree node IDs change between steps | LLM re-assigns IDs | Add `"Node IDs must be stable — same node = same ID in every step"` |
| Final step missing complexity summary | Inconsistent output | Add `"The final step MUST end with 'Time: O(...) Space: O(...)'"` |
| `resultIndices` set too early | LLM anticipates the answer | Add `"Only set resultIndices on the step where the match is confirmed"` |

---

## 11. Adding a New Template Type

1. **Define the step fields** in §5 of this document
2. **Add the type string** to the `TemplateType` enum in `scripts/lib/problem_classifier.dart`
3. **Write a prompt template** in §6 of this document
4. **Add the Dart subclass** to `lib/features/visualizer/domain/visualization_step.dart`:
   - Extend `sealed class VisualizationStep`
   - Add `fromJson` factory
5. **Create the renderer widget** in `lib/features/visualizer/presentation/widgets/`
6. **Register in `RendererFactory`** — add a case in the `switch` statement
7. **Update the classifier heuristics** in §9
8. **Run generation** with `dart scripts/generate_visualizations.dart --type <new_type>`
9. **Manual review** — validate at least 5 generated entries by hand before merging

Each step takes ~30 minutes for a developer. New types should be added one at a time
to keep review scope manageable.
