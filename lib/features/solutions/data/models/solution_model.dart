/// Solution with multiple approaches — mirrors solution_cache.json structure.
class Solution {
  final String slug;
  final List<SolutionApproach> approaches;

  const Solution({required this.slug, required this.approaches});

  factory Solution.fromJson(Map<String, dynamic> json) {
    return Solution(
      slug: json['slug'] as String? ?? '',
      approaches: (json['approaches'] as List?)
              ?.map((a) => SolutionApproach.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'slug': slug,
        'approaches': approaches.map((a) => a.toJson()).toList(),
      };
}

class SolutionApproach {
  final String name;
  final String explanation;
  final String timeComplexity;
  final String spaceComplexity;
  final Map<String, String> code;

  const SolutionApproach({
    required this.name,
    required this.explanation,
    required this.timeComplexity,
    required this.spaceComplexity,
    required this.code,
  });

  factory SolutionApproach.fromJson(Map<String, dynamic> json) {
    final codeMap = <String, String>{};
    final rawCode = json['code'];
    if (rawCode is Map) {
      for (final entry in rawCode.entries) {
        codeMap[entry.key as String] = entry.value as String;
      }
    }
    return SolutionApproach(
      name: json['name'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
      timeComplexity: json['time_complexity'] as String? ?? '',
      spaceComplexity: json['space_complexity'] as String? ?? '',
      code: codeMap,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'explanation': explanation,
        'time_complexity': timeComplexity,
        'space_complexity': spaceComplexity,
        'code': code,
      };
}
