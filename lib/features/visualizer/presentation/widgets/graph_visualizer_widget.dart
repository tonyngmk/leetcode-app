import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/theme/app_colors.dart';
import '../../domain/visualization_step.dart';

/// Renders a graph with nodes at fixed coordinates and directed/undirected edges.
/// Nodes are circles; edges are drawn with CustomPaint.
class GraphVisualizerWidget extends StatelessWidget {
  final GraphStep step;

  const GraphVisualizerWidget({
    super.key,
    required this.step,
  });

  @override
  Widget build(BuildContext context) {
    if (step.nodes.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: Text('Empty graph'),
        ),
      );
    }

    // Find bounds
    double minX = double.infinity, maxX = double.negativeInfinity;
    double minY = double.infinity, maxY = double.negativeInfinity;
    for (final node in step.nodes) {
      minX = minX > node.x ? node.x : minX;
      maxX = maxX < node.x ? node.x : maxX;
      minY = minY > node.y ? node.y : minY;
      maxY = maxY < node.y ? node.y : maxY;
    }

    const padding = 60.0;
    minX -= padding;
    maxX += padding;
    minY -= padding;
    maxY += padding;

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
                painter: _GraphEdgePainter(
                  edges: step.edges,
                  nodes: step.nodes,
                  minX: minX,
                  minY: minY,
                ),
                size: Size(width, height),
              ),
              // Draw nodes
              ...step.nodes.map((node) {
                final isActive = step.activeId == node.id;
                final isVisited = step.visitedIds.contains(node.id);
                return Positioned(
                  left: node.x - minX - 20,
                  top: node.y - minY - 20,
                  child: _GraphNodeWidget(
                    label: node.label,
                    active: isActive,
                    visited: isVisited,
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

/// Paints edges between graph nodes with arrow heads for directed edges.
class _GraphEdgePainter extends CustomPainter {
  final List<VisGraphEdge> edges;
  final List<VisGraphNode> nodes;
  final double minX;
  final double minY;

  _GraphEdgePainter({
    required this.edges,
    required this.nodes,
    required this.minX,
    required this.minY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final nodeMap = {for (final n in nodes) n.id: n};

    for (final edge in edges) {
      final fromNode = nodeMap[edge.fromId];
      final toNode = nodeMap[edge.toId];
      if (fromNode == null || toNode == null) continue;

      final fromPos = Offset(fromNode.x - minX, fromNode.y - minY);
      final toPos = Offset(toNode.x - minX, toNode.y - minY);

      final paint = Paint()
        ..color = edge.highlighted ? AppColors.primary : AppColors.divider
        ..strokeWidth = edge.highlighted ? 2 : 1;

      // Draw line, stopping short of node centers for cleaner look
      const nodeRadius = 20.0;
      final direction = toPos - fromPos;
      final distance = direction.distance;
      final unitDir = direction / distance;

      final startPos = fromPos + unitDir * nodeRadius;
      final endPos = toPos - unitDir * nodeRadius;

      canvas.drawLine(startPos, endPos, paint);

      // Draw arrowhead for directed edges
      if (edge.directed) {
        _drawArrow(canvas, endPos, unitDir, paint);
      }
    }
  }

  void _drawArrow(
    Canvas canvas,
    Offset pos,
    Offset direction,
    Paint paint,
  ) {
    const arrowSize = 8.0;
    const arrowAngle = math.pi / 6; // 30 degrees

    final angle = math.atan2(direction.dy, direction.dx);
    final p1 = Offset(
      pos.dx - arrowSize * math.cos(angle - arrowAngle),
      pos.dy - arrowSize * math.sin(angle - arrowAngle),
    );
    final p2 = Offset(
      pos.dx - arrowSize * math.cos(angle + arrowAngle),
      pos.dy - arrowSize * math.sin(angle + arrowAngle),
    );

    canvas.drawLine(pos, p1, paint);
    canvas.drawLine(pos, p2, paint);
  }

  @override
  bool shouldRepaint(_GraphEdgePainter oldDelegate) => true;
}

/// Individual graph node: circle with label inside.
class _GraphNodeWidget extends StatelessWidget {
  final String label;
  final bool active;
  final bool visited;

  const _GraphNodeWidget({
    required this.label,
    required this.active,
    required this.visited,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor, borderColor, textColor;

    if (active) {
      bgColor = AppColors.primary.withValues(alpha: 0.25);
      borderColor = AppColors.primary;
      textColor = AppColors.primary;
    } else if (visited) {
      bgColor = AppColors.medium.withValues(alpha: 0.15);
      borderColor = AppColors.medium;
      textColor = AppColors.textPrimary;
    } else {
      bgColor = AppColors.card;
      borderColor = AppColors.divider;
      textColor = AppColors.textPrimary;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: active ? 2 : 1,
        ),
        color: bgColor,
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: active ? FontWeight.w600 : FontWeight.normal,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
