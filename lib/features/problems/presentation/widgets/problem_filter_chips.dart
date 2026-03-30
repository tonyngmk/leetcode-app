import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/tag_chip.dart';

class ProblemFilterChips extends StatelessWidget {
  final String? activeTag;
  final ValueChanged<String?> onTagSelected;

  const ProblemFilterChips({
    super.key,
    this.activeTag,
    required this.onTagSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
        itemCount: AppConstants.topicTags.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.s),
        itemBuilder: (context, index) {
          if (index == 0) {
            return TagChip(
              label: 'All',
              selected: activeTag == null,
              onTap: () => onTagSelected(null),
            );
          }
          final tag = AppConstants.topicTags[index - 1];
          return TagChip(
            label: tag,
            selected: activeTag == tag,
            onTap: () => onTagSelected(activeTag == tag ? null : tag),
          );
        },
      ),
    );
  }
}
