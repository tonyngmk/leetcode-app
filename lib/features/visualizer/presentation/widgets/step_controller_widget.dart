import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../cubits/visualizer_cubit.dart';

/// Play/Pause/Prev/Next/Reset controls for the visualiser.
/// Only renders when the cubit is in [VisualizerReady] state.
/// Must be inside a `BlocProvider<VisualizerCubit>`.
class StepControllerWidget extends StatelessWidget {
  const StepControllerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VisualizerCubit, VisualizerState>(
      builder: (context, state) {
        if (state is! VisualizerReady) return const SizedBox.shrink();

        final cubit = context.read<VisualizerCubit>();
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Step counter
            Text(
              '${state.currentIndex + 1} / ${state.steps.length}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const Gap(AppSpacing.m),
            // Reset
            _ControlButton(
              icon: Icons.skip_previous,
              tooltip: 'Reset',
              onPressed: state.isAtStart
                  ? null
                  : () {
                      HapticFeedback.lightImpact();
                      cubit.reset();
                    },
            ),
            const Gap(AppSpacing.xs),
            // Prev
            _ControlButton(
              icon: Icons.chevron_left,
              tooltip: 'Previous step',
              onPressed: state.isAtStart
                  ? null
                  : () {
                      HapticFeedback.lightImpact();
                      cubit.prev();
                    },
            ),
            const Gap(AppSpacing.xs),
            // Play / Pause
            _ControlButton(
              icon: state.isPlaying ? Icons.pause : Icons.play_arrow,
              tooltip: state.isPlaying ? 'Pause' : 'Play',
              isPrimary: true,
              onPressed: () {
                HapticFeedback.lightImpact();
                cubit.togglePlayPause();
              },
            ),
            const Gap(AppSpacing.xs),
            // Next
            _ControlButton(
              icon: Icons.chevron_right,
              tooltip: 'Next step',
              onPressed: state.isAtEnd
                  ? null
                  : () {
                      HapticFeedback.lightImpact();
                      cubit.next();
                    },
            ),
          ],
        );
      },
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool isPrimary;

  const _ControlButton({
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = onPressed == null
        ? AppColors.textSecondary.withValues(alpha: 0.4)
        : isPrimary
            ? AppColors.primary
            : AppColors.textSecondary;

    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isPrimary && onPressed != null
                ? AppColors.primary.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
            border: Border.all(
              color: isPrimary && onPressed != null
                  ? AppColors.primary
                  : AppColors.divider,
            ),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
}
