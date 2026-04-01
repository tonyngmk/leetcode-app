import 'dart:io';
import 'dart:convert';

/// Merges generated visualization steps into the cache JSON file.
abstract class CacheWriter {
  static const _cacheFile = 'assets/visualization_cache.json';

  /// Writes a single problem's visualization to the cache.
  /// Merges with existing cache (does not overwrite entire file).
  static Future<void> write({
    required String slug,
    required String templateType,
    required List<Map<String, dynamic>> approaches,
    bool dryRun = false,
  }) async {
    // Load existing cache
    Map<String, dynamic> cache = {};
    final cacheFileObj = File(_cacheFile);
    if (await cacheFileObj.exists()) {
      final content = await cacheFileObj.readAsString();
      cache = jsonDecode(content) as Map<String, dynamic>;
    }

    // Build entry for this problem
    final entry = {
      'type': templateType,
      'supported': true,
      'approaches': approaches,
    };

    // Merge into cache
    cache[slug] = entry;

    if (!dryRun) {
      // Write updated cache
      await cacheFileObj.writeAsString(
        jsonEncode(cache),
        flush: true,
      );
    }
  }
}
