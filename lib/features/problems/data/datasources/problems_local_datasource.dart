import 'package:hive_flutter/hive_flutter.dart';
import '../models/problem_model.dart';

/// Local cache for problem details using Hive.
/// Mirrors leetcode-bot's problem_cache.json behavior.
class ProblemsLocalDataSource {
  final Box<Map> _box;

  ProblemsLocalDataSource({required Box<Map> box}) : _box = box;

  Problem? getCachedProblem(String slug) {
    final data = _box.get(slug);
    if (data == null) return null;
    return Problem.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> cacheProblem(String slug, Problem problem) async {
    await _box.put(slug, problem.toJson());
  }

  bool hasProblem(String slug) => _box.containsKey(slug);

  Future<void> clearCache() async => _box.clear();
}
