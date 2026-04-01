import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/visualization_step.dart';
import 'array_box_widget.dart';

/// Renders a stack as a vertical column of boxes (top = last pushed).
/// Animated push/pop with currentOp description.
class StackVisualizerWidget extends StatelessWidget {
  final StackStep step;

  const StackVisualizerWidget({
    super.key,
    required this.step,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Stack label
        Text(
          'Stack ${step.currentOp.isNotEmpty ? '(${step.currentOp})' : ''}',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const Gap(AppSpacing.m),
        // Stack boxes (reverse order: top of stack is at bottom visually)
        Container(
          padding: const EdgeInsets.all(AppSpacing.m),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.divider),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = step.stack.length - 1; i >= 0; i--) ...[
                if (i < step.stack.length - 1) const Gap(AppSpacing.xs),
                SizedBox(
                  width: 80,
                  child: ArrayBoxWidget(
                    value: step.stack[i],
                    isActive: false,
                    isResult: step.inputValue == step.stack[i],
                  ),
                ),
              ],
              if (step.stack.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  child: Text(
                    'Empty',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ),
            ],
          ),
        ),
        // Top/Pop indicator
        const Gap(AppSpacing.s),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.m,
                vertical: AppSpacing.s,
              ),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
              ),
              child: Text(
                step.stack.isEmpty ? 'Empty' : 'Top: ${step.stack.last}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
