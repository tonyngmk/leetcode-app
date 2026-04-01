import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/visualization_step.dart';

/// Renders a binary tree with BFS-based positioning.
/// Nodes are circles with values; edges are drawn with CustomPaint.
/// Active nodes highlighted in primary color, visited nodes dimmed.
class TreeVisualizerWidget extends StatelessWidget {
  final TreeStep step;

  const TreeVisualizerWidget({
    super.key,
    required this.step,
  });

  @override
  Widget build(BuildContext context) {
    if (step.nodes.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: Text('Empty tree'),
        ),
      );
    }

    // Find root node (first node, or one with no parent references)
    final rootNode = step.nodes.first;

    // Calculate positions via BFS
    final positions = _calculatePositions(step.nodes, rootNode.id);

    // Find bounds to constrain canvas
    double minX = double.infinity, maxX = double.negativeInfinity;
    double minY = double.infinity, maxY = double.negativeInfinity;
    for (final pos in positions.values) {
      minX = minX > pos.dx ? pos.dx : minX;
      maxX = maxX < pos.dx ? pos.dx : maxX;
      minY = minY > pos.dy ? pos.dy : minY;
      maxY = maxY < pos.dy ? pos.dy : maxY;
    }

    // Add padding
    const nodePadding = 40.0;
    minX -= nodePadding;
    maxX += nodePadding;
    minY -= nodePadding;
    maxY += nodePadding;

    final width = maxX - minX;
    final height = maxY - minY;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: SizedBox(
          width: width,
          height: height,
          child: Stack(
            children: [
              // Draw edges
              CustomPaint(
                painter: _TreeEdgePainter(
                  nodes: step.nodes,
                  positions: positions,
                  highlightedEdges: step.highlightedEdges,
                  minX: minX,
                  minY: minY,
                ),
                size: Size(width, height),
              ),
              // Draw nodes
              ...step.nodes.map((node) {
                final pos = positions[node.id]!;
                final isHighlighted = step.callStack.contains(node.id);
                return Positioned(
                  left: pos.dx - minX - 20, // 20 = circle radius
                  top: pos.dy - minY - 20,
                  child: _TreeNodeWidget(
                    value: node.value,
                    highlighted: isHighlighted,
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  /// BFS-based tree layout: positions nodes by level and sibling index.
  Map<int, Offset> _calculatePositions(
    List<VisTreeNode> nodes,
    int rootId,
  ) {
    final nodeMap = {for (final n in nodes) n.id: n};
    final positions = <int, Offset>{};

    // BFS to assign (level, siblingIndex)
    final queue = <(int id, int level, int siblingIndex)>[];
    queue.add((rootId, 0, 0));
    final levelSiblings = <int, int>{}; // level → max sibling index

    while (queue.isNotEmpty) {
      final (id, level, siblingIndex) = queue.removeAt(0);
      levelSiblings[level] = siblingIndex;

      final node = nodeMap[id];
      if (node == null) continue;

      // Position: level determines Y, sibling index determines X
      const levelHeight = 80.0;
      const nodeSpacing = 80.0;
      final y = level * levelHeight + 40;
      final x = siblingIndex * nodeSpacing + 40;
      positions[id] = Offset(x, y);

      // Enqueue children
      int nextSibling = 0;
      if (node.leftId != null) {
        queue.add((node.leftId!, level + 1, nextSibling));
        nextSibling++;
      }
      if (node.rightId != null) {
        queue.add((node.rightId!, level + 1, nextSibling));
      }
    }

    return positions;
  }
}

/// Paints edges between parent and child nodes.
class _TreeEdgePainter extends CustomPainter {
  final List<VisTreeNode> nodes;
  final Map<int, Offset> positions;
  final List<(int, int)> highlightedEdges;
  final double minX;
  final double minY;

  _TreeEdgePainter({
    required this.nodes,
    required this.positions,
    required this.highlightedEdges,
    required this.minX,
    required this.minY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final node in nodes) {
      final parentPos = positions[node.id];
      if (parentPos == null) continue;

      if (node.leftId != null) {
        _drawEdge(
          canvas,
          parentPos,
          positions[node.leftId]!,
          isHighlighted:
              highlightedEdges.any((e) => e.$1 == node.id && e.$2 == node.leftId),
        );
      }

      if (node.rightId != null) {
        _drawEdge(
          canvas,
          parentPos,
          positions[node.rightId]!,
          isHighlighted: highlightedEdges
              .any((e) => e.$1 == node.id && e.$2 == node.rightId),
        );
      }
    }
  }

  void _drawEdge(
    Canvas canvas,
    Offset from,
    Offset to, {
    required bool isHighlighted,
  }) {
    final paint = Paint()
      ..color = isHighlighted ? AppColors.primary : AppColors.divider
      ..strokeWidth = isHighlighted ? 3 : 1;

    canvas.drawLine(
      Offset(from.dx - minX, from.dy - minY),
      Offset(to.dx - minX, to.dy - minY),
      paint,
    );
  }

  @override
  bool shouldRepaint(_TreeEdgePainter oldDelegate) => true;
}

/// Individual tree node: circle with value inside.
class _TreeNodeWidget extends StatelessWidget {
  final int value;
  final bool highlighted;

  const _TreeNodeWidget({
    required this.value,
    required this.highlighted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: highlighted ? AppColors.primary : AppColors.divider,
          width: highlighted ? 2 : 1,
        ),
        color: highlighted
            ? AppColors.primary.withValues(alpha: 0.15)
            : AppColors.card,
      ),
      alignment: Alignment.center,
      child: Text(
        '$value',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: highlighted ? AppColors.primary : AppColors.textPrimary,
              fontWeight: highlighted ? FontWeight.w600 : FontWeight.normal,
            ),
      ),
    );
  }
}
