/// Discriminated union of all visualisation step types.
/// Each subclass corresponds to one renderer template in [RendererFactory].
sealed class VisualizationStep {
  /// Human-readable description of what is happening this step.
  final String description;

  const VisualizationStep({required this.description});

  /// Dispatch factory — delegates to the correct subclass based on [type].
  static VisualizationStep fromJson(Map<String, dynamic> json, String type) {
    return switch (type) {
      'two_pointer' => TwoPointerStep.fromJson(json),
      'sliding_window' => SlidingWindowStep.fromJson(json),
      'prefix_sum' => PrefixSumStep.fromJson(json),
      'binary_search' => BinarySearchStep.fromJson(json),
      'tree_dfs' || 'tree_bfs' => TreeStep.fromJson(json),
      'grid' => GridStep.fromJson(json),
      'graph' => GraphStep.fromJson(json),
      'stack' => StackStep.fromJson(json),
      'queue' => QueueStep.fromJson(json),
      'dp_1d' => Dp1DStep.fromJson(json),
      'dp_2d' => Dp2DStep.fromJson(json),
      'heap' => HeapStep.fromJson(json),
      // array_basic, hash_map and any unknown type → ArrayStep
      _ => ArrayStep.fromJson(json),
    };
  }
}

// ─── Array / Hash Map ─────────────────────────────────────────────────────────

/// Step for array-based problems, optionally with a hash map overlay.
/// Used for template types: array_basic, hash_map.
final class ArrayStep extends VisualizationStep {
  /// The array values being visualised.
  final List<int> array;

  /// Pointer labels mapped to array indices, e.g. {'i': 0, 'j': 1}.
  final Map<String, int> activePointers;

  /// Indices that hold the answer — rendered in AppColors.easy (green).
  final List<int> resultIndices;

  /// Current hash map state: number → index. Empty when not yet built.
  final Map<int, int> hashMap;

  const ArrayStep({
    required super.description,
    required this.array,
    this.activePointers = const {},
    this.resultIndices = const [],
    this.hashMap = const {},
  });

  factory ArrayStep.fromJson(Map<String, dynamic> json) {
    // activePointers: {"i": 0, "j": 1} — values are ints
    final rawPointers = json['activePointers'] as Map? ?? {};
    final pointers = <String, int>{
      for (final e in rawPointers.entries) e.key as String: e.value as int,
    };

    // resultIndices: [0, 1]
    final rawResult = json['resultIndices'] as List? ?? [];
    final result = rawResult.cast<int>();

    // hashMap: {"2": 0, "7": 1} — JSON keys are strings, convert to int
    final rawMap = json['hashMap'] as Map? ?? {};
    final map = <int, int>{
      for (final e in rawMap.entries) int.parse(e.key as String): e.value as int,
    };

    // array is injected from the approach-level field by VisualizationApproach.fromJson
    final rawArray = json['array'] as List? ?? [];
    final array = rawArray.cast<int>();

    return ArrayStep(
      description: json['description'] as String? ?? '',
      array: array,
      activePointers: pointers,
      resultIndices: result,
      hashMap: map,
    );
  }
}

// ─── Two Pointer ──────────────────────────────────────────────────────────────

/// Step for two-pointer problems (converging left/right pointers).
/// Used for template type: two_pointer.
final class TwoPointerStep extends VisualizationStep {
  final List<int> array;
  final int left;
  final int right;
  final List<int> resultIndices;
  final bool windowHighlight;

  const TwoPointerStep({
    required super.description,
    required this.array,
    required this.left,
    required this.right,
    this.resultIndices = const [],
    this.windowHighlight = false,
  });

  factory TwoPointerStep.fromJson(Map<String, dynamic> json) {
    final rawArray = json['array'] as List? ?? [];
    final rawResult = json['resultIndices'] as List? ?? [];
    return TwoPointerStep(
      description: json['description'] as String? ?? '',
      array: rawArray.cast<int>(),
      left: json['left'] as int? ?? 0,
      right: json['right'] as int? ?? 0,
      resultIndices: rawResult.cast<int>(),
      windowHighlight: json['windowHighlight'] as bool? ?? false,
    );
  }
}

