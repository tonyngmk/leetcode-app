import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../problems/data/models/problem_model.dart';
import '../../../solutions/data/models/solution_model.dart';
import '../../../../injection.dart';
import '../../../visualizer/domain/repositories/visualization_repository.dart';
import '../../../visualizer/presentation/widgets/visualization_panel.dart';

const _langDisplayNames = {
  'python': 'Python',
  'java': 'Java',
  'cpp': 'C++',
  'javascript': 'JavaScript',
  'go': 'Go',
};

const _supportedLangs = ['python', 'java', 'cpp', 'javascript', 'go'];

class SolutionTabView extends StatefulWidget {
  final Solution solution;
  final Problem problem;

  const SolutionTabView({super.key, required this.solution, required this.problem});

  @override
  State<SolutionTabView> createState() => _SolutionTabViewState();
}

class _SolutionTabViewState extends State<SolutionTabView> {
  int _selectedApproach = 0;
  String _selectedLang = 'python';
  bool _spoilerRevealed = false;
  double _spoilerOpacity = 1.0;
  bool _visualizerExpanded = false;
  bool _hasVisualization = false;

  @override
  void initState() {
    super.initState();
    if (widget.solution.approaches.isNotEmpty) {
      final firstApproach = widget.solution.approaches[0];
      final langs = firstApproach.code.keys.toList();
      if (langs.isNotEmpty) {
        _selectedLang = langs.first;
      }
    }
    // Async check — widget rebuilds once result is known.
    sl<VisualizationRepository>()
        .hasVisualization(widget.problem.titleSlug)
        .then((has) {
      if (mounted) setState(() => _hasVisualization = has);
    });
  }

  void _revealSpoiler() {
    HapticFeedback.lightImpact();
    setState(() => _spoilerOpacity = 0.0);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _spoilerRevealed = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.solution.approaches.isEmpty) {
      return _EmptySolutionsView();
    }

    final approach = widget.solution.approaches[_selectedApproach];
    final availableLangs = approach.code.keys.toList();

    if (!availableLangs.contains(_selectedLang) && availableLangs.isNotEmpty) {
      _selectedLang = availableLangs.first;
    }

