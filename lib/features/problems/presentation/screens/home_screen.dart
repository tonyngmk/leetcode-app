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
                      childCount: state.problems.length + (state.isLoadingMore ? 1 : 0),
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

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.s,
      children: [
        for (final diff in ['Easy', 'Medium', 'Hard'])
          ChoiceChip(
            label: Text(diff),
            selected: active == diff,
            selectedColor: AppColors.difficultyColor(diff).withValues(alpha: 0.2),
            labelStyle: TextStyle(
              color: active == diff
                  ? AppColors.difficultyColor(diff)
                  : AppColors.textSecondary,
              fontWeight: active == diff ? FontWeight.w600 : FontWeight.w400,
              fontSize: 12,
            ),
            onSelected: (selected) {
              context.read<ProblemFeedCubit>().filterByDifficulty(
                    selected ? diff : null,
                  );
            },
          ),
      ],
    );
  }
}
