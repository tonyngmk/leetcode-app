import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/problem_model.dart';
import '../../domain/repositories/problems_repository.dart';
import '../../../solutions/data/models/solution_model.dart';
import '../../../solutions/domain/repositories/solutions_repository.dart';

// --- States ---

sealed class ProblemDetailState {}

class ProblemDetailLoading extends ProblemDetailState {}

class ProblemDetailLoaded extends ProblemDetailState {
  final Problem problem;
  final Solution? solution;
  final String? solveStatus; // "ac", "notac", or null

  ProblemDetailLoaded({
    required this.problem,
    this.solution,
    this.solveStatus,
  });
}

class ProblemDetailError extends ProblemDetailState {
  final String message;
  ProblemDetailError(this.message);
}

// --- Cubit ---

class ProblemDetailCubit extends Cubit<ProblemDetailState> {
  final ProblemsRepository _problemsRepo;
  final SolutionsRepository _solutionsRepo;

  ProblemDetailCubit({
    required ProblemsRepository problemsRepo,
    required SolutionsRepository solutionsRepo,
  })  : _problemsRepo = problemsRepo,
        _solutionsRepo = solutionsRepo,
        super(ProblemDetailLoading());

  Future<void> load(String slug) async {
    emit(ProblemDetailLoading());
    try {
      final problem = await _problemsRepo.getProblemDetail(slug);
      final solution = _solutionsRepo.getSolution(slug);

      // Try to get solve status (requires auth, may fail silently)
      String? status;
      try {
        status = await _problemsRepo.getProblemStatus(slug);
      } catch (_) {}

      emit(ProblemDetailLoaded(
        problem: problem,
        solution: solution,
        solveStatus: status,
      ));
    } catch (e) {
      emit(ProblemDetailError(e.toString()));
    }
  }
}
