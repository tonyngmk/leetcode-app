import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/visualization_step.dart';
import 'array_box_widget.dart';

/// Renders an array with a highlighted sliding window range.
/// Used for: Longest Substring Without Repeating, Min Size Subarray Sum, etc.
class SlidingWindowVisualizerWidget extends StatelessWidget {
  final SlidingWindowStep step;

  const SlidingWindowVisualizerWidget({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Array with window highlight
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (int i = 0; i < step.array.length; i++) ...[
                if (i > 0) const Gap(AppSpacing.s),
                Opacity(
                  opacity: i >= step.windowStart && i <= step.windowEnd ? 1.0 : 0.5,
                  child: ArrayBoxWidget(
                    value: step.array[i],
                    isActive: i == step.windowEnd,
                    isResult: step.resultIndices.contains(i),
                  ),
                ),
              ],
            ],
          ),
        ),
        const Gap(AppSpacing.m),
        // Window range label
        Container(
          padding: const EdgeInsets.all(AppSpacing.s),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
          ),
          child: Text(
            'Window: [${step.windowStart}, ${step.windowEnd}]',
            style: AppTypography.code(fontSize: 12).copyWith(
              color: AppColors.primary,
            ),
          ),
        ),
        // Character frequency map if present
        if (step.charFreqMap.isNotEmpty) ...[
          const Gap(AppSpacing.m),
          Container(
            padding: const EdgeInsets.all(AppSpacing.s),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Char Frequency',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const Gap(AppSpacing.xs),
                ...step.charFreqMap.entries.map((e) => Text(
                      '${e.key}: ${e.value}',
                      style: AppTypography.code(fontSize: 11)
                          .copyWith(color: AppColors.textPrimary),
                    )),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
