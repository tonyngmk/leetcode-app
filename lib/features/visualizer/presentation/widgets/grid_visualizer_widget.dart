import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/visualization_step.dart';

/// Renders a 2D grid with cells color-coded by state.
/// States: normal, visited, active, result, wall.
class GridVisualizerWidget extends StatelessWidget {
  final GridStep step;

  const GridVisualizerWidget({
    super.key,
    required this.step,
  });

  @override
  Widget build(BuildContext context) {
    if (step.grid.isEmpty || step.grid[0].isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: Text('Empty grid'),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int row = 0; row < step.grid.length; row++) ...[
                if (row > 0) const Gap(AppSpacing.xs),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int col = 0; col < step.grid[row].length; col++) ...[
                      if (col > 0) const Gap(AppSpacing.xs),
                      _GridCellWidget(
                        cell: step.grid[row][col],
                        isCurrent: step.currentCell != null &&
                            step.currentCell!.$1 == row &&
                            step.currentCell!.$2 == col,
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Single grid cell with state-based coloring.
class _GridCellWidget extends StatelessWidget {
  final VisGridCell cell;
  final bool isCurrent;

  const _GridCellWidget({
    required this.cell,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color borderColor;
    Color textColor;

    switch (cell.state) {
      case 'wall':
        bgColor = AppColors.divider;
        borderColor = AppColors.divider;
        textColor = AppColors.textSecondary;
      case 'result':
        bgColor = AppColors.easy.withValues(alpha: 0.25);
        borderColor = AppColors.easy;
        textColor = AppColors.easy;
      case 'active':
        bgColor = AppColors.primary.withValues(alpha: 0.25);
        borderColor = AppColors.primary;
        textColor = AppColors.primary;
      case 'visited':
        bgColor = AppColors.medium.withValues(alpha: 0.15);
        borderColor = AppColors.medium;
        textColor = AppColors.textPrimary;
      case 'normal':
      default:
        bgColor = AppColors.card;
        borderColor = AppColors.divider;
        textColor = AppColors.textPrimary;
    }

    // Highlight current cell with a thicker border
    if (isCurrent) {
      borderColor = AppColors.primary;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(
          color: borderColor,
          width: isCurrent ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
      ),
      alignment: Alignment.center,
      child: Text(
        '${cell.value}',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
