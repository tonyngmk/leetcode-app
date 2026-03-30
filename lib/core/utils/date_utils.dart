// Date utilities for snapshot-based progress tracking.
// Ported from leetcode-bot/leetcode.py snapshot logic.

class AppDateUtils {
  /// Returns midnight timestamp for the current day in the given timezone offset.
  static DateTime todayMidnight([Duration tzOffset = const Duration(hours: 8)]) {
    final now = DateTime.now().toUtc().add(tzOffset);
    return DateTime.utc(now.year, now.month, now.day).subtract(tzOffset);
  }

  /// Returns Monday midnight of the current week.
  static DateTime weekStart([Duration tzOffset = const Duration(hours: 8)]) {
    final now = DateTime.now().toUtc().add(tzOffset);
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return DateTime.utc(monday.year, monday.month, monday.day).subtract(tzOffset);
  }

  /// Returns the 1st of the current month at midnight.
  static DateTime monthStart([Duration tzOffset = const Duration(hours: 8)]) {
    final now = DateTime.now().toUtc().add(tzOffset);
    return DateTime.utc(now.year, now.month, 1).subtract(tzOffset);
  }

  /// Calculates current streak from a list of AC submission timestamps (sorted desc).
  static int calculateStreak(List<int> timestamps) {
    if (timestamps.isEmpty) return 0;

    final dates = timestamps
        .map((ts) => DateTime.fromMillisecondsSinceEpoch(ts * 1000).toLocal())
        .map((dt) => DateTime(dt.year, dt.month, dt.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    if (dates.isEmpty) return 0;

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final yesterday = todayDate.subtract(const Duration(days: 1));

    // Streak must start from today or yesterday
    if (dates.first != todayDate && dates.first != yesterday) return 0;

    var streak = 1;
    for (var i = 1; i < dates.length; i++) {
      final diff = dates[i - 1].difference(dates[i]).inDays;
      if (diff == 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }
}
