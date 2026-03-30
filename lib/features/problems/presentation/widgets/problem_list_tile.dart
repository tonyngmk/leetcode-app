import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/difficulty_badge.dart';
import '../../data/models/problem_list_item_model.dart';

class ProblemListTile extends StatelessWidget {
  final ProblemListItem problem;
  final bool isSolved;

  const ProblemListTile({
    super.key,
    required this.problem,
    this.isSolved = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push('/problem/${problem.titleSlug}');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.m,
          vertical: AppSpacing.s,
        ),
        child: Row(
          children: [
            // Solved indicator
            if (isSolved)
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.s),
                child: Icon(Icons.check_circle, color: AppColors.easy, size: 18),
              ),
            // Problem info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${problem.questionFrontendId}. ',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      Expanded(
                        child: Text(
                          problem.title,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (problem.isPaidOnly)
                        Padding(
                          padding: const EdgeInsets.only(left: AppSpacing.xs),
                          child: Icon(Icons.lock, size: 14, color: AppColors.medium),
                        ),
                    ],
                  ),
                  const Gap(AppSpacing.xs),
                  Row(
                    children: [
                      DifficultyBadge(difficulty: problem.difficulty),
                      const Gap(AppSpacing.s),
                      Text(
                        '${problem.acRate.toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      const Gap(AppSpacing.s),
                      Expanded(
                        child: Row(
                          children: problem.topicTags
                              .take(2)
                              .map(
                                (tag) => Padding(
                                  padding: const EdgeInsets.only(right: AppSpacing.xs),
                                  child: Text(
                                    tag.name,
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}
