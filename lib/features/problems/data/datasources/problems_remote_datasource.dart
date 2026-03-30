import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/problem_model.dart';
import '../models/problem_list_item_model.dart';
import '../models/daily_challenge_model.dart';

/// Remote data source for LeetCode problems — ports from leetcode-bot/leetcode.py.
class ProblemsRemoteDataSource {
  final DioClient _dioClient;

  ProblemsRemoteDataSource({required DioClient dioClient}) : _dioClient = dioClient;

  /// Fetches paginated problem list with optional filters.
  /// Port of fetch_problems() from leetcode.py L749.
  Future<ProblemListResponse> getProblems({
    String? difficulty,
    List<String>? tags,
    int limit = 20,
    int skip = 0,
  }) async {
    final filters = <String, dynamic>{};
    if (difficulty != null) filters['difficulty'] = difficulty.toUpperCase();
    if (tags != null && tags.isNotEmpty) {
      filters['tags'] = tags.map((t) => t.toLowerCase().replaceAll(' ', '-')).toList();
    }

    final data = await _dioClient.graphql(
      ApiConstants.problemsQuery,
      variables: {
        'categorySlug': '',
        'limit': limit,
        'skip': skip,
        'filters': filters,
      },
    );
    return ProblemListResponse.fromJson(data);
  }

  /// Fetches full problem detail by slug.
  /// Port of fetch_problem() from leetcode.py L787.
  Future<Problem> getProblemDetail(String slug) async {
    final data = await _dioClient.graphql(
      ApiConstants.problemDetailQuery,
      variables: {'titleSlug': slug},
    );
    return Problem.fromJson(data['question'] as Map<String, dynamic>);
  }

  /// Fetches today's daily coding challenge.
  /// Port of fetch_daily_challenge() from leetcode.py L823.
  Future<DailyChallenge> getDailyChallenge() async {
    final data = await _dioClient.graphql(ApiConstants.dailyChallengeQuery);
    return DailyChallenge.fromJson(data);
  }

  /// Fetches user's solve status for a problem (requires auth).
  /// Port of fetch_problem_status() from leetcode.py L883.
  Future<String?> getProblemStatus(String slug) async {
    final data = await _dioClient.graphqlAuth(
      ApiConstants.problemStatusQuery,
      variables: {'titleSlug': slug},
    );
    return (data['question'] as Map<String, dynamic>)['status'] as String?;
  }

  /// Batch fetch problem statuses using aliased GraphQL.
  /// Port of fetch_problems_status() from leetcode.py L909.
  Future<Map<String, String?>> getProblemsStatusBatch(List<String> slugs) async {
    if (slugs.isEmpty) return {};
    final aliases = <String>[];
    for (var i = 0; i < slugs.length; i++) {
      aliases.add('q$i: question(titleSlug: "${slugs[i]}") { status }');
    }
    final query = 'query { ${aliases.join('\n')} }';
    final data = await _dioClient.graphqlAuth(query);

    final result = <String, String?>{};
    for (var i = 0; i < slugs.length; i++) {
      final q = data['q$i'] as Map<String, dynamic>?;
      result[slugs[i]] = q?['status'] as String?;
    }
    return result;
  }
}
