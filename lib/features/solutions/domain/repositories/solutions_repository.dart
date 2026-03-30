import '../../data/models/solution_model.dart';

abstract class SolutionsRepository {
  Solution? getSolution(String slug);
  bool hasSolution(String slug);
  Future<void> loadFromAsset();
}
