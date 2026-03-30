import 'package:flutter_bloc/flutter_bloc.dart';
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

// --- Cubit ---

class JudgeCubit extends Cubit<JudgeState> {
  final JudgeRepository _repository;

  JudgeCubit({required JudgeRepository repository})
      : _repository = repository,
        super(JudgeIdle());

  Future<void> testSolution({
    required String slug,
    required String questionId,
    required String lang,
    required String code,
    String dataInput = '',
  }) async {
    emit(JudgeTesting());
    try {
      final result = await _repository.testSolution(
        slug: slug,
        questionId: questionId,
        lang: lang,
        code: code,
        dataInput: dataInput,
      );
      emit(JudgeTestResult(result));
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
    try {
      final result = await _repository.submitSolution(
        slug: slug,
        questionId: questionId,
        lang: lang,
        code: code,
      );
      emit(JudgeSubmitResult(result));
    } catch (e) {
      emit(JudgeError(e.toString()));
    }
  }

  void reset() => emit(JudgeIdle());
}
