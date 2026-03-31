import 'package:flutter_test/flutter_test.dart';
import 'package:algoflow/features/problems/data/models/problem_model.dart';

void main() {
  group('Problem.fromJson', () {
    /// Test parsing with strongly-typed Map<String, dynamic> (direct API response)
    test('parses valid JSON from API', () {
      final json = <String, dynamic>{
        'questionId': '1',
        'questionFrontendId': '1',
        'title': 'Two Sum',
        'titleSlug': 'two-sum',
        'content': '<p>Find two numbers...</p>',
        'difficulty': 'Easy',
        'likes': 5000,
        'dislikes': 100,
        'topicTags': [
          {'name': 'Array', 'slug': 'array'},
          {'name': 'Hash Table', 'slug': 'hash-table'},
        ],
        'hints': ['Hint 1', 'Hint 2'],
        'isPaidOnly': false,
        'exampleTestcases': '[2,7,11,15]\n9',
        'stats': '{"acRate": "49.2%"}',
        'codeSnippets': [
          {
            'lang': 'Python3',
            'langSlug': 'python3',
            'code': 'def twoSum(nums, target): pass',
          },
        ],
      };

      final problem = Problem.fromJson(json);

      expect(problem.title, 'Two Sum');
      expect(problem.titleSlug, 'two-sum');
      expect(problem.difficulty, 'Easy');
      expect(problem.topicTags, hasLength(2));
      expect(problem.topicTags[0].name, 'Array');
      expect(problem.topicTags[0].slug, 'array');
      expect(problem.codeSnippets, hasLength(1));
      expect(problem.codeSnippets[0].lang, 'Python3');
      expect(problem.codeSnippets[0].code, 'def twoSum(nums, target): pass');
      expect(problem.hints, hasLength(2));
    });

    /// Test parsing with Map<dynamic, dynamic> (simulates Hive cache retrieval)
    /// This is the critical test that would have failed before the fix.
    test('parses Map<dynamic, dynamic> from Hive cache (handles nested Map cast)', () {
      // Simulate what Hive returns: Map<dynamic, dynamic> with nested dynamic-keyed maps
      final hiveData = <dynamic, dynamic>{
        'questionId': '1',
        'questionFrontendId': '1',
        'title': 'Two Sum',
        'titleSlug': 'two-sum',
        'content': '<p>Find two numbers...</p>',
        'difficulty': 'Easy',
        'likes': 5000,
        'dislikes': 100,
        // These nested maps simulate what Hive returns — Map<dynamic, dynamic>
        'topicTags': [
          <dynamic, dynamic>{'name': 'Array', 'slug': 'array'},
          <dynamic, dynamic>{'name': 'Hash Table', 'slug': 'hash-table'},
        ],
        'hints': ['Hint 1', 'Hint 2'],
        'isPaidOnly': false,
        'exampleTestcases': '[2,7,11,15]\n9',
        'stats': '{"acRate": "49.2%"}',
        'codeSnippets': [
          <dynamic, dynamic>{
            'lang': 'Python3',
            'langSlug': 'python3',
            'code': 'def twoSum(nums, target): pass',
          },
        ],
      };

      // Simulate datasource's shallow conversion (what Hive cache does)
      final shallowConverted = Map<String, dynamic>.from(hiveData);

      // This should NOT crash with:
      // "type '_Map<dynamic, dynamic>' is not a subtype of type 'Map<String, dynamic>'"
      final problem = Problem.fromJson(shallowConverted);

      expect(problem.title, 'Two Sum');
      expect(problem.titleSlug, 'two-sum');
      expect(problem.topicTags, hasLength(2));
      expect(problem.topicTags[0].name, 'Array');
      expect(problem.topicTags[0].slug, 'array');
      expect(problem.topicTags[1].name, 'Hash Table');
      expect(problem.topicTags[1].slug, 'hash-table');
      expect(problem.codeSnippets, hasLength(1));
      expect(problem.codeSnippets[0].lang, 'Python3');
      expect(problem.codeSnippets[0].langSlug, 'python3');
      expect(problem.codeSnippets[0].code, 'def twoSum(nums, target): pass');
    });

    test('handles missing optional fields gracefully', () {
      final json = <String, dynamic>{
        'title': 'Two Sum',
        'titleSlug': 'two-sum',
        'difficulty': 'Easy',
        // omit optional fields
      };

      final problem = Problem.fromJson(json);

      expect(problem.title, 'Two Sum');
      expect(problem.questionId, isNull);
      expect(problem.content, isNull);
      expect(problem.topicTags, isEmpty);
      expect(problem.hints, isEmpty);
      expect(problem.codeSnippets, isEmpty);
    });

    test('parses complex nested structure with multiple tags and snippets', () {
      final hiveData = <dynamic, dynamic>{
        'title': 'Merge Sorted Array',
        'titleSlug': 'merge-sorted-array',
        'difficulty': 'Medium',
        'topicTags': [
          <dynamic, dynamic>{'name': 'Array', 'slug': 'array'},
          <dynamic, dynamic>{'name': 'Two Pointers', 'slug': 'two-pointers'},
          <dynamic, dynamic>{'name': 'Sorting', 'slug': 'sorting'},
        ],
        'codeSnippets': [
          <dynamic, dynamic>{
            'lang': 'Python3',
            'langSlug': 'python3',
            'code': 'def merge(nums1, m, nums2, n): pass',
          },
          <dynamic, dynamic>{
            'lang': 'Java',
            'langSlug': 'java',
            'code': 'public void merge(int[] nums1, int m, int[] nums2, int n) {}',
          },
          <dynamic, dynamic>{
            'lang': 'C++',
            'langSlug': 'cpp',
            'code': 'void merge(vector<int>& nums1, int m, vector<int>& nums2, int n) {}',
          },
        ],
      };

      final shallowConverted = Map<String, dynamic>.from(hiveData);
      final problem = Problem.fromJson(shallowConverted);

      expect(problem.topicTags, hasLength(3));
      expect(problem.codeSnippets, hasLength(3));
      expect(
        problem.topicTags.map((t) => t.slug),
        ['array', 'two-pointers', 'sorting'],
      );
      expect(
        problem.codeSnippets.map((s) => s.langSlug),
        ['python3', 'java', 'cpp'],
      );
    });
  });
}
