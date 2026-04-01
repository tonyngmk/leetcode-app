import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/visualization_step.dart';
import 'array_box_widget.dart';

/// Renders the full array for the current [step].
/// Each element is an [ArrayBoxWidget]. Pointer labels appear above
/// active indices derived from [step.activePointers].
class ArrayVisualizerWidget extends StatelessWidget {
  final ArrayStep step;

  const ArrayVisualizerWidget({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    // Build reverse map: index → list of pointer labels
    // (multiple pointers can theoretically point at same index)
    final indexToLabels = <int, List<String>>{};
    for (final entry in step.activePointers.entries) {
      indexToLabels.putIfAbsent(entry.value, () => []).add(entry.key);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (int i = 0; i < step.array.length; i++) ...[
          if (i > 0) const Gap(AppSpacing.s),
          ArrayBoxWidget(
            value: step.array[i],
            pointerLabel: indexToLabels[i]?.join('/'),
            isActive: step.activePointers.containsValue(i),
            isResult: step.resultIndices.contains(i),
          ),
        ],
      ],
    );
  }
}
