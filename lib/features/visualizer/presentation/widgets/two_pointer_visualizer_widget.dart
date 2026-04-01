import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/visualization_step.dart';
import 'array_box_widget.dart';

/// Renders an array with left and right converging pointers.
/// Used for: 3Sum, Container With Most Water, Trapping Rain Water, etc.
class TwoPointerVisualizerWidget extends StatelessWidget {
  final TwoPointerStep step;

  const TwoPointerVisualizerWidget({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pointer labels (L/R)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.s),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < step.array.length; i++) ...[
                if (i > 0) const Gap(AppSpacing.s),
                SizedBox(
                  width: 48,
                  child: i == step.left
                      ? Text(
                          'L',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        )
                      : i == step.right
                          ? Text(
                              'R',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: AppColors.medium,
                                    fontWeight: FontWeight.w600,
                                  ),
                            )
                          : const SizedBox.shrink(),
                ),
              ],
            ],
          ),
        ),
        // Array boxes
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (int i = 0; i < step.array.length; i++) ...[
              if (i > 0) const Gap(AppSpacing.s),
              ArrayBoxWidget(
                value: step.array[i],
                isActive: i == step.left || i == step.right,
                isResult: step.resultIndices.contains(i),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