// ─── Sliding Window ───────────────────────────────────────────────────────────

/// Step for sliding window problems.
/// Used for template type: sliding_window.
final class SlidingWindowStep extends VisualizationStep {
  final List<int> array;
  final int windowStart;
  final int windowEnd;
  final String? currentChar;
  final Map<String, int> charFreqMap;
  final List<int> resultIndices;

  const SlidingWindowStep({
    required super.description,
    required this.array,
    required this.windowStart,
    required this.windowEnd,
    this.currentChar,
    this.charFreqMap = const {},
    this.resultIndices = const [],
  });

  factory SlidingWindowStep.fromJson(Map<String, dynamic> json) {
    final rawArray = json['array'] as List? ?? [];
    final rawResult = json['resultIndices'] as List? ?? [];
    final rawFreq = json['charFreqMap'] as Map? ?? {};
    return SlidingWindowStep(
      description: json['description'] as String? ?? '',
      array: rawArray.cast<int>(),
      windowStart: json['windowStart'] as int? ?? 0,
      windowEnd: json['windowEnd'] as int? ?? 0,
      currentChar: json['currentChar'] as String?,
      charFreqMap: {
        for (final e in rawFreq.entries) e.key as String: e.value as int,
      },
      resultIndices: rawResult.cast<int>(),
    );
  }
}

// ─── Prefix Sum ───────────────────────────────────────────────────────────────

/// Step for prefix sum problems.
/// Used for template type: prefix_sum.
final class PrefixSumStep extends VisualizationStep {
  final List<int> array;
  final List<int> prefixArray;
  final int? currentIndex;
  final (int, int)? highlightedRange;

  const PrefixSumStep({
    required super.description,
    required this.array,
    required this.prefixArray,
    this.currentIndex,
    this.highlightedRange,
  });

  factory PrefixSumStep.fromJson(Map<String, dynamic> json) {
    final rawArray = json['array'] as List? ?? [];
    final rawPrefix = json['prefixArray'] as List? ?? [];
    final rawRange = json['highlightedRange'] as List?;
    return PrefixSumStep(
      description: json['description'] as String? ?? '',
      array: rawArray.cast<int>(),
      prefixArray: rawPrefix.cast<int>(),
      currentIndex: json['currentIndex'] as int?,
      highlightedRange: rawRange != null
          ? (rawRange[0] as int, rawRange[1] as int)
          : null,
    );
  }
}

// ─── Binary Search ────────────────────────────────────────────────────────────

/// Step for binary search problems.
/// Used for template type: binary_search.
final class BinarySearchStep extends VisualizationStep {
  final List<int> array;
  final int lo;
  final int mid;
  final int hi;
  final bool eliminatedLeft;
  final bool eliminatedRight;
  final int? resultIndex;

  const BinarySearchStep({
    required super.description,
    required this.array,
    required this.lo,
    required this.mid,
    required this.hi,
    this.eliminatedLeft = false,
    this.eliminatedRight = false,
    this.resultIndex,
  });

  factory BinarySearchStep.fromJson(Map<String, dynamic> json) {
    final rawArray = json['array'] as List? ?? [];
    return BinarySearchStep(
      description: json['description'] as String? ?? '',
      array: rawArray.cast<int>(),
      lo: json['lo'] as int? ?? 0,
      mid: json['mid'] as int? ?? 0,
      hi: json['hi'] as int? ?? 0,
      eliminatedLeft: json['eliminatedLeft'] as bool? ?? false,
      eliminatedRight: json['eliminatedRight'] as bool? ?? false,
      resultIndex: json['resultIndex'] as int?,
    );
  }
}

// ─── Tree ─────────────────────────────────────────────────────────────────────

