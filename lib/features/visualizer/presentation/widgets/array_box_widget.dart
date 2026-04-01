import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// A single element box in the array visualizer.
/// Shows the value, optional pointer label above, and highlights
/// based on [isActive] (primary/blue) and [isResult] (easy/green).
class ArrayBoxWidget extends StatelessWidget {
  final int value;
  final String? pointerLabel; // e.g. 'i', 'j', 'curr' — shown above box
  final bool isActive; // highlight with AppColors.primary
  final bool isResult; // highlight with AppColors.easy (overrides active)

  const ArrayBoxWidget({
    super.key,
    required this.value,
    this.pointerLabel,
    this.isActive = false,
    this.isResult = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor;
    final Color bgColor;
    final Color textColor;

    if (isResult) {
      borderColor = AppColors.easy;
      bgColor = AppColors.easy.withValues(alpha: 0.15);
      textColor = AppColors.easy;
    } else if (isActive) {
      borderColor = AppColors.primary;
      bgColor = AppColors.primary.withValues(alpha: 0.15);
      textColor = AppColors.primary;
    } else {
      borderColor = AppColors.divider;
      bgColor = AppColors.card;
      textColor = AppColors.textPrimary;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pointer label area — fixed height so boxes stay aligned
        SizedBox(
          height: 18,
          child: pointerLabel != null
              ? Text(
                  pointerLabel!,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isResult ? AppColors.easy : AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                )
              : null,
        ),
        const Gap(AppSpacing.xs),
        // Box
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          alignment: Alignment.center,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),
            style: AppTypography.code(fontSize: 14).copyWith(color: textColor),
            child: Text('$value'),
          ),
        ),
      ],
    );
  }
}
