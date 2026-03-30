import '../../data/models/problem_model.dart';
import '../../data/models/problem_list_item_model.dart';
import '../../data/models/daily_challenge_model.dart';

abstract class ProblemsRepository {
  Future<ProblemListResponse> getProblems({
    String? difficulty,
    List<String>? tags,
    int limit = 20,
    int skip = 0,
  });

  Future<Problem> getProblemDetail(String slug);

  Future<DailyChallenge> getDailyChallenge();

  Future<String?> getProblemStatus(String slug);

  Future<Map<String, String?>> getProblemsStatusBatch(List<String> slugs);
}
