import '../../data/models/solution_model.dart';

abstract class SolutionsRepository {
  Solution? getSolution(String slug);
  Future<Solution?> getSolutionAsync(String slug);
  Future<bool> hasSolution(String slug);
  Future<void> loadFromAsset();
}
