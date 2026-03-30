import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';
import '../datasources/profile_local_datasource.dart';
import '../models/user_profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remote;
  final ProfileLocalDataSource _local;

  ProfileRepositoryImpl({
    required ProfileRemoteDataSource remote,
    required ProfileLocalDataSource local,
  })  : _remote = remote,
        _local = local;

  @override
  Future<UserProfile> getUserProfile(String username) =>
      _remote.getUserProfile(username);

  @override
  Future<List<AcSubmission>> getRecentAcSubmissions(String username, {int limit = 200}) =>
      _remote.getRecentAcSubmissions(username, limit: limit);

  @override
  Future<String?> validateCredentials() => _remote.validateCredentials();

  @override
  String? get savedUsername => _local.savedUsername;

  @override
  Future<void> saveUsername(String username) => _local.saveUsername(username);

  @override
  List<String> get bookmarkedSlugs => _local.bookmarkedSlugs;

  @override
  Future<void> toggleBookmark(String slug) => _local.toggleBookmark(slug);

  @override
  bool isBookmarked(String slug) => _local.isBookmarked(slug);

  @override
  Future<void> saveSnapshot(String dateStr, Map<String, int> counts) =>
      _local.saveSnapshot(dateStr, counts);

  @override
  Map<String, int>? getSnapshot(String dateStr) => _local.getSnapshot(dateStr);

  @override
  List<String> get recentSearches => _local.recentSearches;

  @override
  Future<void> addRecentSearch(String query) => _local.addRecentSearch(query);

  @override
  Future<void> removeRecentSearch(String query) => _local.removeRecentSearch(query);
}
