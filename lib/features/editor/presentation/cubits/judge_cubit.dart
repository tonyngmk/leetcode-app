import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/auth_interceptor.dart';
import '../../data/models/submission_result_model.dart';
import '../../domain/repositories/judge_repository.dart';

// --- States ---

sealed class JudgeState {}

class JudgeIdle extends JudgeState {}

class JudgeTesting extends JudgeState {}

class JudgeSubmitting extends JudgeState {}

class JudgeTestResult extends JudgeState {
  final SubmissionResult result;
  JudgeTestResult(this.result);
}

class JudgeSubmitResult extends JudgeState {
  final SubmissionResult result;
  JudgeSubmitResult(this.result);
}

class JudgeError extends JudgeState {
  final String message;
  JudgeError(this.message);
}

/// Authentication/session error — distinct from generic errors so the UI
/// can surface a clear "please log in" message instead of a raw error.
class JudgeAuthError extends JudgeState {
  final String message;
  JudgeAuthError(this.message);
}

// --- Cubit ---

class JudgeCubit extends Cubit<JudgeState> {
  final JudgeRepository _repository;
  final AuthInterceptor _authInterceptor;

  JudgeCubit({required JudgeRepository repository, required AuthInterceptor authInterceptor})
      : _repository = repository,
        _authInterceptor = authInterceptor,
        super(JudgeIdle());

  /// Returns true if the user has a valid LeetCode session cookie.
  Future<bool> _ensureAuthenticated() async {
    final hasCreds = await _authInterceptor.hasCredentials();
    return hasCreds;
  }

  Future<void> testSolution({
    required String slug,
    required String questionId,
    required String lang,
    required String code,
    String dataInput = '',
  }) async {
    emit(JudgeTesting());
    if (!await _ensureAuthenticated()) {
      emit(JudgeAuthError('Please sign in to run code. Your session may have expired.'));
      return;
    }
    try {
      final result = await _repository.testSolution(
        slug: slug,
        questionId: questionId,
        lang: lang,
        code: code,
        dataInput: dataInput,
      );
      emit(JudgeTestResult(result));
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      emit(JudgeError(e.toString()));
    }
  }

  Future<void> submitSolution({
    required String slug,
    required String questionId,
    required String lang,
    required String code,
  }) async {
    emit(JudgeSubmitting());
    if (!await _ensureAuthenticated()) {
      emit(JudgeAuthError('Please sign in to submit code. Your session may have expired.'));
      return;
    }
    try {
      final result = await _repository.submitSolution(
        slug: slug,
        questionId: questionId,
        lang: lang,
        code: code,
      );
      emit(JudgeSubmitResult(result));
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      emit(JudgeError(e.toString()));
    }
  }

  /// Handles Dio exceptions and maps 499 (invalid session) to auth error state.
  void _handleDioError(DioException e) {
    final statusCode = e.response?.statusCode;
    if (statusCode == 499 || statusCode == 401 || statusCode == 403) {
      emit(JudgeAuthError(
        'Authentication failed. Please sign in again. '
        '(Error $statusCode — ${e.message ?? 'invalid session'})',
      ));
    } else if (statusCode != null && statusCode >= 400) {
      emit(JudgeError('Server error ($statusCode): ${e.message ?? 'unknown'}'));
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      emit(JudgeError('Request timed out. Please try again.'));
    } else if (e.type == DioExceptionType.connectionError) {
      emit(JudgeError('No internet connection. Please check your network.'));
    } else {
      emit(JudgeError(e.message ?? 'An unexpected error occurred.'));
    }
  }

  void reset() => emit(JudgeIdle());
}
