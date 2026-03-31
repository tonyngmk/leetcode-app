import '../../domain/repositories/solutions_repository.dart';
import '../datasources/solutions_local_datasource.dart';
import '../models/solution_model.dart';

class SolutionsRepositoryImpl implements SolutionsRepository {
  final SolutionsLocalDataSource _local;

  SolutionsRepositoryImpl({required SolutionsLocalDataSource local}) : _local = local;

  @override
  Solution? getSolution(String slug) => _local.getSolution(slug);

  @override
  Future<Solution?> getSolutionAsync(String slug) => _local.getSolutionAsync(slug);

  @override
  Future<bool> hasSolution(String slug) => _local.hasSolution(slug);

  @override
  Future<void> loadFromAsset() async {
    // Now a no-op since loading is lazy, kept for API compatibility
  }
}
