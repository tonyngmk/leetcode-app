import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'dart:math' as math;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/visualization_step.dart';
import 'array_box_widget.dart';

/// Renders a heap as both an array and a tree visualization.
/// Shows structure (complete binary tree) and heap property enforcement.
class HeapVisualizerWidget extends StatelessWidget {
  final HeapStep step;

  const HeapVisualizerWidget({
    super.key,
    required this.step,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Array representation
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.m),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Array View',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const Gap(AppSpacing.s),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < step.arrayView.length; i++) ...[
                    if (i > 0) const Gap(AppSpacing.xs),
                    SizedBox(
                      width: 48,
                      child: ArrayBoxWidget(
                        value: step.arrayView[i],
                        isActive: step.highlightedIndex == i,
                        isResult: false,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        const Divider(),
        const Gap(AppSpacing.m),
        // Tree representation (simplified BFS layout)
        Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Heap Structure',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const Gap(AppSpacing.m),
              _HeapTreeView(
                nodes: step.nodes,
                highlightedIndex: step.highlightedIndex,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Simplified tree visualization for heap nodes.
class _HeapTreeView extends StatelessWidget {
  final List<VisHeapNode> nodes;
  final int? highlightedIndex;

  const _HeapTreeView({
    required this.nodes,
    required this.highlightedIndex,
  });

  @override
  Widget build(BuildContext context) {
    if (nodes.isEmpty) {
      return const Text('Empty heap');
    }

    // Simple tree layout for heaps (BFS-based positioning)
    const levelHeight = 80.0;
    const nodeSpacing = 60.0;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 400,
        height: 300,
        child: Stack(
          children: [
            // Draw edges
            CustomPaint(
              painter: _HeapEdgePainter(nodes: nodes),
              size: const Size(400, 300),
            ),
            // Draw nodes
            ...nodes.asMap().entries.map((entry) {
              final idx = entry.key;
              final node = entry.value;
              final level = _getLevel(idx);
              final siblingIndex = _getSiblingIndex(idx);

              final x = 200.0 + (siblingIndex - 1) * nodeSpacing - 30;
              final y = level * levelHeight + 20;

              return Positioned(
                left: x,
                top: y,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: idx == highlightedIndex
                          ? AppColors.primary
                          : AppColors.divider,
                      width: idx == highlightedIndex ? 2 : 1,
                    ),
                    color: idx == highlightedIndex
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : AppColors.card,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${node.value}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: idx == highlightedIndex
                              ? AppColors.primary
                              : AppColors.textPrimary,
                          fontWeight: idx == highlightedIndex
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  int _getLevel(int index) => (math.log(index + 1) / math.log(2)).floor();

  int _getSiblingIndex(int index) {
    final level = _getLevel(index);
    final levelStart = (1 << level) - 1; // 2^level - 1
    return index - levelStart;
  }
}

/// Paints edges between heap parent and child nodes.
class _HeapEdgePainter extends CustomPainter {
  final List<VisHeapNode> nodes;

  _HeapEdgePainter({required this.nodes});

  @override
  void paint(Canvas canvas, Size size) {
    const levelHeight = 80.0;
    const nodeSpacing = 60.0;
    const centerX = 200.0;

    for (int i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      final parentLevel = _getLevel(i);
      final parentSiblingIndex = _getSiblingIndex(i);
      final parentX = centerX + (parentSiblingIndex - 1) * nodeSpacing;
      final parentY = parentLevel * levelHeight + 20;

      if (node.leftId != null && node.leftId! < nodes.length) {
        final childIdx = node.leftId!;
        final childLevel = _getLevel(childIdx);
        final childSiblingIndex = _getSiblingIndex(childIdx);
        final childX = centerX + (childSiblingIndex - 1) * nodeSpacing;
        final childY = childLevel * levelHeight + 20;

        canvas.drawLine(
          Offset(parentX, parentY),
          Offset(childX, childY),
          Paint()
            ..color = AppColors.divider
            ..strokeWidth = 1,
        );
      }

      if (node.rightId != null && node.rightId! < nodes.length) {
        final childIdx = node.rightId!;
        final childLevel = _getLevel(childIdx);
        final childSiblingIndex = _getSiblingIndex(childIdx);
        final childX = centerX + (childSiblingIndex - 1) * nodeSpacing;
        final childY = childLevel * levelHeight + 20;

        canvas.drawLine(
          Offset(parentX, parentY),
          Offset(childX, childY),
          Paint()
            ..color = AppColors.divider
            ..strokeWidth = 1,
        );
      }
    }
  }

  int _getLevel(int index) => (math.log(index + 1) / math.log(2)).floor();

  int _getSiblingIndex(int index) {
    final level = _getLevel(index);
    final levelStart = (1 << level) - 1;
    return index - levelStart;
  }

  @override
  bool shouldRepaint(_HeapEdgePainter oldDelegate) => true;
}
