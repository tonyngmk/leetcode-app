import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import 'array_box_widget.dart';

/// Renders an array with lo/mid/hi pointers and dimmed eliminated regions.
/// Used for: Search in Rotated Array, Find Peak Element, etc.
class BinarySearchVisualizerWidget extends StatelessWidget {
  final List<int> array;
  final int lo;
  final int mid;
  final int hi;
  final bool eliminatedLeft;
  final bool eliminatedRight;

  const BinarySearchVisualizerWidget({
    super.key,
    required this.array,
    required this.lo,
    required this.mid,
    required this.hi,
    this.eliminatedLeft = false,
    this.eliminatedRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pointer labels
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.s),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < array.length; i++) ...[
                if (i > 0) const Gap(AppSpacing.s),
                SizedBox(
                  width: 48,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (i == lo)
                        Text(
                          'lo',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        )
                      else if (i == mid)
                        Text(
                          'mid',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                color: AppColors.medium,
                                fontWeight: FontWeight.w600,
                              ),
                        )
                      else if (i == hi)
                        Text(
                          'hi',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                color: AppColors.hard,
                                fontWeight: FontWeight.w600,
                              ),
                        )
                      else
                        const SizedBox.shrink(),
                    ],
                  ),
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
            for (int i = 0; i < array.length; i++) ...[
              if (i > 0) const Gap(AppSpacing.s),
              Opacity(
                opacity: (eliminatedLeft && i < lo) || (eliminatedRight && i > hi)
                    ? 0.4
                    : 1.0,
                child: ArrayBoxWidget(
                  value: array[i],
                  isActive: i == lo || i == mid || i == hi,
                ),
              ),
            ],
          ],
        ),
        const Gap(AppSpacing.m),
        // Range indicator
        Container(
          padding: const EdgeInsets.all(AppSpacing.s),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
          ),
          child: Text(
            'Range: [$lo, $hi] | mid=$mid',
            style: AppTypography.code(fontSize: 12).copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
