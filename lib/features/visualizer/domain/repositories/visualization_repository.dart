import '../problem_visualization.dart';

abstract class VisualizationRepository {
  Future<ProblemVisualization?> getVisualization(String slug);
  Future<bool> hasVisualization(String slug);
}
