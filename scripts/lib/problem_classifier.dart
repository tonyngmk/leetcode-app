/// Classifies problems into template types based on topic tags and slug.
abstract class ProblemClassifier {
  /// Classifies a problem slug into a template type.
  /// Applies heuristics in order of priority.
  static String classify({
    required List<String> topicTags,
    required String slug,
    required String title,
  }) {
    // Convert topic slugs to a set for easy checking
    final tags = topicTags.map((t) => t.toLowerCase()).toSet();

    // 1. Tree problems
    if (slug.contains('tree') || slug.contains('binary-tree') || title.contains('Tree')) {
      return 'tree_dfs'; // default to DFS; override file can change to BFS
    }

    // 2. Binary search
    if (tags.contains('binary-search')) {
      return 'binary_search';
    }

    // 3. Dynamic programming
    if (tags.contains('dynamic-programming')) {
      // Check dimensionality: 1D vs 2D
      if (slug.contains('climbing') || slug.contains('coin') || slug.contains('house')) {
        return 'dp_1d';
      }
      if (slug.contains('edit') ||
          slug.contains('lcs') ||
          slug.contains('distance') ||
          slug.contains('unique-paths')) {
        return 'dp_2d';
      }
      // Default: guess 1D
      return 'dp_1d';
    }

    // 4. Stack
    if (tags.contains('stack')) {
      return 'stack';
    }

    // 5. Graph
    if (tags.contains('graph') || tags.contains('union-find')) {
      return 'graph';
    }

    // 6. Matrix / Grid
    if (tags.contains('matrix') ||
        slug.contains('island') ||
        slug.contains('grid') ||
        slug.contains('matrix')) {
      return 'grid';
    }

    // 7. Sliding window
    if (tags.contains('sliding-window')) {
      return 'sliding_window';
    }

    // 8. Two pointers
    if (tags.contains('two-pointers')) {
      return 'two_pointer';
    }

    // 9. Prefix sum
    if (tags.contains('prefix-sum')) {
      return 'prefix_sum';
    }

    // 10. Hash table / Hash map
    if (tags.contains('hash-table')) {
      return 'hash_map';
    }

    // 11. Array (default for array problems)
    if (tags.contains('array')) {
      return 'array_basic';
    }

    // Default: unsupported
    return 'unsupported';
  }
}