/// Single node in a tree visualization. Flat list representation for diffing steps.
final class VisTreeNode {
  final int id;
  final int value;
  final int? leftId;
  final int? rightId;
  final bool highlighted;
  final String? color;

  const VisTreeNode({
    required this.id,
    required this.value,
    this.leftId,
    this.rightId,
    this.highlighted = false,
    this.color,
  });

  factory VisTreeNode.fromJson(Map<String, dynamic> json) {
    return VisTreeNode(
      id: json['id'] as int? ?? 0,
      value: json['value'] as int? ?? 0,
      leftId: json['leftId'] as int?,
      rightId: json['rightId'] as int?,
      highlighted: json['highlighted'] as bool? ?? false,
      color: json['color'] as String?,
    );
  }
}

/// Step for tree-based problems (in-order, level-order, path sum, etc.).
/// Used for template types: tree_dfs, tree_bfs.
final class TreeStep extends VisualizationStep {
  final List<VisTreeNode> nodes;
  final List<(int, int)> highlightedEdges;
  final List<int> callStack;

  const TreeStep({
    required super.description,
    required this.nodes,
    this.highlightedEdges = const [],
    this.callStack = const [],
  });

  factory TreeStep.fromJson(Map<String, dynamic> json) {
    final rawNodes = json['nodes'] as List? ?? [];
    final nodes = rawNodes
        .map((n) => VisTreeNode.fromJson(n as Map<String, dynamic>))
        .toList();

    final rawEdges = json['highlightedEdges'] as List? ?? [];
    final edges = rawEdges
        .map((e) {
          final edge = e as List;
          return (edge[0] as int, edge[1] as int);
        })
        .toList();

    final rawStack = json['callStack'] as List? ?? [];
    final stack = rawStack.cast<int>();

    return TreeStep(
      description: json['description'] as String? ?? '',
      nodes: nodes,
      highlightedEdges: edges,
      callStack: stack,
    );
  }
}

// ─── Grid ─────────────────────────────────────────────────────────────────────

/// Single cell in a grid visualization.
final class VisGridCell {
  final int row;
  final int col;
  final int value;
  final String state; // 'normal', 'visited', 'active', 'result', 'wall'

  const VisGridCell({
    required this.row,
    required this.col,
    required this.value,
    this.state = 'normal',
  });

  factory VisGridCell.fromJson(Map<String, dynamic> json) {
    return VisGridCell(
      row: json['row'] as int? ?? 0,
      col: json['col'] as int? ?? 0,
      value: json['value'] as int? ?? 0,
      state: json['state'] as String? ?? 'normal',
    );
  }
}

/// Step for grid/matrix problems (Number of Islands, Word Search, etc.).
/// Used for template type: grid.
final class GridStep extends VisualizationStep {
  final List<List<VisGridCell>> grid;
  final (int, int)? currentCell;
  final List<(int, int)> queue;

  const GridStep({
    required super.description,
    required this.grid,
    this.currentCell,
    this.queue = const [],
  });

  factory GridStep.fromJson(Map<String, dynamic> json) {
    final rawGrid = json['grid'] as List? ?? [];
    final grid = rawGrid
        .map((row) => (row as List)
            .map((cell) => VisGridCell.fromJson(cell as Map<String, dynamic>))
            .toList())
        .toList();

    final rawCurrent = json['currentCell'] as List?;
    final currentCell = rawCurrent != null
        ? (rawCurrent[0] as int, rawCurrent[1] as int)
        : null;

    final rawQueue = json['queue'] as List? ?? [];
    final queue = rawQueue
        .map((item) {
          final cell = item as List;
          return (cell[0] as int, cell[1] as int);
        })
        .toList();

    return GridStep(
      description: json['description'] as String? ?? '',
      grid: grid,
      currentCell: currentCell,
      queue: queue,
    );
  }
}

// ─── Graph ────────────────────────────────────────────────────────────────────

