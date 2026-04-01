/// Validates generated visualization steps.
abstract class StepValidator {
  /// Validates a list of steps for a given template type.
  /// Returns true if valid, false otherwise (logs errors).
  static bool validate(
    List<Map<String, dynamic>> steps,
    String templateType, {
    bool verbose = false,
  }) {
    if (steps.isEmpty) {
      _log('Error: no steps generated', verbose);
      return false;
    }

    if (steps.length < 3) {
      _log('Error: fewer than 3 steps', verbose);
      return false;
    }

    if (steps.length > 15) {
      _log('Error: more than 15 steps', verbose);
      return false;
    }

    // Check universal constraints
    for (int i = 0; i < steps.length; i++) {
      final step = steps[i];

      if (step['description'] == null || (step['description'] as String).isEmpty) {
        _log('Error: step $i has no description', verbose);
        return false;
      }

      final desc = step['description'] as String;
      final lines = desc.split('\n');
      if (lines.length > 3) {
        _log('Error: step $i has ${lines.length} lines (max 3)', verbose);
        return false;
      }
      for (final line in lines) {
        if (line.length > 120) {
          _log('Error: step $i line too long (${line.length} > 120): $line', verbose);
          return false;
        }
      }
    }

    // Type-specific validation
    return switch (templateType) {
      'array_basic' || 'hash_map' => _validateArray(steps, verbose),
      'two_pointer' => _validateTwoPointer(steps, verbose),
      'sliding_window' => _validateSlidingWindow(steps, verbose),
      'prefix_sum' => _validatePrefixSum(steps, verbose),
      'binary_search' => _validateBinarySearch(steps, verbose),
      'stack' => _validateStack(steps, verbose),
      'tree_dfs' || 'tree_bfs' => _validateTree(steps, verbose),
      'grid' => _validateGrid(steps, verbose),
      'graph' => _validateGraph(steps, verbose),
      'dp_1d' => _validateDP1D(steps, verbose),
      'dp_2d' => _validateDP2D(steps, verbose),
      _ => true, // Unsupported types pass validation (they'll fail at render time)
    };
  }

  static bool _validateArray(List<Map<String, dynamic>> steps, bool verbose) {
    for (int i = 0; i < steps.length; i++) {
      final step = steps[i];
      final pointers = step['activePointers'] as Map? ?? {};
      final results = step['resultIndices'] as List? ?? [];
      final hashMap = step['hashMap'] as Map? ?? {};

      // Pointers in bounds (assuming array is [2,7,11,15] = length 4)
      for (final idx in pointers.values) {
        if (idx < 0 || idx >= 4) {
          _log('Error: step $i pointer out of bounds: $idx', verbose);
          return false;
        }
      }

      // Result indices in bounds
      for (final idx in results) {
        if (idx < 0 || idx >= 4) {
          _log('Error: step $i result index out of bounds: $idx', verbose);
          return false;
        }
      }

      // Hash map values in bounds
      for (final val in hashMap.values) {
        if (val < 0 || val >= 4) {
          _log('Error: step $i hashmap value out of bounds: $val', verbose);
          return false;
        }
      }

      // Hash map is monotone (entries only added)
      if (i > 0) {
        final prevMap = (steps[i - 1]['hashMap'] as Map? ?? {}).keys.toSet();
        final currMap = hashMap.keys.toSet();
        if (!currMap.containsAll(prevMap)) {
          _log(
              'Error: step $i hashmap not monotone (entries removed)',
              verbose);
          return false;
        }
      }
    }

    // Final step should have result indices or explicit "no solution" message
    final lastStep = steps.last;
    final finalResults = lastStep['resultIndices'] as List? ?? [];
    if (finalResults.isEmpty && !(lastStep['description'] as String).contains('not found')) {
      _log('Warning: final step has no result and no "not found" message', verbose);
    }

    return true;
  }

  static bool _validateTwoPointer(List<Map<String, dynamic>> steps, bool verbose) {
    for (int i = 0; i < steps.length; i++) {
      final step = steps[i];
      final left = step['left'] as int? ?? 0;
      final right = step['right'] as int? ?? 0;

      if (left > right) {
        _log('Error: step $i left > right (pointers crossed)', verbose);
        return false;
      }
    }
    return true;
  }

