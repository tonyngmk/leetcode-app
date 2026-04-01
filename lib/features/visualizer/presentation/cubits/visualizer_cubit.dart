import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/visualization_repository.dart';
import '../../domain/visualization_step.dart';

// ─── States ───────────────────────────────────────────────────────────────────

sealed class VisualizerState {}

/// Steps are being loaded from the repository.
final class VisualizerLoading extends VisualizerState {}

/// No visualisation exists for this problem slug.
final class VisualizerUnsupported extends VisualizerState {}

/// Steps loaded and ready for navigation.
final class VisualizerReady extends VisualizerState {
  final List<VisualizationStep> steps;
  final int currentIndex;
  final bool isPlaying;

  VisualizerReady({
    required this.steps,
    this.currentIndex = 0,
    this.isPlaying = false,
  });

  bool get isAtStart => currentIndex == 0;
  bool get isAtEnd => currentIndex == steps.length - 1;
  VisualizationStep get currentStep => steps[currentIndex];

  VisualizerReady copyWith({
    List<VisualizationStep>? steps,
    int? currentIndex,
    bool? isPlaying,
  }) {
    return VisualizerReady(
      steps: steps ?? this.steps,
      currentIndex: currentIndex ?? this.currentIndex,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }
}

// ─── Cubit ────────────────────────────────────────────────────────────────────

/// Manages step-by-step algorithm visualisation.
/// Fetches steps from [VisualizationRepository] on [loadForSlug].
class VisualizerCubit extends Cubit<VisualizerState> {
  static const _autoPlayInterval = Duration(milliseconds: 900);

  final VisualizationRepository _repository;
  Timer? _timer;

  VisualizerCubit(this._repository) : super(VisualizerLoading());

  // ── Loading ─────────────────────────────────────────────────────────────────

  /// Load steps for [slug] at [approachIndex] from the repository.
  /// Emits [VisualizerLoading] → [VisualizerReady] or [VisualizerUnsupported].
  Future<void> loadForSlug(String slug, int approachIndex) async {
    _stopTimer();
    emit(VisualizerLoading());

    final viz = await _repository.getVisualization(slug);
    if (viz == null || !viz.supported) {
      emit(VisualizerUnsupported());
      return;
    }

    final steps = viz.stepsForApproach(approachIndex);
    if (steps.isEmpty) {
      emit(VisualizerUnsupported());
      return;
    }

    emit(VisualizerReady(steps: steps));
  }

  // ── Navigation ──────────────────────────────────────────────────────────────

  void next() {
    final s = state;
    if (s is! VisualizerReady || s.isAtEnd) return;
    emit(s.copyWith(currentIndex: s.currentIndex + 1));
  }

  void prev() {
    final s = state;
    if (s is! VisualizerReady || s.isAtStart) return;
    emit(s.copyWith(currentIndex: s.currentIndex - 1));
  }

  void reset() {
    final s = state;
    if (s is! VisualizerReady) return;
    _stopTimer();
    emit(s.copyWith(currentIndex: 0, isPlaying: false));
  }

  // ── Playback ────────────────────────────────────────────────────────────────

  void play() {
    var s = state;
    if (s is! VisualizerReady) return;
    // Restart from beginning if already at the last step.
    if (s.isAtEnd) s = s.copyWith(currentIndex: 0);
    emit(s.copyWith(isPlaying: true));
    _startTimer();
  }

  void pause() {
    final s = state;
    if (s is! VisualizerReady) return;
    _stopTimer();
    emit(s.copyWith(isPlaying: false));
  }

  void togglePlayPause() {
    final s = state;
    if (s is! VisualizerReady) return;
    s.isPlaying ? pause() : play();
  }

  // ── Internal ─────────────────────────────────────────────────────────────────

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(_autoPlayInterval, (_) {
      final s = state;
      if (s is! VisualizerReady) {
        _stopTimer();
      } else if (s.isAtEnd) {
        pause();
      } else {
        next();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Future<void> close() {
    _stopTimer();
    return super.close();
  }
}
