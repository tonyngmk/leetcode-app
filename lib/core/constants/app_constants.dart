/// App-wide constants — ported from leetcode-bot/config.py
abstract final class AppConstants {
  static const defaultTimezone = 'Asia/Singapore';
  static const fetchDelayMs = 1000;
  static const maxPollAttempts = 20;
  static const pollIntervalMs = 1500;

  // Pagination
  static const problemsPageSize = 20;

  // Search debounce
  static const searchDebounceMs = 300;

  // Animation durations
  static const animDurationFast = Duration(milliseconds: 200);
  static const animDurationNormal = Duration(milliseconds: 300);
  static const animDurationSlow = Duration(milliseconds: 350);

  /// LeetCode submission status codes
  static const statusCodes = <int, String>{
    10: 'Accepted',
    11: 'Wrong Answer',
    12: 'Memory Limit Exceeded',
    13: 'Output Limit Exceeded',
    14: 'Time Limit Exceeded',
    15: 'Runtime Error',
    20: 'Compile Error',
  };

  /// Language slug → display name
  static const langSlugs = <String, String>{
    'python3': 'Python3',
    'python': 'Python',
    'java': 'Java',
    'cpp': 'C++',
    'c': 'C',
    'csharp': 'C#',
    'javascript': 'JavaScript',
    'typescript': 'TypeScript',
    'go': 'Go',
    'ruby': 'Ruby',
    'swift': 'Swift',
    'kotlin': 'Kotlin',
    'rust': 'Rust',
    'scala': 'Scala',
    'php': 'PHP',
    'dart': 'Dart',
    'racket': 'Racket',
    'erlang': 'Erlang',
    'elixir': 'Elixir',
  };

  /// Difficulty emojis for display
  static const difficultyEmoji = <String, String>{
    'Easy': '\u{1f7e2}',
    'Medium': '\u{1f7e0}',
    'Hard': '\u{1f534}',
  };

  /// Popular topic tags for filter chips
  static const topicTags = [
    'Array',
    'String',
    'Hash Table',
    'Dynamic Programming',
    'Math',
    'Sorting',
    'Greedy',
    'Depth-First Search',
    'Binary Search',
    'Tree',
    'Breadth-First Search',
    'Matrix',
    'Two Pointers',
    'Stack',
    'Graph',
    'Linked List',
    'Heap (Priority Queue)',
    'Sliding Window',
    'Backtracking',
    'Recursion',
  ];
}
