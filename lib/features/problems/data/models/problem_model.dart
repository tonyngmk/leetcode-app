import 'topic_tag_model.dart';
import 'code_snippet_model.dart';

/// Full problem detail — from PROBLEM_DETAIL_QUERY.
class Problem {
  final String? questionId;
  final String? questionFrontendId;
  final String title;
  final String titleSlug;
  final String? content;
  final String difficulty;
  final int likes;
  final int dislikes;
  final List<TopicTag> topicTags;
  final List<String> hints;
  final bool isPaidOnly;
  final String? exampleTestcases;
  final String? stats;
  final List<CodeSnippet> codeSnippets;

  const Problem({
    this.questionId,
    this.questionFrontendId,
    required this.title,
    required this.titleSlug,
    this.content,
    required this.difficulty,
    this.likes = 0,
    this.dislikes = 0,
    this.topicTags = const [],
    this.hints = const [],
    this.isPaidOnly = false,
    this.exampleTestcases,
    this.stats,
    this.codeSnippets = const [],
  });

  double get acceptanceRate {
    if (stats == null) return 0;
    try {
      // stats is a JSON string like: {"totalAccepted": "...", "acRate": "49.2%", ...}
      final match = RegExp(r'"acRate"\s*:\s*"([\d.]+)').firstMatch(stats!);
      if (match != null) return double.parse(match.group(1)!);
    } catch (_) {}
    return 0;
  }

  factory Problem.fromJson(Map<String, dynamic> json) {
    return Problem(
      questionId: json['questionId'] as String?,
      questionFrontendId: json['questionFrontendId'] as String?,
      title: json['title'] as String,
      titleSlug: json['titleSlug'] as String,
      content: json['content'] as String?,
      difficulty: json['difficulty'] as String,
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      dislikes: (json['dislikes'] as num?)?.toInt() ?? 0,
      topicTags: (json['topicTags'] as List?)
              ?.map((t) => TopicTag.fromJson(t as Map<String, dynamic>))
              .toList() ??
          [],
      hints: (json['hints'] as List?)?.cast<String>() ?? [],
      isPaidOnly: json['isPaidOnly'] as bool? ?? false,
      exampleTestcases: json['exampleTestcases'] as String?,
      stats: json['stats'] as String?,
      codeSnippets: (json['codeSnippets'] as List?)
              ?.map((s) => CodeSnippet.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'questionFrontendId': questionFrontendId,
        'title': title,
        'titleSlug': titleSlug,
        'content': content,
        'difficulty': difficulty,
        'likes': likes,
        'dislikes': dislikes,
        'topicTags': topicTags.map((t) => t.toJson()).toList(),
        'hints': hints,
        'isPaidOnly': isPaidOnly,
        'exampleTestcases': exampleTestcases,
        'stats': stats,
        'codeSnippets': codeSnippets.map((s) => s.toJson()).toList(),
      };
}
