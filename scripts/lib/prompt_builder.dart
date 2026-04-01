/// Builds LLM prompts for visualization step generation per template type.
abstract class PromptBuilder {
  static String buildPrompt({
    required String slug,
    required String title,
    required Map<String, dynamic> approach,
    required String templateType,
    required String exampleTestcases,
  }) {
    final name = approach['name'] as String? ?? '';
    final explanation = approach['explanation'] as String? ?? '';
    final time = approach['time_complexity'] as String? ?? '';
    final space = approach['space_complexity'] as String? ?? '';
    final code = (approach['code'] as Map?)? ['python'] as String? ?? '';

    final base = '''Problem: $title ($slug)
Approach: $name
Explanation: $explanation
Time: $time, Space: $space
Example testcases: $exampleTestcases
Python code:
```python
$code
```

''';

    return base + _promptForType(templateType, slug, code);
  }

  static String _promptForType(String type, String slug, String code) {
    return switch (type) {
      'array_basic' || 'hash_map' => _promptArrayBasic(slug),
      'two_pointer' => _promptTwoPointer(slug),
      'sliding_window' => _promptSlidingWindow(slug),
      'prefix_sum' => _promptPrefixSum(slug),
      'binary_search' => _promptBinarySearch(slug),
      'stack' => _promptStack(slug),
      'tree_dfs' => _promptTreeDFS(slug),
      'tree_bfs' => _promptTreeBFS(slug),
      'grid' => _promptGrid(slug),
      'graph' => _promptGraph(slug),
      'dp_1d' => _promptDP1D(slug),
      'dp_2d' => _promptDP2D(slug),
      _ => _promptUnsupported(),
    };
  }

  static String _promptArrayBasic(String slug) => '''Template type: array_basic
For two-sum: array=[2,7,11,15], target=9.

Generate a JSON array of steps. Each step object must have:
- "description": string (newline-separated lines, max 3 lines, max 120 chars each)
- "activePointers": object mapping label ("i", "j", "curr") to array index
- "resultIndices": array of integer indices (empty until answer found)
- "hashMap": object mapping string-encoded integer keys to integer index values
             (empty {} if this approach does not use a hash map)

Output only the JSON array, no markdown.''';

  static String _promptTwoPointer(String slug) => '''Template type: two_pointer
For three-sum: array=[−1,0,1,2,−1,−2], target=0.

Generate a JSON array of steps. Each step must have:
- "description": string
- "left": integer (left pointer index, 0-based)
- "right": integer (right pointer index, 0-based)
- "resultIndices": array of integers (empty until answer found)
- "windowHighlight": boolean (true if range [left,right] should be shaded)

Pointer movement: if sum < target, move left right (left++); if sum > target,
move right left (right--); if equal, save result and continue or stop.

Output only the JSON array.''';

  static String _promptSlidingWindow(String slug) => '''Template type: sliding_window
Example: longest substring without repeating characters.

Generate a JSON array of steps. Each step must have:
- "description": string
- "windowStart": integer (inclusive left bound)
- "windowEnd": integer (inclusive right bound)
- "currentChar": string or null (character being processed)
- "charFreqMap": object mapping char to count (empty {} if not used)
- "resultIndices": array of integers (only on final answer step)

Output only the JSON array.''';

  static String _promptPrefixSum(String slug) => '''Template type: prefix_sum
Example: range sum queries, product of array except self.

Generate a JSON array of steps. Each step must have:
- "description": string
- "prefixArray": array of integers (grows each step during build phase)
- "currentIndex": integer being processed
- "highlightedRange": [l, r] range being queried (query phase only)

Output only the JSON array.''';

  static String _promptBinarySearch(String slug) => '''Template type: binary_search
Example: search in rotated sorted array.

Generate a JSON array of steps. Each step must have:
- "description": string
- "lo": integer (low pointer)
- "mid": integer (mid pointer)
- "hi": integer (high pointer)
- "eliminatedLeft": boolean (dim indices 0..lo-1)
- "eliminatedRight": boolean (dim indices hi+1..end)
- "resultIndex": integer (only when answer found)

Output only the JSON array.''';

  static String _promptStack(String slug) => '''Template type: stack
Example: valid parentheses, daily temperatures.

Generate a JSON array of steps. Each step must have:
- "description": string
- "inputArray": array being iterated
- "currentInputIndex": integer (current position)
- "stackContents": array (top = last element)
- "operation": "push"|"pop"|"peek"|null
- "resultValid": boolean (only on final step for yes/no problems)

Output only the JSON array.''';

  static String _promptTreeDFS(String slug) => '''Template type: tree_dfs
Example: max depth, path sum, diameter.

Node IDs assigned by BFS level-order: root=1, root.left=2, root.right=3, etc.

Generate JSON array. Each step must have:
- "description": string
- "nodes": array of {id, value, leftId, rightId, state}
  States: "normal", "active", "visited", "result", "path"
- "callStack": array of node IDs (DFS stack)
- "queue": array (empty for DFS, empty [] for DFS)
- "resultValue": int|null (set on final step)

Include ALL nodes in every step.

Output only the JSON array.''';

  static String _promptTreeBFS(String slug) => '''Template type: tree_bfs
Example: level order traversal, zigzag traversal.

Generate JSON array. Each step must have:
- "description": string
- "nodes": array of {id, value, leftId, rightId, state}
  States: "normal", "active", "visited", "result", "path"
- "callStack": array (empty [] for BFS)
- "queue": array of node IDs (BFS queue)
- "resultValue": int|null (set on final step)

Include ALL nodes in every step.

Output only the JSON array.''';

  static String _promptGrid(String slug) => '''Template type: grid
Example: number of islands, word search.

Generate JSON array. Each step must have:
- "description": string
- "grid": 2D array of {value, state}
  States: "normal", "active", "visited", "queued", "result", "wall"
- "currentCell": [row,col] or null
- "queue": array of [row,col] pairs
- "visitedCount": integer (count of relevant cells)

Include full grid in every step.

Output only the JSON array.''';

  static String _promptGraph(String slug) => '''Template type: graph
Example: course schedule, clone graph.

Generate JSON array. Each step must have:
- "description": string
- "nodes": array of {id, label, state}
  States: "normal", "active", "visited", "result"
- "edges": array of {fromId, toId, directed, highlighted}
- "queue": array of node IDs (BFS queue)
- "visitedSet": array of node IDs (already visited)

Output only the JSON array.''';

  static String _promptDP1D(String slug) => '''Template type: dp_1d
Example: climbing stairs, house robber, coin change.

Generate JSON array. Each step must have:
- "description": string (show recurrence calculation explicitly)
- "dpTable": array of integers (unfilled=0, show partial fill during build)
- "currentIndex": integer being computed
- "dependencyIndices": array of indices this cell depends on
- "formula": string recurrence (same for all steps, e.g. "dp[i]=dp[i-1]+dp[i-2]")

Start with base cases, then fill left to right.

Output only the JSON array.''';

  static String _promptDP2D(String slug) => '''Template type: dp_2d
Example: edit distance, longest common subsequence.

Generate JSON array. Each step must have:
- "description": string
- "dpTable": 2D array of integers (show partial fill)
- "currentRow": integer being computed
- "currentCol": integer being computed
- "dependencyCells": array of [row,col] dependencies
- "rowLabel": string (word1 for edit distance)
- "colLabel": string (word2 for edit distance)

Output only the JSON array.''';

  static String _promptUnsupported() =>
      'Unsupported template type. This problem cannot be visualized yet.';
}
