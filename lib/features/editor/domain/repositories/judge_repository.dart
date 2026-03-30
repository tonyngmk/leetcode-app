import '../../data/models/submission_result_model.dart';

abstract class JudgeRepository {
  Future<SubmissionResult> testSolution({
    required String slug,
    required String questionId,
    required String lang,
    required String code,
    String dataInput,
  });

  Future<SubmissionResult> submitSolution({
    required String slug,
    required String questionId,
    required String lang,
    required String code,
  });
}
