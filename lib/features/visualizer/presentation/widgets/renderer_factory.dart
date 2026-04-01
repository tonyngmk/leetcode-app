import 'package:flutter/material.dart';
import '../../domain/visualization_step.dart';
import 'array_visualizer_widget.dart';
import 'binary_search_visualizer_widget.dart';
import 'dp_1d_visualizer_widget.dart';
import 'dp_2d_visualizer_widget.dart';
import 'graph_visualizer_widget.dart';
import 'grid_visualizer_widget.dart';
import 'hash_map_visualizer_widget.dart';
import 'heap_visualizer_widget.dart';
import 'prefix_sum_visualizer_widget.dart';
import 'queue_visualizer_widget.dart';
import 'sliding_window_visualizer_widget.dart';
import 'stack_visualizer_widget.dart';
import 'tree_visualizer_widget.dart';
import 'two_pointer_visualizer_widget.dart';

/// Picks the correct visualisation widget for a given [VisualizationStep].
///
/// Two entry points:
/// - [buildVisual] — the primary data-structure widget (array row, tree, etc.)
/// - [buildAuxiliary] — optional secondary widget (hash map panel, etc.)
///   Returns null when no auxiliary is needed for this step.
class RendererFactory {
  RendererFactory._();

  /// Primary visualisation widget for [step].
  static Widget buildVisual(VisualizationStep step) {
    return switch (step) {
      ArrayStep s => ArrayVisualizerWidget(step: s),
      TwoPointerStep s => TwoPointerVisualizerWidget(step: s),
      SlidingWindowStep s => SlidingWindowVisualizerWidget(step: s),
      PrefixSumStep s => PrefixSumVisualizerWidget(
        originalArray: s.array,
        prefixArray: s.prefixArray,
        currentIndex: s.currentIndex ?? 0,
      ),
      BinarySearchStep s => BinarySearchVisualizerWidget(
        array: s.array,
        lo: s.lo,
        mid: s.mid,
        hi: s.hi,
        eliminatedLeft: s.eliminatedLeft,
        eliminatedRight: s.eliminatedRight,
      ),
      TreeStep s => TreeVisualizerWidget(step: s),
      GridStep s => GridVisualizerWidget(step: s),
      GraphStep s => GraphVisualizerWidget(step: s),
      StackStep s => StackVisualizerWidget(step: s),
      QueueStep s => QueueVisualizerWidget(step: s),
      Dp1DStep s => Dp1DVisualizerWidget(step: s),
      Dp2DStep s => Dp2DVisualizerWidget(step: s),
      HeapStep s => HeapVisualizerWidget(step: s),
    };
  }

  /// Optional auxiliary widget (e.g. hash map panel) shown below the primary.
  /// Returns null if this step type has no auxiliary display.
  static Widget? buildAuxiliary(
    VisualizationStep current,
    VisualizationStep? previous,
  ) {
    return switch (current) {
      ArrayStep s => s.hashMap.isNotEmpty
          ? HashMapVisualizerWidget(
              hashMap: s.hashMap,
              previousKeys: previous is ArrayStep
                  ? previous.hashMap.keys.toSet()
                  : const <int>{},
            )
          : null,
      _ => null, // Other types don't have auxiliary widgets yet
    };
  }
}
