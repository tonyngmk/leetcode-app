import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/visualization_step.dart';

/// Renders a 2D DP table as a scrollable grid.
/// Highlights the current cell and shows the recurrence formula.
class Dp2DVisualizerWidget extends StatelessWidget {
  final Dp2DStep step;

  const Dp2DVisualizerWidget({
    super.key,
    required this.step,
  });

  @override
  Widget build(BuildContext context) {
    if (step.table.isEmpty || step.table[0].isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: Text('Empty table'),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Formula
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
        // DP table grid
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int row = 0; row < step.table.length; row++) ...[
                    if (row > 0) const Gap(AppSpacing.xs),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (int col = 0; col < step.table[row].length; col++) ...[
                          if (col > 0) const Gap(AppSpacing.xs),
                          _Dp2DCellWidget(
                            value: step.table[row][col],
                            row: row,
                            col: col,
                            isCurrent: step.currentRow == row &&
                                step.currentCol == col,
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        // Current cell indicator
        if (step.currentRow != null && step.currentCol != null)
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
                'dp[${step.currentRow}][${step.currentCol}] = ${step.table[step.currentRow!][step.currentCol!]}',
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

/// Single cell in DP 2D table.
class _Dp2DCellWidget extends StatelessWidget {
  final int value;
  final int row;
  final int col;
  final bool isCurrent;

  const _Dp2DCellWidget({
    required this.value,
    required this.row,
    required this.col,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        border: Border.all(
          color: isCurrent ? AppColors.primary : AppColors.divider,
          width: isCurrent ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        color: isCurrent
            ? AppColors.primary.withValues(alpha: 0.15)
            : AppColors.card,
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$value',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isCurrent ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                ),
          ),
          Text(
            '[$row,$col]',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
          ),
        ],
      ),
    );
  }
}
