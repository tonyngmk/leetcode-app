import '../../data/models/user_profile_model.dart';

abstract class ProfileRepository {
  Future<UserProfile> getUserProfile(String username);
  Future<List<AcSubmission>> getRecentAcSubmissions(String username, {int limit});
  Future<String?> validateCredentials();

  String? get savedUsername;
  Future<void> saveUsername(String username);

  List<String> get bookmarkedSlugs;
  Future<void> toggleBookmark(String slug);
  bool isBookmarked(String slug);

  Future<void> saveSnapshot(String dateStr, Map<String, int> counts);
  Map<String, int>? getSnapshot(String dateStr);

  List<String> get recentSearches;
  Future<void> addRecentSearch(String query);
  Future<void> removeRecentSearch(String query);
}
