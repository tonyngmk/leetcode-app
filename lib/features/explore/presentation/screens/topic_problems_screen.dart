import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/skeleton_loading.dart';
import '../../../problems/domain/repositories/problems_repository.dart';
import '../../../problems/presentation/cubits/problem_feed_cubit.dart';
import '../../../problems/presentation/widgets/problem_list_tile.dart';

class TopicProblemsScreen extends StatelessWidget {
  final String tag;

  const TopicProblemsScreen({super.key, required this.tag});

  String get _displayTag => tag.replaceAll('-', ' ').split(' ').map((w) {
        if (w.isEmpty) return w;
        return w[0].toUpperCase() + w.substring(1);
      }).join(' ');

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProblemFeedCubit(repository: sl<ProblemsRepository>())
        ..filterByTag(_displayTag),
      child: Scaffold(
        appBar: AppBar(title: Text(_displayTag)),
        body: BlocBuilder<ProblemFeedCubit, ProblemFeedState>(
          builder: (context, state) {
            return switch (state) {
              ProblemFeedLoading() => ListView.builder(
                  itemCount: 8,
                  itemBuilder: (_, _) => const ProblemTileSkeleton(),
                ),
              ProblemFeedError(:final message) => ErrorView(
                  message: message,
                  onRetry: () =>
                      context.read<ProblemFeedCubit>().filterByTag(_displayTag),
                ),
              ProblemFeedLoaded(:final problems) => problems.isEmpty
                  ? const Center(child: Text('No problems found'))
                  : ListView.builder(
                      itemCount: problems.length,
                      itemBuilder: (context, index) =>
                          ProblemListTile(problem: problems[index]),
                    ),
            };
          },
        ),
      ),
    );
  }
}
