import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/solution_model.dart';

/// Local data source for cached solutions.
/// On first launch, loads from bundled asset (solution_cache.json.gz).
class SolutionsLocalDataSource {
  final Box<Map> _box;

  SolutionsLocalDataSource({required Box<Map> box}) : _box = box;

  Solution? getSolution(String slug) {
    final data = _box.get(slug);
    if (data == null) return null;
    return Solution.fromJson(Map<String, dynamic>.from(data));
  }

  bool hasSolution(String slug) => _box.containsKey(slug);

  Future<void> saveSolution(String slug, Solution solution) async {
    await _box.put(slug, solution.toJson());
  }

  bool get isLoaded => _box.isNotEmpty;

  /// Loads all solutions from the bundled JSON asset into Hive.
  /// Called on first launch only.
  Future<void> loadFromAsset() async {
    if (_box.isNotEmpty) return;
    try {
      final jsonStr = await rootBundle.loadString('assets/solution_cache.json');
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      for (final entry in data.entries) {
        final slug = entry.key;
        final solutionData = entry.value as Map<String, dynamic>;
        await _box.put(slug, solutionData);
      }
    } catch (_) {
      // Asset not bundled yet — solutions will be empty until asset is added
    }
  }
}
