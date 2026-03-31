import 'package:dio/dio.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/submission_result_model.dart';

/// Remote data source for testing and submitting code.
/// Ports from leetcode-bot/leetcode.py: interpret_solution, submit_solution, check_result.
class JudgeRemoteDataSource {
  final DioClient _dioClient;

  JudgeRemoteDataSource({required DioClient dioClient}) : _dioClient = dioClient;

  /// Tests code against example test cases.
  /// Port of interpret_solution() from leetcode.py L944.
  Future<String> interpretSolution({
    required String slug,
    required String questionId,
    required String lang,
    required String code,
    String dataInput = '',
  }) async {
    final response = await _dioClient.dio.post<Map<String, dynamic>>(
      '/problems/$slug/interpret_solution/',
      data: {
        'question_id': questionId,
        'lang': lang,
        'typed_code': code,
        'data_input': dataInput,
      },
      options: Options(
        extra: {'requiresAuth': true},
        // Submission endpoints can be slow — give LeetCode up to 60s.
        sendTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );
    return response.data!['interpret_id'] as String;
  }

  /// Submits code for official judging.
  /// Port of submit_solution() from leetcode.py L979.
  Future<int> submitSolution({
    required String slug,
    required String questionId,
    required String lang,
    required String code,
  }) async {
    final response = await _dioClient.dio.post<Map<String, dynamic>>(
      '/problems/$slug/submit/',
      data: {
        'question_id': questionId,
        'lang': lang,
        'typed_code': code,
      },
      options: Options(
        extra: {'requiresAuth': true},
        // Submission endpoints can be slow — give LeetCode up to 60s.
        sendTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );
    return response.data!['submission_id'] as int;
  }

  /// Polls for submission result until state == SUCCESS.
  /// Port of check_result() from leetcode.py L1012.
  Future<SubmissionResult> checkResult(dynamic submissionId) async {
    for (var i = 0; i < AppConstants.maxPollAttempts; i++) {
      final response = await _dioClient.dio.get<Map<String, dynamic>>(
        '/submissions/detail/$submissionId/check/',
        options: Options(
          extra: {'requiresAuth': true},
          receiveTimeout: const Duration(seconds: 30),
        ),
      );
      final result = SubmissionResult.fromJson(response.data!);
      if (!result.isPending) return result;
      await Future<void>.delayed(
        const Duration(milliseconds: AppConstants.pollIntervalMs),
      );
    }
    return const SubmissionResult(state: 'TIMEOUT', statusMsg: 'Polling timed out');
  }
}
