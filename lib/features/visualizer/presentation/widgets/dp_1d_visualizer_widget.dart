import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/visualization_step.dart';

/// Renders a 1D DP table as a horizontal row of cells.
/// Highlights the current index being computed; shows the recurrence formula.
class Dp1DVisualizerWidget extends StatelessWidget {
  final Dp1DStep step;

  const Dp1DVisualizerWidget({
    super.key,
    required this.step,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // DP table label and formula
        if (step.formula != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.m),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.m),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
              ),
              child: Text(
                'Formula: ${step.formula}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontFamily: 'JetBrainsMono',
                    ),
              ),
            ),
          ),
        // DP table row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < step.table.length; i++) ...[
              if (i > 0) const Gap(AppSpacing.xs),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Index label
                  SizedBox(
                    width: 48,
                    height: 20,
                    child: Text(
                      'i=$i',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: step.currentIndex == i
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontWeight: step.currentIndex == i
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                    ),
                  ),
                  const Gap(AppSpacing.xs),
                  // Cell
                  SizedBox(
                    width: 48,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.s),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: step.currentIndex == i
                              ? AppColors.primary
                              : AppColors.divider,
                          width: step.currentIndex == i ? 2 : 1,
                        ),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusSmall),
                        color: step.currentIndex == i
                            ? AppColors.primary.withValues(alpha: 0.15)
                            : AppColors.card,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${step.table[i]}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(
                              color: step.currentIndex == i
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                              fontWeight: step.currentIndex == i
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        // Current value indicator
        if (step.currentIndex != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.m),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.m,
                vertical: AppSpacing.s,
              ),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
              ),
              child: Text(
                'dp[${step.currentIndex}] = ${step.table[step.currentIndex!]}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
      ],
    );
  }
}