/// Single node in a graph visualization.
final class VisGraphNode {
  final int id;
  final String label;
  final double x;
  final double y;
  final String state; // 'normal', 'visited', 'active', 'result'

  const VisGraphNode({
    required this.id,
    required this.label,
    required this.x,
    required this.y,
    this.state = 'normal',
  });

  factory VisGraphNode.fromJson(Map<String, dynamic> json) {
    return VisGraphNode(
      id: json['id'] as int? ?? 0,
      label: json['label'] as String? ?? '',
      x: (json['x'] as num?)?.toDouble() ?? 0.0,
      y: (json['y'] as num?)?.toDouble() ?? 0.0,
      state: json['state'] as String? ?? 'normal',
    );
  }
}

/// Single edge in a graph visualization.
final class VisGraphEdge {
  final int fromId;
  final int toId;
  final bool directed;
  final bool highlighted;

  const VisGraphEdge({
    required this.fromId,
    required this.toId,
    this.directed = false,
    this.highlighted = false,
  });

  factory VisGraphEdge.fromJson(Map<String, dynamic> json) {
    return VisGraphEdge(
      fromId: json['fromId'] as int? ?? 0,
      toId: json['toId'] as int? ?? 0,
      directed: json['directed'] as bool? ?? false,
      highlighted: json['highlighted'] as bool? ?? false,
    );
  }
}

/// Step for graph problems (BFS/DFS, shortest path, etc.).
/// Used for template type: graph.
final class GraphStep extends VisualizationStep {
  final List<VisGraphNode> nodes;
  final List<VisGraphEdge> edges;
  final List<int> visitedIds;
  final int? activeId;

  const GraphStep({
    required super.description,
    required this.nodes,
    required this.edges,
    this.visitedIds = const [],
    this.activeId,
  });

  factory GraphStep.fromJson(Map<String, dynamic> json) {
    final rawNodes = json['nodes'] as List? ?? [];
    final nodes = rawNodes
        .map((n) => VisGraphNode.fromJson(n as Map<String, dynamic>))
        .toList();

    final rawEdges = json['edges'] as List? ?? [];
    final edges = rawEdges
        .map((e) => VisGraphEdge.fromJson(e as Map<String, dynamic>))
        .toList();

    final rawVisited = json['visitedIds'] as List? ?? [];
    final visited = rawVisited.cast<int>();

    return GraphStep(
      description: json['description'] as String? ?? '',
      nodes: nodes,
      edges: edges,
      visitedIds: visited,
      activeId: json['activeId'] as int?,
    );
  }
}

// ─── Stack ────────────────────────────────────────────────────────────────────

/// Step for stack-based problems.
/// Used for template type: stack.
final class StackStep extends VisualizationStep {
  final List<int> stack;
  final String currentOp; // 'push', 'pop', 'peek', or empty
  final int? inputValue; // value being pushed/popped
  final List<int> resultStack; // for problems that return the final stack

  const StackStep({
    required super.description,
    required this.stack,
    this.currentOp = '',
    this.inputValue,
    this.resultStack = const [],
  });

  factory StackStep.fromJson(Map<String, dynamic> json) {
    final rawStack = json['stack'] as List? ?? [];
    final rawResult = json['resultStack'] as List? ?? [];

    return StackStep(
      description: json['description'] as String? ?? '',
      stack: rawStack.cast<int>(),
      currentOp: json['currentOp'] as String? ?? '',
      inputValue: json['inputValue'] as int?,
      resultStack: rawResult.cast<int>(),
    );
  }
}

// ─── Queue ────────────────────────────────────────────────────────────────────

/// Step for queue-based problems.
/// Used for template type: queue (though often uses same visualizer as stack).
final class QueueStep extends VisualizationStep {
  final List<int> queue;
  final String currentOp; // 'enqueue', 'dequeue', or empty
  final int? inputValue;
  final List<int> resultQueue;

  const QueueStep({
    required super.description,
    required this.queue,
    this.currentOp = '',
    this.inputValue,
    this.resultQueue = const [],
  });

