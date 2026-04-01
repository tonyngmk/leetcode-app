import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/repositories/visualization_repository.dart';
import '../cubits/visualizer_cubit.dart';
import 'renderer_factory.dart';
import 'step_controller_widget.dart';

/// Visualisation panel for a single problem approach.
///
/// Owns and manages the [VisualizerCubit] lifecycle. Receives a
/// [VisualizationRepository] from the caller (avoids direct sl<> access
/// inside a non-screen widget).
///
/// When [approachIndex] changes, reloads steps from the repository.
class VisualizationPanel extends StatefulWidget {
  final String slug;
  final int approachIndex;
  final VisualizationRepository repository;

  const VisualizationPanel({
    super.key,
    required this.slug,
    required this.approachIndex,
    required this.repository,
  });

  @override
  State<VisualizationPanel> createState() => _VisualizationPanelState();
}

class _VisualizationPanelState extends State<VisualizationPanel> {
  late VisualizerCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = VisualizerCubit(widget.repository);
    _cubit.loadForSlug(widget.slug, widget.approachIndex);
  }

  @override
  void didUpdateWidget(VisualizationPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slug != widget.slug ||
        oldWidget.approachIndex != widget.approachIndex) {
      _cubit.loadForSlug(widget.slug, widget.approachIndex);
    }
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<VisualizerCubit, VisualizerState>(
        builder: (context, state) {
          return switch (state) {
            VisualizerLoading() => _buildLoading(),
            VisualizerUnsupported() => const SizedBox.shrink(),
            VisualizerReady s => _buildReady(context, s),
          };
        },
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(color: AppColors.divider),
      ),
      padding: const EdgeInsets.all(AppSpacing.l),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildReady(BuildContext context, VisualizerReady state) {
    final step = state.currentStep;
    final previousStep =
        state.currentIndex > 0 ? state.steps[state.currentIndex - 1] : null;

    final visual = RendererFactory.buildVisual(step);
    final auxiliary = RendererFactory.buildAuxiliary(step, previousStep);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(color: AppColors.divider),
      ),
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Primary visualisation (array, tree, etc.)
          visual,
          const Gap(AppSpacing.m),
          // Auxiliary widget (hash map, etc.) — only when present
          if (auxiliary != null) ...[
            auxiliary,
            const Gap(AppSpacing.m),
          ],
          // Step description
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.s),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                step.description,
                key: ValueKey(state.currentIndex),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const Gap(AppSpacing.m),
          // Playback controls
          const StepControllerWidget(),
        ],
      ),
    );
  }
}
