import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/solution_model.dart';

/// Local data source for cached solutions.
///
/// Loads solution cache lazily on-demand from bundled JSON asset.
/// Does NOT load all 4054 problems at startup — only loads when accessed.
class SolutionsLocalDataSource {
  Map<String, dynamic>? _cache;
  bool _isLoading = false;

  /// Lazily loads the asset and caches it in memory.
  /// Called on first [getSolution] or [hasSolution] call.
  Future<void> _ensureLoaded() async {
    if (_cache != null || _isLoading) return;
    _isLoading = true;
    try {
      final jsonStr = await rootBundle.loadString('assets/solution_cache.json');
      _cache = json.decode(jsonStr) as Map<String, dynamic>;
    } catch (e) {
      // Asset not bundled yet — solutions will be unavailable
      _cache = {};
    } finally {
      _isLoading = false;
    }
  }

  Solution? getSolution(String slug) {
    if (_cache == null) return null;
    final data = _cache![slug] as Map<String, dynamic>?;
    if (data == null) return null;
    return Solution.fromJson(data);
  }

  Future<Solution?> getSolutionAsync(String slug) async {
    await _ensureLoaded();
    return getSolution(slug);
  }

  Future<bool> hasSolution(String slug) async {
    await _ensureLoaded();
    return _cache!.containsKey(slug);
  }

  bool get isLoaded => _cache != null;
}