    return Column(
      children: [
        // Approach chip strip
        if (widget.solution.approaches.length > 1)
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.m,
                vertical: AppSpacing.xs,
              ),
              itemCount: widget.solution.approaches.length,
              separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.s),
              itemBuilder: (context, index) {
                final isSelected = index == _selectedApproach;
                return Semantics(
                  label: 'Approach ${index + 1} of ${widget.solution.approaches.length}',
                  button: true,
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedApproach = index),
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 48),
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.15)
                            : AppColors.card,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.divider,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        widget.solution.approaches[index].name,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              fontWeight:
                                  isSelected ? FontWeight.w600 : FontWeight.w400,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        // Visualize toggle — shown for any problem with visualisation data
        if (_hasVisualization)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.m,
              vertical: AppSpacing.xs,
            ),
            child: GestureDetector(
              onTap: () =>
                  setState(() => _visualizerExpanded = !_visualizerExpanded),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.m,
                  vertical: AppSpacing.s,
                ),
                decoration: BoxDecoration(
                  color: _visualizerExpanded
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : AppColors.card,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusSmall),
                  border: Border.all(
                    color: _visualizerExpanded
                        ? AppColors.primary
                        : AppColors.divider,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _visualizerExpanded
                          ? Icons.visibility_off_outlined
                          : Icons.play_circle_outline,
                      size: 16,
                      color: _visualizerExpanded
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    const Gap(AppSpacing.xs),
                    Text(
                      _visualizerExpanded
                          ? 'Hide Visualizer'
                          : 'Visualize',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                            color: _visualizerExpanded
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        // Collapsible visualization panel
        if (_hasVisualization && _visualizerExpanded)
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.m,
                vertical: AppSpacing.xs,
              ),
              child: VisualizationPanel(
                slug: widget.problem.titleSlug,
                approachIndex: _selectedApproach,
                repository: sl<VisualizationRepository>(),
              ),
            ),
          ),
        // Spoiler gate
        Expanded(
          child: Stack(
            children: [
              // Content (always rendered, obscured by gate)
              AnimatedOpacity(
                opacity: _spoilerRevealed ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Approach header
                      Text(
                        approach.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const Gap(AppSpacing.s),
                      // Complexity badges + preferred lang
                      Row(
                        children: [
                          _ComplexityBadge(
                            label: 'Time',
                            value: approach.timeComplexity,
                          ),
                          const Gap(AppSpacing.s),
                          _ComplexityBadge(
                            label: 'Space',
                            value: approach.spaceComplexity,
                          ),
                          if (availableLangs.isNotEmpty) ...[
                            const Gap(AppSpacing.s),
                            _PreferredLangTag(lang: availableLangs.first),
                          ],
                        ],
                      ),
                      const Gap(AppSpacing.m),
                      // Language pills
                      SizedBox(
                        height: 32,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _supportedLangs.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: AppSpacing.xs),
                          itemBuilder: (context, index) {
                            final lang = _supportedLangs[index];
                            final hasCode = availableLangs.contains(lang);
                            final isSelected = lang == _selectedLang;
                            return Semantics(
                              label:
                                  '${_langDisplayNames[lang] ?? lang}${isSelected ? ', selected' : ''}${!hasCode ? ', no code available' : ''}',
                              button: true,
                              child: GestureDetector(
                                onTap: hasCode
                                    ? () => setState(() => _selectedLang = lang)
                                    : null,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.s,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.surface
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(
                                        AppSpacing.radiusSmall),
                                    border: isSelected
                                        ? Border.all(color: AppColors.primary)
                                        : null,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    _langDisplayNames[lang] ?? lang,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: hasCode
                                              ? (isSelected
                                                  ? AppColors.primary
                                                  : AppColors.textSecondary)
                                              : AppColors.textSecondary
                                                  .withValues(alpha: 0.4),
                                        ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const Gap(AppSpacing.m),
                      // Explanation
                      Text(
                        approach.explanation,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const Gap(AppSpacing.m),
                      // Code block
                      _CodeBlock(
                        lang: _langDisplayNames[_selectedLang] ?? _selectedLang,
                        code: approach.code[_selectedLang] ?? '',
                        onEdit: () {
                          context.push(
                            '/problem/${widget.problem.titleSlug}/editor',
                            extra: {
                              'problem': widget.problem,
                              'initialCode': approach.code[_selectedLang] ?? '',
                            },
                          );
                        },
                      ),
                      const Gap(AppSpacing.xxl),
                    ],
                  ),
                ),
              ),
              // Spoiler gate overlay
              if (!_spoilerRevealed)
                Positioned.fill(
                  child: AnimatedOpacity(
                    opacity: _spoilerOpacity,
                    duration: const Duration(milliseconds: 300),
                    child: GestureDetector(
                      onTap: _revealSpoiler,
                      child: Container(
                        color: AppColors.background,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lock_outline,
                              size: 48,
                              color: AppColors.textSecondary,
                            ),
                            const Gap(AppSpacing.m),
                            Text(
                              'Solutions are hidden by default',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(color: AppColors.textPrimary),
                            ),
                            const Gap(AppSpacing.xs),
                            Text(
                              'LeetCode hides solutions until you try.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                            const Gap(AppSpacing.l),
                            FilledButton(
                              onPressed: _revealSpoiler,
                              child: const Text('View Solutions'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ComplexityBadge extends StatelessWidget {
  final String label;
  final String value;

  const _ComplexityBadge({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _PreferredLangTag extends StatelessWidget {
  final String lang;

  const _PreferredLangTag({required this.lang});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _langDisplayNames[lang] ?? lang,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const Gap(4),
          Icon(Icons.check, size: 12, color: AppColors.easy),
        ],
      ),
    );
  }
}

class _CodeBlock extends StatefulWidget {
  final String lang;
  final String code;
  final VoidCallback onEdit;

  const _CodeBlock({
    required this.lang,
    required this.code,
    required this.onEdit,
  });

  @override
  State<_CodeBlock> createState() => _CodeBlockState();
}

class _CodeBlockState extends State<_CodeBlock> {
  bool _copied = false;

  void _copy() {
    Clipboard.setData(ClipboardData(text: widget.code));
    HapticFeedback.lightImpact();
    setState(() => _copied = true);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header bar
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.m,
              vertical: AppSpacing.s,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.divider),
              ),
            ),
            child: Row(
              children: [
                Text(
                  widget.lang,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    _copied ? Icons.check : Icons.copy,
                    size: 18,
                    color: _copied ? AppColors.easy : AppColors.textSecondary,
                  ),
                  tooltip: 'Copy',
                  onPressed: _copy,
                  constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 18, color: AppColors.textSecondary),
                  tooltip: 'Edit in Editor',
                  onPressed: widget.onEdit,
                  constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                ),
              ],
            ),
          ),
          // Code content
          Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: SelectableText(
              widget.code,
              style: AppTypography.code().copyWith(
                    color: AppColors.textPrimary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySolutionsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.code_off,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const Gap(AppSpacing.m),
          Text(
            'No solutions cached yet.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                ),
          ),
          const Gap(AppSpacing.xs),
          Text(
            'Start coding to contribute!',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}
