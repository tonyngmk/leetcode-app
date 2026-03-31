import 'package:flutter_test/flutter_test.dart';
import 'package:algoflow/features/solutions/data/models/solution_model.dart';

void main() {
  group('Solution.fromJson', () {
    test('parses valid JSON from API', () {
      final json = <String, dynamic>{
        'slug': 'two-sum',
        'approaches': [
          {
            'name': 'Brute Force',
            'explanation': 'Try all pairs',
            'time_complexity': 'O(n^2)',
            'space_complexity': 'O(1)',
            'code': {
              'python3': 'for i in range(n): ...',
              'java': 'for (int i = 0; i < n; i++) ...',
            },
          },
        ],
      };

      final solution = Solution.fromJson(json);

      expect(solution.slug, 'two-sum');
      expect(solution.approaches, hasLength(1));
      expect(solution.approaches[0].name, 'Brute Force');
      expect(solution.approaches[0].code, {'python3': 'for i in range(n): ...', 'java': 'for (int i = 0; i < n; i++) ...'});
    });

    /// Critical test: parse with Map<dynamic, dynamic> from Hive cache
    /// Tests the fix for: `a as Map<String, dynamic>` crashing on nested approach maps
    test('parses Map<dynamic, dynamic> with nested approaches from Hive cache', () {
      final hiveData = <dynamic, dynamic>{
        'slug': 'two-sum',
        'approaches': [
          <dynamic, dynamic>{
            'name': 'Brute Force',
            'explanation': 'Try all pairs',
            'time_complexity': 'O(n^2)',
            'space_complexity': 'O(1)',
            'code': <dynamic, dynamic>{
              'python3': 'for i in range(n): ...',
              'java': 'for (int i = 0; i < n; i++) ...',
            },
          },
          <dynamic, dynamic>{
            'name': 'Hash Map',
            'explanation': 'Use a hash map for O(1) lookup',
            'time_complexity': 'O(n)',
            'space_complexity': 'O(n)',
            'code': <dynamic, dynamic>{
              'python3': 'seen = {}; ...',
              'java': 'Map<Integer, Integer> map = new HashMap<>(); ...',
            },
          },
        ],
      };

      final shallowConverted = Map<String, dynamic>.from(hiveData);

      // Should NOT crash with type cast error on approaches list
      final solution = Solution.fromJson(shallowConverted);

      expect(solution.slug, 'two-sum');
      expect(solution.approaches, hasLength(2));
      expect(solution.approaches[0].name, 'Brute Force');
      expect(solution.approaches[0].timeComplexity, 'O(n^2)');
      expect(solution.approaches[0].code['python3'], 'for i in range(n): ...');
      expect(solution.approaches[0].code['java'], 'for (int i = 0; i < n; i++) ...');
      expect(solution.approaches[1].name, 'Hash Map');
      expect(solution.approaches[1].timeComplexity, 'O(n)');
      expect(solution.approaches[1].code['python3'], 'seen = {}; ...');
    });

    test('handles missing approaches gracefully', () {
      final json = <String, dynamic>{
        'slug': 'two-sum',
      };

      final solution = Solution.fromJson(json);

      expect(solution.slug, 'two-sum');
      expect(solution.approaches, isEmpty);
    });

    test('handles missing code in approach gracefully', () {
      final json = <String, dynamic>{
        'slug': 'two-sum',
        'approaches': [
          {
            'name': 'Brute Force',
            'explanation': 'Try all pairs',
            'time_complexity': 'O(n^2)',
            'space_complexity': 'O(1)',
            // code is omitted
          },
        ],
      };

      final solution = Solution.fromJson(json);

      expect(solution.approaches[0].code, isEmpty);
    });
  });

  group('SolutionApproach.fromJson', () {
    test('parses valid approach JSON', () {
      final json = <String, dynamic>{
        'name': 'Hash Map',
        'explanation': 'Use a hash map',
        'time_complexity': 'O(n)',
        'space_complexity': 'O(n)',
        'code': {
          'python3': 'seen = {}',
          'java': 'Map<Integer, Integer> map = new HashMap<>();',
        },
      };

      final approach = SolutionApproach.fromJson(json);

      expect(approach.name, 'Hash Map');
      expect(approach.explanation, 'Use a hash map');
      expect(approach.timeComplexity, 'O(n)');
      expect(approach.spaceComplexity, 'O(n)');
      expect(approach.code, hasLength(2));
      expect(approach.code['python3'], 'seen = {}');
    });

    /// Critical test: parse with Map<dynamic, dynamic> code map from Hive
    /// The SolutionApproach.fromJson uses defensive pattern with `is Map` check,
    /// but this test ensures it handles Hive's Map<dynamic, dynamic> correctly
    test('parses Map<dynamic, dynamic> code map from Hive cache', () {
      final hiveData = <dynamic, dynamic>{
        'name': 'Hash Map',
        'explanation': 'Use a hash map',
        'time_complexity': 'O(n)',
        'space_complexity': 'O(n)',
        'code': <dynamic, dynamic>{
          'python3': 'seen = {}',
          'java': 'Map<Integer, Integer> map = new HashMap<>();',
          'cpp': 'std::unordered_map<int, int> map;',
        },
      };

      final shallowConverted = Map<String, dynamic>.from(hiveData);
      final approach = SolutionApproach.fromJson(shallowConverted);

      expect(approach.name, 'Hash Map');
      expect(approach.code, hasLength(3));
      expect(approach.code['python3'], 'seen = {}');
      expect(approach.code['java'], 'Map<Integer, Integer> map = new HashMap<>();');
      expect(approach.code['cpp'], 'std::unordered_map<int, int> map;');
    });

    test('handles missing fields with defaults', () {
      final json = <String, dynamic>{};

      final approach = SolutionApproach.fromJson(json);

      expect(approach.name, '');
      expect(approach.explanation, '');
      expect(approach.timeComplexity, '');
      expect(approach.spaceComplexity, '');
      expect(approach.code, isEmpty);
    });
  });
}
