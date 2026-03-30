import 'package:hive_flutter/hive_flutter.dart';

/// Local storage for user data, snapshots, bookmarks.
class ProfileLocalDataSource {
  final Box<dynamic> _box;

  ProfileLocalDataSource({required Box<dynamic> box}) : _box = box;

  // Username
  String? get savedUsername => _box.get('username') as String?;
  Future<void> saveUsername(String username) => _box.put('username', username);

  // Bookmarked problems
  List<String> get bookmarkedSlugs {
    final list = _box.get('bookmarks');
    if (list is List) return list.cast<String>();
    return [];
  }

  Future<void> toggleBookmark(String slug) async {
    final bookmarks = bookmarkedSlugs.toList();
    if (bookmarks.contains(slug)) {
      bookmarks.remove(slug);
    } else {
      bookmarks.add(slug);
    }
    await _box.put('bookmarks', bookmarks);
  }

  bool isBookmarked(String slug) => bookmarkedSlugs.contains(slug);

  // Snapshots (daily baseline)
  Future<void> saveSnapshot(String dateStr, Map<String, int> counts) async {
    await _box.put('snapshot_$dateStr', counts);
  }

  Map<String, int>? getSnapshot(String dateStr) {
    final data = _box.get('snapshot_$dateStr');
    if (data is Map) return Map<String, int>.from(data);
    return null;
  }

  // Recent searches
  List<String> get recentSearches {
    final list = _box.get('recent_searches');
    if (list is List) return list.cast<String>();
    return [];
  }

  Future<void> addRecentSearch(String query) async {
    final searches = recentSearches.toList();
    searches.remove(query);
    searches.insert(0, query);
    if (searches.length > 10) searches.removeLast();
    await _box.put('recent_searches', searches);
  }

  Future<void> removeRecentSearch(String query) async {
    final searches = recentSearches.toList();
    searches.remove(query);
    await _box.put('recent_searches', searches);
  }

  Future<void> clearRecentSearches() => _box.delete('recent_searches');
}
