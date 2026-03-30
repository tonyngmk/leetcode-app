import 'topic_tag_model.dart';

/// Lightweight problem from PROBLEMS_QUERY list response.
class ProblemListItem {
  final String questionFrontendId;
  final String title;
  final String titleSlug;
  final String difficulty;
  final double acRate;
  final bool isPaidOnly;
  final List<TopicTag> topicTags;

  const ProblemListItem({
    required this.questionFrontendId,
    required this.title,
    required this.titleSlug,
    required this.difficulty,
    required this.acRate,
    this.isPaidOnly = false,
    this.topicTags = const [],
  });

  factory ProblemListItem.fromJson(Map<String, dynamic> json) {
    return ProblemListItem(
      questionFrontendId: json['questionFrontendId'] as String,
      title: json['title'] as String,
      titleSlug: json['titleSlug'] as String,
      difficulty: json['difficulty'] as String,
      acRate: (json['acRate'] as num).toDouble(),
      isPaidOnly: json['isPaidOnly'] as bool? ?? false,
      topicTags: (json['topicTags'] as List?)
              ?.map((t) => TopicTag.fromJson(t as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class ProblemListResponse {
  final int total;
  final List<ProblemListItem> questions;

  const ProblemListResponse({required this.total, required this.questions});

  factory ProblemListResponse.fromJson(Map<String, dynamic> json) {
    final list = json['problemsetQuestionList'] as Map<String, dynamic>;
    return ProblemListResponse(
      total: list['total'] as int,
      questions: (list['questions'] as List)
          .map((q) => ProblemListItem.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }
}
