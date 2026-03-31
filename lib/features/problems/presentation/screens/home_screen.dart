import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../injection.dart';
import '../../domain/repositories/problems_repository.dart';
import '../cubits/problem_feed_cubit.dart';
import '../widgets/daily_challenge_card.dart';
import '../widgets/problem_list_tile.dart';
import '../widgets/problem_filter_chips.dart';
import '../../../../shared/widgets/skeleton_loading.dart';
import '../../../../shared/widgets/error_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProblemFeedCubit(repository: sl<ProblemsRepository>())..load(),
      child: const _HomeBody(),
    );
  }
}

class _HomeBody extends StatefulWidget {
  const _HomeBody();

  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ProblemFeedCubit>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ProblemFeedCubit, ProblemFeedState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () => context.read<ProblemFeedCubit>().refresh(),
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  floating: true,
                  title: Text(
                    'AlgoFlow',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () => context.go('/search'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () {},
                    ),
                  ],
                ),
                // Daily Challenge
                if (state is ProblemFeedLoaded && state.dailyChallenge != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                      child: DailyChallengeCard(challenge: state.dailyChallenge!),
                    ),
                  ),
                if (state is ProblemFeedLoading)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.m),
                      child: SkeletonLoading(height: 120),
                    ),
                  ),
                // Gap between daily challenge and filter chips
                const SliverToBoxAdapter(child: Gap(AppSpacing.m)),
                // Filter chips
                SliverToBoxAdapter(
                  child: ProblemFilterChips(
                    activeTag: state is ProblemFeedLoaded ? state.activeTag : null,
                    onTagSelected: (tag) {
                      context.read<ProblemFeedCubit>().filterByTag(tag);
                    },
                  ),
                ),
                // Difficulty filters
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.m,
                      vertical: AppSpacing.xs,
                    ),
                    child: _DifficultyFilters(
                      active: state is ProblemFeedLoaded ? state.activeDifficulty : null,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: Gap(AppSpacing.s)),
                // Problem list
                if (state is ProblemFeedLoading)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, _) => const ProblemTileSkeleton(),
                      childCount: 8,
                    ),
                  )
                else if (state is ProblemFeedError)
                  SliverFillRemaining(
                    child: ErrorView(
                      message: state.message,
                      onRetry: () => context.read<ProblemFeedCubit>().load(),
                    ),
                  )
                else if (state is ProblemFeedLoaded)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (state.isFiltering && index == 0) {
                          return Column(
                            children: [
                              LinearProgressIndicator(
                                backgroundColor: AppColors.surface,
                                color: AppColors.primary,
                                minHeight: 2,
                              ),
                              if (state.problems.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.all(AppSpacing.l),
                                  child: Center(child: CircularProgressIndicator()),
                                ),
                            ],
                          );
                        }
                        if (index < state.problems.length) {
                          return ProblemListTile(problem: state.problems[index]);
                        }
                        if (state.isLoadingMore) {
                          return const Padding(
                            padding: EdgeInsets.all(AppSpacing.m),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        return null;
                      },
                      childCount: state.problems.isEmpty && state.isFiltering
                          ? 1
                          : state.problems.length + (state.isLoadingMore ? 1 : 0),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          _navigateToRandomProblem(context);
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.shuffle, color: AppColors.background),
      ),
    );
  }

  void _navigateToRandomProblem(BuildContext context) {
    final state = context.read<ProblemFeedCubit>().state;
    if (state is ProblemFeedLoaded && state.problems.isNotEmpty) {
      final random = state.problems[Random().nextInt(state.problems.length)];
      context.push('/problem/${random.titleSlug}');
    }
  }
}

class _DifficultyFilters extends StatelessWidget {
  final String? active;

  const _DifficultyFilters({this.active});

  static const _difficulties = [
    ('Easy', Colors.green, Icons.circle),
    ('Medium', Colors.orange, Icons.circle),
    ('Hard', Colors.red, Icons.circle),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final (diff, color, _) in _difficulties)
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
              ),
              child: _DifficultyButton(
                label: diff,
                color: color,
                isSelected: active == diff,
                onSelected: (selected) {
                  context.read<ProblemFeedCubit>().filterByDifficulty(
                        selected ? diff : null,
                      );
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _DifficultyButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final ValueChanged<bool> onSelected;

  const _DifficultyButton({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onSelected(!isSelected),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.s,
          horizontal: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : AppColors.card,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
          border: Border.all(
            color: isSelected ? color : AppColors.divider,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.circle,
              size: 10,
              color: isSelected ? color : AppColors.textSecondary,
            ),
            const Gap(6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
