import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  static const _topicIcons = <String, IconData>{
    'Array': Icons.data_array,
    'String': Icons.text_fields,
    'Hash Table': Icons.tag,
    'Dynamic Programming': Icons.trending_up,
    'Math': Icons.calculate,
    'Sorting': Icons.sort,
    'Greedy': Icons.bolt,
    'Depth-First Search': Icons.account_tree,
    'Binary Search': Icons.search,
    'Tree': Icons.park,
    'Breadth-First Search': Icons.layers,
    'Matrix': Icons.grid_on,
    'Two Pointers': Icons.compare_arrows,
    'Stack': Icons.stacked_bar_chart,
    'Graph': Icons.hub,
    'Linked List': Icons.link,
    'Heap (Priority Queue)': Icons.filter_list,
    'Sliding Window': Icons.width_normal,
    'Backtracking': Icons.undo,
    'Recursion': Icons.loop,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.m),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.3,
          crossAxisSpacing: AppSpacing.s,
          mainAxisSpacing: AppSpacing.s,
        ),
        itemCount: AppConstants.topicTags.length,
        itemBuilder: (context, index) {
          final tag = AppConstants.topicTags[index];
          final icon = _topicIcons[tag] ?? Icons.code;
          return _TopicCard(tag: tag, icon: icon);
        },
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  final String tag;
  final IconData icon;

  const _TopicCard({required this.tag, required this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push('/explore/${tag.toLowerCase().replaceAll(' ', '-')}');
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const Gap(AppSpacing.s),
            Text(
              tag,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