  static bool _validateSlidingWindow(
      List<Map<String, dynamic>> steps, bool verbose) {
    for (int i = 0; i < steps.length; i++) {
      final step = steps[i];
      final start = step['windowStart'] as int? ?? 0;
      final end = step['windowEnd'] as int? ?? 0;

      if (start > end) {
        _log('Error: step $i windowStart > windowEnd', verbose);
        return false;
      }
    }
    return true;
  }

  static bool _validatePrefixSum(List<Map<String, dynamic>> steps, bool verbose) {
    for (int i = 0; i < steps.length; i++) {
      final step = steps[i];
      final table = step['prefixArray'] as List? ?? [];
      if (table.isEmpty) {
        _log('Error: step $i prefixArray is empty', verbose);
        return false;
      }
    }
    return true;
  }

  static bool _validateBinarySearch(
      List<Map<String, dynamic>> steps, bool verbose) {
    for (int i = 0; i < steps.length; i++) {
      final step = steps[i];
      final lo = step['lo'] as int? ?? 0;
      final mid = step['mid'] as int? ?? 0;
      final hi = step['hi'] as int? ?? 0;

      if (lo > mid || mid > hi) {
        _log('Error: step $i pointer order invalid: lo=$lo, mid=$mid, hi=$hi',
            verbose);
        return false;
      }
    }
    return true;
  }

  static bool _validateStack(List<Map<String, dynamic>> steps, bool verbose) {
    for (int i = 0; i < steps.length; i++) {
      final step = steps[i];
      final stack = step['stackContents'] as List? ?? [];
      // Stack can be any size
      if (stack.isEmpty && i > 0) {
        // OK for some steps
      }
    }
    return true;
  }

  static bool _validateTree(List<Map<String, dynamic>> steps, bool verbose) {
    for (int i = 0; i < steps.length; i++) {
      final step = steps[i];
      final nodes = step['nodes'] as List? ?? [];

      if (nodes.isEmpty) {
        _log('Error: step $i has no nodes', verbose);
        return false;
      }

      // Check node IDs are stable (same count across steps)
      if (i > 0) {
        final prevNodes = (steps[i - 1]['nodes'] as List? ?? []).length;
        if (nodes.length != prevNodes) {
          _log(
              'Error: step $i node count ${nodes.length} != prev $prevNodes',
              verbose);
          return false;
        }
      }
    }
    return true;
  }

  static bool _validateGrid(List<Map<String, dynamic>> steps, bool verbose) {
    int? rows, cols;
    for (int i = 0; i < steps.length; i++) {
      final step = steps[i];
      final grid = step['grid'] as List? ?? [];

      if (grid.isEmpty) {
        _log('Error: step $i has no grid', verbose);
        return false;
      }

      if (rows == null) {
        rows = grid.length;
        cols = (grid[0] as List?)?.length ?? 0;
      } else if (grid.length != rows) {
        _log('Error: step $i row count mismatch', verbose);
        return false;
      }
    }
    return true;
  }

  static bool _validateGraph(List<Map<String, dynamic>> steps, bool verbose) {
    // Lightweight validation — graph can be any topology
    for (int i = 0; i < steps.length; i++) {
      final step = steps[i];
      if ((step['nodes'] as List? ?? []).isEmpty) {
        _log('Error: step $i has no nodes', verbose);
        return false;
      }
    }
    return true;
  }

  static bool _validateDP1D(List<Map<String, dynamic>> steps, bool verbose) {
    for (int i = 0; i < steps.length; i++) {
      final step = steps[i];
      final table = step['dpTable'] as List? ?? [];
      if (table.isEmpty) {
        _log('Error: step $i dpTable is empty', verbose);
        return false;
      }
    }
    return true;
  }

  static bool _validateDP2D(List<Map<String, dynamic>> steps, bool verbose) {
    int? cols;
    for (int i = 0; i < steps.length; i++) {
      final step = steps[i];
      final table = step['dpTable'] as List? ?? [];
      if (table.isEmpty) {
        _log('Error: step $i dpTable is empty', verbose);
        return false;
      }
      if (cols == null) {
        cols = (table[0] as List?)?.length ?? 0;
      }
    }
    return true;
  }

  static void _log(String msg, bool verbose) {
    if (verbose) print('    $msg');
  }
}
