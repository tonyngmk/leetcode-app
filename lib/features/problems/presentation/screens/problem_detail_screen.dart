import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../injection.dart';
import '../../../../shared/widgets/difficulty_badge.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/skeleton_loading.dart';
import '../../data/models/problem_model.dart';
import '../../domain/repositories/problems_repository.dart';
import '../../../solutions/domain/repositories/solutions_repository.dart';
import '../cubits/problem_detail_cubit.dart';
import '../widgets/solution_tab_view.dart';

class ProblemDetailScreen extends StatelessWidget {
  final String slug;

  const ProblemDetailScreen({super.key, required this.slug});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProblemDetailCubit(
        problemsRepo: sl<ProblemsRepository>(),
        solutionsRepo: sl<SolutionsRepository>(),
      )..load(slug),
      child: _ProblemDetailBody(slug: slug),
    );
  }
}

class _ProblemDetailBody extends StatelessWidget {
  final String slug;

  const _ProblemDetailBody({required this.slug});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProblemDetailCubit, ProblemDetailState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: state is ProblemDetailLoaded
                ? Text(state.problem.title, overflow: TextOverflow.ellipsis)
                : null,
          ),
          body: switch (state) {
            ProblemDetailLoading() => const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SkeletonLoading(height: 24, width: 200),
                    Gap(AppSpacing.m),
                    SkeletonLoading(height: 300),
                  ],
                ),
              ),
            ProblemDetailError(:final message) => ErrorView(
                message: message,
                onRetry: () => context.read<ProblemDetailCubit>().load(slug),
              ),
            ProblemDetailLoaded(:final problem, :final solution, :final solveStatus) =>
              _LoadedContent(
                problem: problem,
                solution: solution,
                solveStatus: solveStatus,
                slug: slug,
              ),
          },
          bottomNavigationBar: state is ProblemDetailLoaded
              ? _StartCodingBar(slug: slug, problem: state.problem)
              : null,
        );
      },
    );
  }
}

class _LoadedContent extends StatelessWidget {
  final dynamic problem;
  final dynamic solution;
  final String? solveStatus;
  final String slug;

  const _LoadedContent({
    required this.problem,
    required this.solution,
    required this.solveStatus,
    required this.slug,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: solution != null ? 3 : 2,
      child: Column(
        children: [
          // Stats row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
            child: Row(
              children: [
                DifficultyBadge(difficulty: problem.difficulty),
                const Gap(AppSpacing.s),
                if (solveStatus == 'ac')
                  const Icon(Icons.check_circle, color: AppColors.easy, size: 18),
                const Spacer(),
                if (problem.likes > 0) ...[
                  Icon(Icons.thumb_up_outlined, size: 14, color: AppColors.textSecondary),
                  const Gap(2),
                  Text('${problem.likes}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          )),
                  const Gap(AppSpacing.m),
                ],
              ],
            ),
          ),
          const Gap(AppSpacing.s),
          // Tabs
          TabBar(
            tabs: [
              const Tab(text: 'Description'),
              const Tab(text: 'Hints'),
              if (solution != null) const Tab(text: 'Solutions'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _DescriptionTab(content: problem.content ?? ''),
                _HintsTab(hints: problem.hints),
                if (solution != null) SolutionTabView(solution: solution),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DescriptionTab extends StatelessWidget {
  final String content;

  const _DescriptionTab({required this.content});

  @override
  Widget build(BuildContext context) {
    if (content.isEmpty) {
      return const Center(child: Text('No description available'));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: HtmlWidget(
        content,
        textStyle: Theme.of(context).textTheme.bodyMedium,
        customStylesBuilder: (element) {
          if (element.localName == 'code') {
            return {
              'background-color': '#21262D',
              'padding': '2px 6px',
              'border-radius': '4px',
              'font-family': 'JetBrains Mono',
              'font-size': '13px',
            };
          }
          if (element.localName == 'pre') {
            return {
              'background-color': '#161B22',
              'padding': '12px',
              'border-radius': '8px',
              'overflow': 'auto',
            };
          }
          return null;
        },
      ),
    );
  }
}

class _HintsTab extends StatefulWidget {
  final List<String> hints;

  const _HintsTab({required this.hints});

  @override
  State<_HintsTab> createState() => _HintsTabState();
}

class _HintsTabState extends State<_HintsTab> {
  final _revealedHints = <int>{};

  @override
  Widget build(BuildContext context) {
    if (widget.hints.isEmpty) {
      return const Center(child: Text('No hints available'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.m),
      itemCount: widget.hints.length,
      itemBuilder: (context, index) {
        final revealed = _revealedHints.contains(index);
        return Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.s),
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _revealedHints.add(index));
            },
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hint ${index + 1}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const Gap(AppSpacing.s),
                  AnimatedCrossFade(
                    firstChild: Container(
                      height: 40,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Tap to reveal',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.primary,
                            ),
                      ),
                    ),
                    secondChild: HtmlWidget(
                      widget.hints[index],
                      textStyle: Theme.of(context).textTheme.bodyMedium,
                    ),
                    crossFadeState: revealed
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StartCodingBar extends StatelessWidget {
  final String slug;
  final Problem problem;

  const _StartCodingBar({required this.slug, required this.problem});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: AppColors.divider),
        ),
      ),
      child: SafeArea(
        child: FilledButton(
          onPressed: () {
            debugPrint('[START_CODING] button pressed, slug=$slug, problem=${problem.title}, codeSnippets=${problem.codeSnippets.length}');
            HapticFeedback.lightImpact();
            debugPrint('[START_CODING] calling context.push with extra');
            context.push('/problem/$slug/editor', extra: problem);
            debugPrint('[START_CODING] context.push returned');
          },
          child: const Text('Start Coding'),
        ),
      ),
    );
  }
}