  factory QueueStep.fromJson(Map<String, dynamic> json) {
    final rawQueue = json['queue'] as List? ?? [];
    final rawResult = json['resultQueue'] as List? ?? [];

    return QueueStep(
      description: json['description'] as String? ?? '',
      queue: rawQueue.cast<int>(),
      currentOp: json['currentOp'] as String? ?? '',
      inputValue: json['inputValue'] as int?,
      resultQueue: rawResult.cast<int>(),
    );
  }
}

// ─── Dynamic Programming (1D) ──────────────────────────────────────────────────

/// Step for 1D DP problems.
/// Used for template type: dp_1d.
final class Dp1DStep extends VisualizationStep {
  final List<int> table;
  final int? currentIndex;
  final String? formula; // e.g., "dp[i] = dp[i-1] + dp[i-2]"

  const Dp1DStep({
    required super.description,
    required this.table,
    this.currentIndex,
    this.formula,
  });

  factory Dp1DStep.fromJson(Map<String, dynamic> json) {
    final rawTable = json['table'] as List? ?? [];

    return Dp1DStep(
      description: json['description'] as String? ?? '',
      table: rawTable.cast<int>(),
      currentIndex: json['currentIndex'] as int?,
      formula: json['formula'] as String?,
    );
  }
}

// ─── Dynamic Programming (2D) ──────────────────────────────────────────────────

/// Step for 2D DP problems.
/// Used for template type: dp_2d.
final class Dp2DStep extends VisualizationStep {
  final List<List<int>> table;
  final int? currentRow;
  final int? currentCol;
  final String? formula; // e.g., "dp[i][j] = dp[i-1][j] + dp[i][j-1]"

  const Dp2DStep({
    required super.description,
    required this.table,
    this.currentRow,
    this.currentCol,
    this.formula,
  });

  factory Dp2DStep.fromJson(Map<String, dynamic> json) {
    final rawTable = json['table'] as List? ?? [];
    final table = rawTable
        .map((row) => (row as List).cast<int>().toList())
        .toList();

    return Dp2DStep(
      description: json['description'] as String? ?? '',
      table: table,
      currentRow: json['currentRow'] as int?,
      currentCol: json['currentCol'] as int?,
      formula: json['formula'] as String?,
    );
  }
}

// ─── Heap ─────────────────────────────────────────────────────────────────────

/// Single node in a heap (for tree visualization).
final class VisHeapNode {
  final int id;
  final int value;
  final int? leftId;
  final int? rightId;

  const VisHeapNode({
    required this.id,
    required this.value,
    this.leftId,
    this.rightId,
  });

  factory VisHeapNode.fromJson(Map<String, dynamic> json) {
    return VisHeapNode(
      id: json['id'] as int? ?? 0,
      value: json['value'] as int? ?? 0,
      leftId: json['leftId'] as int?,
      rightId: json['rightId'] as int?,
    );
  }
}

/// Step for heap problems (min-heap / max-heap).
/// Used for template type: heap.
final class HeapStep extends VisualizationStep {
  final List<int> arrayView; // flat array representation [parent, left, right, ...]
  final List<VisHeapNode> nodes; // tree node representation for layout
  final int? highlightedIndex; // which element is being compared/swapped

  const HeapStep({
    required super.description,
    required this.arrayView,
    required this.nodes,
    this.highlightedIndex,
  });

  factory HeapStep.fromJson(Map<String, dynamic> json) {
    final rawArray = json['arrayView'] as List? ?? [];
    final rawNodes = json['nodes'] as List? ?? [];

    final nodes = rawNodes
        .map((n) => VisHeapNode.fromJson(n as Map<String, dynamic>))
        .toList();

    return HeapStep(
      description: json['description'] as String? ?? '',
      arrayView: rawArray.cast<int>(),
      nodes: nodes,
      highlightedIndex: json['highlightedIndex'] as int?,
    );
  }
}
