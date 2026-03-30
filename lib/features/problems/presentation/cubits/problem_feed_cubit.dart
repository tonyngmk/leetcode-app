import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/problem_list_item_model.dart';
import '../../data/models/daily_challenge_model.dart';
import '../../domain/repositories/problems_repository.dart';

// --- States ---

sealed class ProblemFeedState {}

class ProblemFeedLoading extends ProblemFeedState {}

class ProblemFeedLoaded extends ProblemFeedState {
  final List<ProblemListItem> problems;
  final int total;
  final int currentPage;
  final String? activeDifficulty;
  final String? activeTag;
  final DailyChallenge? dailyChallenge;
  final bool isLoadingMore;

  ProblemFeedLoaded({
    required this.problems,
    required this.total,
    this.currentPage = 0,
    this.activeDifficulty,
    this.activeTag,
    this.dailyChallenge,
    this.isLoadingMore = false,
  });

  ProblemFeedLoaded copyWith({
    List<ProblemListItem>? problems,
    int? total,
    int? currentPage,
    String? Function()? activeDifficulty,
    String? Function()? activeTag,
    DailyChallenge? dailyChallenge,
    bool? isLoadingMore,
  }) {
    return ProblemFeedLoaded(
      problems: problems ?? this.problems,
      total: total ?? this.total,
      currentPage: currentPage ?? this.currentPage,
      activeDifficulty: activeDifficulty != null ? activeDifficulty() : this.activeDifficulty,
      activeTag: activeTag != null ? activeTag() : this.activeTag,
      dailyChallenge: dailyChallenge ?? this.dailyChallenge,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class ProblemFeedError extends ProblemFeedState {
  final String message;
  ProblemFeedError(this.message);
}

// --- Cubit ---

class ProblemFeedCubit extends Cubit<ProblemFeedState> {
  final ProblemsRepository _repository;
  static const _pageSize = 20;

  ProblemFeedCubit({required ProblemsRepository repository})
      : _repository = repository,
        super(ProblemFeedLoading());

  Future<void> load() async {
    emit(ProblemFeedLoading());
    try {
      final results = await Future.wait([
        _repository.getProblems(limit: _pageSize, skip: 0),
        _repository.getDailyChallenge(),
      ]);
      final response = results[0] as ProblemListResponse;
      final daily = results[1] as DailyChallenge;
      emit(ProblemFeedLoaded(
        problems: response.questions,
        total: response.total,
        dailyChallenge: daily,
      ));
    } catch (e) {
      emit(ProblemFeedError(e.toString()));
    }
  }

  Future<void> filterByDifficulty(String? difficulty) async {
    final current = state;
    if (current is! ProblemFeedLoaded) return;
    emit(ProblemFeedLoading());
    try {
      final response = await _repository.getProblems(
        difficulty: difficulty,
        tags: current.activeTag != null ? [current.activeTag!] : null,
        limit: _pageSize,
        skip: 0,
      );
      emit(ProblemFeedLoaded(
        problems: response.questions,
        total: response.total,
        activeDifficulty: difficulty,
        activeTag: current.activeTag,
        dailyChallenge: current.dailyChallenge,
      ));
    } catch (e) {
      emit(ProblemFeedError(e.toString()));
    }
  }

  Future<void> filterByTag(String? tag) async {
    final current = state;
    if (current is! ProblemFeedLoaded) return;
    emit(ProblemFeedLoading());
    try {
      final response = await _repository.getProblems(
        difficulty: current.activeDifficulty,
        tags: tag != null ? [tag] : null,
        limit: _pageSize,
        skip: 0,
      );
      emit(ProblemFeedLoaded(
        problems: response.questions,
        total: response.total,
        activeDifficulty: current.activeDifficulty,
        activeTag: tag,
        dailyChallenge: current.dailyChallenge,
      ));
    } catch (e) {
      emit(ProblemFeedError(e.toString()));
    }
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! ProblemFeedLoaded || current.isLoadingMore) return;
    if (current.problems.length >= current.total) return;

    emit(current.copyWith(isLoadingMore: true));
    try {
      final response = await _repository.getProblems(
        difficulty: current.activeDifficulty,
        tags: current.activeTag != null ? [current.activeTag!] : null,
        limit: _pageSize,
        skip: current.problems.length,
      );
      emit(current.copyWith(
        problems: [...current.problems, ...response.questions],
        total: response.total,
        currentPage: current.currentPage + 1,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(current.copyWith(isLoadingMore: false));
    }
  }

  Future<void> refresh() => load();
}
