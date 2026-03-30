/// User profile — from USER_PROFILE_QUERY response.
class UserProfile {
  final String username;
  final Map<String, int> counts; // {Easy: N, Medium: N, Hard: N}
  final List<RecentSubmission> recent;

  const UserProfile({
    required this.username,
    required this.counts,
    this.recent = const [],
  });

  int get totalSolved => counts.values.fold(0, (a, b) => a + b);

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final user = json['matchedUser'] as Map<String, dynamic>;
    final stats = user['submitStats'] as Map<String, dynamic>;
    final acNums = stats['acSubmissionNum'] as List;
    final counts = <String, int>{};
    for (final item in acNums) {
      final m = item as Map<String, dynamic>;
      final diff = m['difficulty'] as String;
      if (diff != 'All') {
        counts[diff] = (m['count'] as num).toInt();
      }
    }

    final recentList = (json['recentSubmissionList'] as List?)
            ?.map((s) => RecentSubmission.fromJson(s as Map<String, dynamic>))
            .toList() ??
        [];

    return UserProfile(
      username: user['username'] as String,
      counts: counts,
      recent: recentList,
    );
  }
}

class RecentSubmission {
  final String title;
  final String titleSlug;
  final int timestamp;
  final String statusDisplay;

  const RecentSubmission({
    required this.title,
    required this.titleSlug,
    required this.timestamp,
    required this.statusDisplay,
  });

  bool get isAccepted => statusDisplay == 'Accepted';

  factory RecentSubmission.fromJson(Map<String, dynamic> json) {
    return RecentSubmission(
      title: json['title'] as String,
      titleSlug: json['titleSlug'] as String,
      timestamp: int.parse(json['timestamp'] as String),
      statusDisplay: json['statusDisplay'] as String,
    );
  }
}

class AcSubmission {
  final String id;
  final String title;
  final String titleSlug;
  final int timestamp;

  const AcSubmission({
    required this.id,
    required this.title,
    required this.titleSlug,
    required this.timestamp,
  });

  factory AcSubmission.fromJson(Map<String, dynamic> json) {
    return AcSubmission(
      id: json['id'] as String,
      title: json['title'] as String,
      titleSlug: json['titleSlug'] as String,
      timestamp: int.parse(json['timestamp'] as String),
    );
  }
}
