import '../../domain/repositories/judge_repository.dart';
import '../datasources/judge_remote_datasource.dart';
import '../models/submission_result_model.dart';

class JudgeRepositoryImpl implements JudgeRepository {
  final JudgeRemoteDataSource _remote;

  JudgeRepositoryImpl({required JudgeRemoteDataSource remote}) : _remote = remote;

  @override
  Future<SubmissionResult> testSolution({
    required String slug,
    required String questionId,
    required String lang,
    required String code,
    String dataInput = '',
  }) async {
    final interpretId = await _remote.interpretSolution(
      slug: slug,
      questionId: questionId,
      lang: lang,
      code: code,
      dataInput: dataInput,
    );
    return _remote.checkResult(interpretId);
  }

  @override
  Future<SubmissionResult> submitSolution({
    required String slug,
    required String questionId,
    required String lang,
    required String code,
  }) async {
    final submissionId = await _remote.submitSolution(
      slug: slug,
      questionId: questionId,
      lang: lang,
      code: code,
    );
    return _remote.checkResult(submissionId);
  }
}
