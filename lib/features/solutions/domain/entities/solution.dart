/// Domain entity for a solution — mirrors the solution cache schema.
/// Kept separate from the data model per Clean Architecture layers.
class SolutionEntity {
  final String slug;
  final List<SolutionApproachEntity> approaches;

  const SolutionEntity({required this.slug, required this.approaches});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SolutionEntity &&
          runtimeType == other.runtimeType &&
          slug == other.slug &&
          approaches.length == other.approaches.length &&
          _listEquals(approaches, other.approaches);

  @override
  int get hashCode => slug.hashCode;

  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

class SolutionApproachEntity {
  final String name;
  final String explanation;
  final String timeComplexity;
  final String spaceComplexity;
  final Map<String, String> code;

  const SolutionApproachEntity({
    required this.name,
    required this.explanation,
    required this.timeComplexity,
    required this.spaceComplexity,
    required this.code,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SolutionApproachEntity &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          explanation == other.explanation &&
          timeComplexity == other.timeComplexity &&
          spaceComplexity == other.spaceComplexity;

  @override
  int get hashCode =>
      name.hashCode ^
      explanation.hashCode ^
      timeComplexity.hashCode ^
      spaceComplexity.hashCode;
}
