import 'visualization_step.dart';

/// Domain model for a problem's full visualisation data.
/// Mirrors the top-level entry in visualization_cache.json.
class ProblemVisualization {
  final String slug;
  final String type;
  final bool supported;
  final List<VisualizationApproach> approaches;

  const ProblemVisualization({
    required this.slug,
    required this.type,
    required this.supported,
    required this.approaches,
  });

  factory ProblemVisualization.fromJson(String slug, Map<String, dynamic> json) {
    final type = json['type'] as String? ?? 'unsupported';
    final supported = json['supported'] as bool? ?? false;

    return ProblemVisualization(
      slug: slug,
      type: type,
      supported: supported,
      approaches: supported
          ? (json['approaches'] as List? ?? [])
              .map((a) => VisualizationApproach.fromJson(
                    Map<String, dynamic>.from(a as Map),
                    type,
                  ))
              .toList()
          : const [],
    );
  }

  /// Returns steps for the given approach index, or empty list if out of range.
  List<VisualizationStep> stepsForApproach(int index) {
    if (!supported || index < 0 || index >= approaches.length) return const [];
    return approaches[index].steps;
  }
}

/// A single approach within a [ProblemVisualization].
class VisualizationApproach {
  final String name;
  final List<VisualizationStep> steps;

  const VisualizationApproach({required this.name, required this.steps});

  factory VisualizationApproach.fromJson(Map<String, dynamic> json, String type) {
    // Array is stored at the approach level and injected into each step.
    final rawArray = json['array'] as List? ?? [];
    final array = rawArray.cast<int>();

    return VisualizationApproach(
      name: json['name'] as String? ?? '',
      steps: (json['steps'] as List? ?? []).map((s) {
        final stepJson = Map<String, dynamic>.from(s as Map);
        // Inject the approach-level array into each step so steps are self-contained.
        if (!stepJson.containsKey('array')) {
          stepJson['array'] = array;
        }
        return VisualizationStep.fromJson(stepJson, type);
      }).toList(),
    );
  }
}
