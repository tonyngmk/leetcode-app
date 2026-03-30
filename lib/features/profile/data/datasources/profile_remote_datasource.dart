import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_profile_model.dart';

/// Remote data source for user profile data.
/// Ports from leetcode-bot/leetcode.py: fetch_user_profile, fetch_recent_ac_submissions, validate_credentials.
class ProfileRemoteDataSource {
  final DioClient _dioClient;

  ProfileRemoteDataSource({required DioClient dioClient}) : _dioClient = dioClient;

  /// Port of fetch_user_profile() from leetcode.py L148.
  Future<UserProfile> getUserProfile(String username) async {
    final data = await _dioClient.graphql(
      ApiConstants.userProfileQuery,
      variables: {'username': username},
    );
    return UserProfile.fromJson(data);
  }

  /// Port of fetch_recent_ac_submissions() from leetcode.py L185.
  Future<List<AcSubmission>> getRecentAcSubmissions(String username, {int limit = 200}) async {
    final data = await _dioClient.graphql(
      ApiConstants.recentAcSubmissionsQuery,
      variables: {'username': username, 'limit': limit},
    );
    final list = data['recentAcSubmissionList'] as List;
    return list.map((s) => AcSubmission.fromJson(s as Map<String, dynamic>)).toList();
  }

  /// Port of validate_credentials() from leetcode.py L859.
  Future<String?> validateCredentials() async {
    try {
      final data = await _dioClient.graphqlAuth(ApiConstants.globalDataQuery);
      final status = data['userStatus'] as Map<String, dynamic>;
      if (status['isSignedIn'] == true) {
        return status['username'] as String?;
      }
    } catch (_) {}
    return null;
  }
}
