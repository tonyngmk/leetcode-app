import 'package:flutter_test/flutter_test.dart';
import 'package:algoflow/features/problems/data/models/problem_list_item_model.dart';

void main() {
  group('ProblemListItem.fromJson', () {
    test('parses valid JSON from API', () {
      final json = <String, dynamic>{
        'questionFrontendId': '1',
        'title': 'Two Sum',
        'titleSlug': 'two-sum',
        'difficulty': 'Easy',
        'acRate': 45.5,
        'isPaidOnly': false,
        'topicTags': [
          {'name': 'Array', 'slug': 'array'},
          {'name': 'Hash Table', 'slug': 'hash-table'},
        ],
      };

      final item = ProblemListItem.fromJson(json);

      expect(item.questionFrontendId, '1');
      expect(item.title, 'Two Sum');
      expect(item.titleSlug, 'two-sum');
      expect(item.difficulty, 'Easy');
      expect(item.acRate, 45.5);
      expect(item.isPaidOnly, false);
      expect(item.topicTags, hasLength(2));
      expect(item.topicTags[0].name, 'Array');
    });

    /// Critical test: parse with Map<dynamic, dynamic> from Hive
    /// Tests the fix for: `t as Map<String, dynamic>` crashing on nested maps
    test('parses Map<dynamic, dynamic> with nested topic tags from Hive cache', () {
      final hiveData = <dynamic, dynamic>{
        'questionFrontendId': '1',
        'title': 'Two Sum',
        'titleSlug': 'two-sum',
        'difficulty': 'Easy',
        'acRate': 45.5,
        'isPaidOnly': false,
        'topicTags': [
          <dynamic, dynamic>{'name': 'Array', 'slug': 'array'},
          <dynamic, dynamic>{'name': 'Hash Table', 'slug': 'hash-table'},
        ],
      };

      final shallowConverted = Map<String, dynamic>.from(hiveData);

      // Should NOT crash with type cast error
      final item = ProblemListItem.fromJson(shallowConverted);

      expect(item.title, 'Two Sum');
      expect(item.topicTags, hasLength(2));
      expect(item.topicTags[0].name, 'Array');
      expect(item.topicTags[0].slug, 'array');
      expect(item.topicTags[1].name, 'Hash Table');
    });

    test('handles missing topicTags gracefully', () {
      final json = <String, dynamic>{
        'questionFrontendId': '1',
        'title': 'Two Sum',
        'titleSlug': 'two-sum',
        'difficulty': 'Easy',
        'acRate': 45.5,
      };

      final item = ProblemListItem.fromJson(json);

      expect(item.topicTags, isEmpty);
    });
  });

  group('ProblemListResponse.fromJson', () {
    test('parses valid problem list response from API', () {
      final json = <String, dynamic>{
        'problemsetQuestionList': {
          'total': 3200,
          'questions': [
            {
              'questionFrontendId': '1',
              'title': 'Two Sum',
              'titleSlug': 'two-sum',
              'difficulty': 'Easy',
              'acRate': 45.5,
              'isPaidOnly': false,
              'topicTags': [
                {'name': 'Array', 'slug': 'array'},
              ],
            },
            {
              'questionFrontendId': '2',
              'title': 'Add Two Numbers',
              'titleSlug': 'add-two-numbers',
              'difficulty': 'Medium',
              'acRate': 35.2,
              'isPaidOnly': false,
              'topicTags': [
                {'name': 'Linked List', 'slug': 'linked-list'},
              ],
            },
          ],
        },
      };

      final response = ProblemListResponse.fromJson(json);

      expect(response.total, 3200);
      expect(response.questions, hasLength(2));
      expect(response.questions[0].title, 'Two Sum');
      expect(response.questions[1].title, 'Add Two Numbers');
      expect(response.questions[0].topicTags[0].name, 'Array');
    });

    /// Critical test: parse with Map<dynamic, dynamic> from Hive
    /// Tests fixes for multiple cast issues:
    /// 1. `json['problemsetQuestionList'] as Map<String, dynamic>` — line 46
    /// 2. `q as Map<String, dynamic>` on questions list — line 50
    test('parses Map<dynamic, dynamic> problem list response from Hive', () {
      final hiveData = <dynamic, dynamic>{
        'problemsetQuestionList': <dynamic, dynamic>{
          'total': 3200,
          'questions': [
            <dynamic, dynamic>{
              'questionFrontendId': '1',
              'title': 'Two Sum',
              'titleSlug': 'two-sum',
              'difficulty': 'Easy',
              'acRate': 45.5,
              'isPaidOnly': false,
              'topicTags': [
                <dynamic, dynamic>{'name': 'Array', 'slug': 'array'},
              ],
            },
            <dynamic, dynamic>{
              'questionFrontendId': '2',
              'title': 'Add Two Numbers',
              'titleSlug': 'add-two-numbers',
              'difficulty': 'Medium',
              'acRate': 35.2,
              'isPaidOnly': false,
              'topicTags': [
                <dynamic, dynamic>{'name': 'Linked List', 'slug': 'linked-list'},
              ],
            },
          ],
        },
      };

      final shallowConverted = Map<String, dynamic>.from(hiveData);

      // Should NOT crash with type cast error on problemsetQuestionList or questions
      final response = ProblemListResponse.fromJson(shallowConverted);

      expect(response.total, 3200);
      expect(response.questions, hasLength(2));
      expect(response.questions[0].title, 'Two Sum');
      expect(response.questions[0].difficulty, 'Easy');
      expect(response.questions[0].topicTags[0].name, 'Array');
      expect(response.questions[1].title, 'Add Two Numbers');
      expect(response.questions[1].topicTags[0].name, 'Linked List');
    });

    test('parses problem list with empty questions', () {
      final json = <String, dynamic>{
        'problemsetQuestionList': {
          'total': 0,
          'questions': [],
        },
      };

      final response = ProblemListResponse.fromJson(json);

      expect(response.total, 0);
      expect(response.questions, isEmpty);
    });
  });
}
