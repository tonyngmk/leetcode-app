import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/visualization_step.dart';
import 'array_box_widget.dart';

/// Renders a queue as a horizontal row of boxes (left = front, right = back).
/// Animated enqueue/dequeue with currentOp description.
class QueueVisualizerWidget extends StatelessWidget {
  final QueueStep step;

  const QueueVisualizerWidget({
    super.key,
    required this.step,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Queue label
        Text(
          'Queue ${step.currentOp.isNotEmpty ? '(${step.currentOp})' : ''}',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const Gap(AppSpacing.m),
        // Queue boxes (left = front, right = back)
        Container(
          padding: const EdgeInsets.all(AppSpacing.m),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.divider),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Front pointer
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.s),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Front',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Icon(
                      Icons.arrow_downward,
                      size: 12,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
              // Queue elements
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < step.queue.length; i++) ...[
                    if (i > 0) const Gap(AppSpacing.xs),
                    SizedBox(
                      width: 48,
                      child: ArrayBoxWidget(
                        value: step.queue[i],
                        isActive: false,
                        isResult: step.inputValue == step.queue[i],
                      ),
                    ),
                  ],
                  if (step.queue.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.m,
                      ),
                      child: Text(
                        'Empty',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ),
                ],
              ),
              // Back pointer
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.s),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Back',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.medium,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Icon(
                      Icons.arrow_downward,
                      size: 12,
                      color: AppColors.medium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Front/Back indicators
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
                step.queue.isEmpty
                    ? 'Empty'
                    : 'Front: ${step.queue.first} | Back: ${step.queue.last}',
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
