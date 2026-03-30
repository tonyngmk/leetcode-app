import '../../domain/repositories/problems_repository.dart';
import '../datasources/problems_remote_datasource.dart';
import '../datasources/problems_local_datasource.dart';
import '../models/problem_model.dart';
import '../models/problem_list_item_model.dart';
import '../models/daily_challenge_model.dart';

class ProblemsRepositoryImpl implements ProblemsRepository {
  final ProblemsRemoteDataSource _remote;
  final ProblemsLocalDataSource _local;

  ProblemsRepositoryImpl({
    required ProblemsRemoteDataSource remote,
    required ProblemsLocalDataSource local,
  })  : _remote = remote,
        _local = local;

  @override
  Future<ProblemListResponse> getProblems({
    String? difficulty,
    List<String>? tags,
    int limit = 20,
    int skip = 0,
  }) {
    return _remote.getProblems(
      difficulty: difficulty,
      tags: tags,
      limit: limit,
      skip: skip,
    );
  }

  @override
  Future<Problem> getProblemDetail(String slug) async {
    // Cache-first strategy (mirrors bot's _get_cached_problem)
    final cached = _local.getCachedProblem(slug);
    if (cached != null && cached.content != null) return cached;

    final problem = await _remote.getProblemDetail(slug);
    await _local.cacheProblem(slug, problem);
    return problem;
  }

  @override
  Future<DailyChallenge> getDailyChallenge() {
    return _remote.getDailyChallenge();
  }

  @override
  Future<String?> getProblemStatus(String slug) {
    return _remote.getProblemStatus(slug);
  }

  @override
  Future<Map<String, String?>> getProblemsStatusBatch(List<String> slugs) {
    return _remote.getProblemsStatusBatch(slugs);
  }
}
