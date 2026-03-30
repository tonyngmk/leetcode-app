import '../../domain/repositories/solutions_repository.dart';
import '../datasources/solutions_local_datasource.dart';
import '../models/solution_model.dart';

class SolutionsRepositoryImpl implements SolutionsRepository {
  final SolutionsLocalDataSource _local;

  SolutionsRepositoryImpl({required SolutionsLocalDataSource local}) : _local = local;

  @override
  Solution? getSolution(String slug) => _local.getSolution(slug);

  @override
  bool hasSolution(String slug) => _local.hasSolution(slug);

  @override
  Future<void> loadFromAsset() => _local.loadFromAsset();
}
