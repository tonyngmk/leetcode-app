import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/problem_visualization.dart';

/// Local data source for algorithm visualisation steps.
///
/// Lazy-loads visualization_cache.json on first access.
/// Mirrors the pattern of [SolutionsLocalDataSource].
class VisualizationLocalDataSource {
  Map<String, dynamic>? _cache;

  Future<void> _ensureLoaded() async {
    if (_cache != null) return;
    try {
      final jsonStr =
          await rootBundle.loadString('assets/visualization_cache.json');
      _cache = json.decode(jsonStr) as Map<String, dynamic>;
    } catch (_) {
      // Asset missing or malformed — visualisations unavailable.
      _cache = {};
    }
  }

  Future<bool> hasVisualization(String slug) async {
    await _ensureLoaded();
    return _cache!.containsKey(slug);
  }

  Future<ProblemVisualization?> getVisualization(String slug) async {
    await _ensureLoaded();
    final data = _cache![slug] as Map<String, dynamic>?;
    if (data == null) return null;
    return ProblemVisualization.fromJson(slug, data);
  }
}
