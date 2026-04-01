import '../../domain/problem_visualization.dart';
import '../../domain/repositories/visualization_repository.dart';
import '../datasources/visualization_local_datasource.dart';

class VisualizationRepositoryImpl implements VisualizationRepository {
  final VisualizationLocalDataSource _local;

  VisualizationRepositoryImpl({required VisualizationLocalDataSource local})
      : _local = local;

  @override
  Future<ProblemVisualization?> getVisualization(String slug) =>
      _local.getVisualization(slug);

  @override
  Future<bool> hasVisualization(String slug) => _local.hasVisualization(slug);
}
