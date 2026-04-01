import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Renders two rows: original array and running prefix sum.
/// Used for: Range Sum Query, Product of Array Except Self, etc.
class PrefixSumVisualizerWidget extends StatelessWidget {
  final List<int> originalArray;
  final List<int> prefixArray;
  final int currentIndex;

  const PrefixSumVisualizerWidget({
    super.key,
    required this.originalArray,
    required this.prefixArray,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Original array row
        _buildRow(context, 'nums', originalArray, -1),
        const Gap(AppSpacing.m),
        // Prefix array row
        _buildRow(context, 'prefix', prefixArray, currentIndex),
      ],
    );
  }

  Widget _buildRow(
    BuildContext context,
    String label,
    List<int> values,
    int highlightIndex,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const Gap(AppSpacing.xs),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < values.length; i++) ...[
                if (i > 0) const Gap(AppSpacing.xs),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: i == highlightIndex
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : AppColors.card,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                    border: Border.all(
                      color: i == highlightIndex
                          ? AppColors.primary
                          : AppColors.divider,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${values[i]}',
                    style: AppTypography.code(fontSize: 12).copyWith(
                      color: i == highlightIndex
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
