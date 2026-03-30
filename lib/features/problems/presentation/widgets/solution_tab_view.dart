import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../solutions/data/models/solution_model.dart';

class SolutionTabView extends StatefulWidget {
  final Solution solution;

  const SolutionTabView({super.key, required this.solution});

  @override
  State<SolutionTabView> createState() => _SolutionTabViewState();
}

class _SolutionTabViewState extends State<SolutionTabView> {
  int _selectedApproach = 0;
  String _selectedLang = 'python';

  @override
  Widget build(BuildContext context) {
    if (widget.solution.approaches.isEmpty) {
      return const Center(child: Text('No solutions available'));
    }

    final approach = widget.solution.approaches[_selectedApproach];
    final availableLangs = approach.code.keys.toList();
    if (!availableLangs.contains(_selectedLang) && availableLangs.isNotEmpty) {
      _selectedLang = availableLangs.first;
    }

    return Column(
      children: [
        // Approach tabs
        if (widget.solution.approaches.length > 1)
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.xs),
              itemCount: widget.solution.approaches.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.s),
              itemBuilder: (context, index) {
                final isSelected = index == _selectedApproach;
                return GestureDetector(
                  onTap: () => setState(() => _selectedApproach = index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.card,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.divider,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      widget.solution.approaches[index].name,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isSelected ? AppColors.primary : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                    ),
                  ),
                );
              },
            ),
          ),
        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Explanation
                Text(
                  approach.explanation,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Gap(AppSpacing.m),
                // Complexity badges
                Row(
                  children: [
                    _ComplexityBadge(label: 'Time', value: approach.timeComplexity),
                    const Gap(AppSpacing.s),
                    _ComplexityBadge(label: 'Space', value: approach.spaceComplexity),
                  ],
                ),
                const Gap(AppSpacing.m),
                // Language tabs
                SizedBox(
                  height: 32,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: availableLangs.map((lang) {
                      final isSelected = lang == _selectedLang;
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.xs),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedLang = lang),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.surface : Colors.transparent,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                              border: isSelected
                                  ? Border.all(color: AppColors.primary)
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              lang,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                                  ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const Gap(AppSpacing.s),
                // Code block
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.m),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: SelectableText(
                    approach.code[_selectedLang] ?? 'No code available',
                    style: AppTypography.code().copyWith(
                          color: AppColors.textPrimary,
                        ),
                  ),
                ),
              ],
            ),
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
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s, vertical: AppSpacing.xs),
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
