import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Displays the current hash map state as a vertical list of key → value rows.
/// Animates new entries appearing via [AnimatedOpacity].
///
/// [previousKeys] should be the set of keys from the previous step so new
/// keys can be highlighted. Pass empty set on first render.
class HashMapVisualizerWidget extends StatelessWidget {
  final Map<int, int> hashMap;
  final Set<int> previousKeys;

  const HashMapVisualizerWidget({
    super.key,
    required this.hashMap,
    this.previousKeys = const {},
  });

  @override
  Widget build(BuildContext context) {
    if (hashMap.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(color: AppColors.divider),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.s,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Text(
            'Hash Map',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const Gap(AppSpacing.xs),
          // Entries
          ...hashMap.entries.map((entry) {
            final isNew = !previousKeys.contains(entry.key);
            return _MapEntry(
              key: ValueKey(entry.key),
              numKey: entry.key,
              indexValue: entry.value,
              isNew: isNew,
            );
          }),
        ],
      ),
    );
  }
}

class _MapEntry extends StatefulWidget {
  final int numKey;
  final int indexValue;
  final bool isNew;

  const _MapEntry({
    super.key,
    required this.numKey,
    required this.indexValue,
    required this.isNew,
  });

  @override
  State<_MapEntry> createState() => _MapEntryState();
}

class _MapEntryState extends State<_MapEntry> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.isNew) {
      // Start invisible, animate to full opacity
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _opacity = 1.0);
      });
    } else {
      _opacity = 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rowColor = widget.isNew ? AppColors.primary : AppColors.textPrimary;
    final Widget row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${widget.numKey}',
            style: AppTypography.code(fontSize: 12).copyWith(color: rowColor),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
            child: Text(
              '→',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
          Text(
            '${widget.indexValue}',
            style: AppTypography.code(fontSize: 12).copyWith(color: rowColor),
          ),
        ],
      ),
    );

    if (!widget.isNew) return row;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: _opacity,
      child: row,
    );
  }
}
