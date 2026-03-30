// HTML content extraction utilities — ported from leetcode-bot/leetcode.py
// extract_description(), extract_examples(), extract_constraints(), extract_images().

class HtmlParser {
  static final _tagRegex = RegExp(r'<[^>]+>');
  static final _entityMap = {
    '&lt;': '<',
    '&gt;': '>',
    '&amp;': '&',
    '&quot;': '"',
    '&#39;': "'",
    '&nbsp;': ' ',
    '&le;': '\u2264',
    '&ge;': '\u2265',
    '&ne;': '\u2260',
  };

  /// Strips HTML tags and decodes entities.
  static String stripHtml(String html) {
    var text = html.replaceAll(RegExp(r'<br\s*/?>'), '\n');
    text = text.replaceAll(RegExp(r'<p>'), '\n');
    text = text.replaceAll(RegExp(r'</p>'), '');
    text = text.replaceAll(_tagRegex, '');
    for (final entry in _entityMap.entries) {
      text = text.replaceAll(entry.key, entry.value);
    }
    text = text.replaceAllMapped(RegExp(r'&#(\d+);'), (match) {
      final code = int.tryParse(match.group(1)!);
      return code != null ? String.fromCharCode(code) : match.group(0)!;
    });
    return text.trim();
  }

  /// Extracts the problem description (paragraphs before "Example" or "Constraints").
  static String extractDescription(String content) {
    final stopPatterns = [
      RegExp(r'<p><strong[^>]*>Example', caseSensitive: false),
      RegExp(r'<p><strong[^>]*>Constraints', caseSensitive: false),
      RegExp(r'<div class="example', caseSensitive: false),
      RegExp(r'<p>\s*<strong>Example', caseSensitive: false),
    ];
    var endIndex = content.length;
    for (final pattern in stopPatterns) {
      final match = pattern.firstMatch(content);
      if (match != null && match.start < endIndex) {
        endIndex = match.start;
      }
    }
    return content.substring(0, endIndex).trim();
  }

  /// Extracts example blocks from LeetCode HTML content.
  static List<String> extractExamples(String content) {
    final examples = <String>[];

    // Pattern 1: <div class="example-block">
    final divPattern = RegExp(
      r'<div class="example-block"[^>]*>(.*?)</div>',
      dotAll: true,
    );
    for (final match in divPattern.allMatches(content)) {
      examples.add(stripHtml(match.group(1)!));
    }
    if (examples.isNotEmpty) return examples;

    // Pattern 2: <pre> blocks
    final prePattern = RegExp(r'<pre>(.*?)</pre>', dotAll: true);
    for (final match in prePattern.allMatches(content)) {
      examples.add(stripHtml(match.group(1)!));
    }
    return examples;
  }

  /// Extracts constraint <li> items.
  static List<String> extractConstraints(String content) {
    // Find the Constraints section
    final constraintStart = RegExp(
      r'<p><strong>Constraints:?</strong>',
      caseSensitive: false,
    ).firstMatch(content);
    if (constraintStart == null) return [];

    final section = content.substring(constraintStart.start);
    final liPattern = RegExp(r'<li>(.*?)</li>', dotAll: true);
    return liPattern
        .allMatches(section)
        .map((m) => stripHtml(m.group(1)!))
        .toList();
  }

  /// Extracts image URLs from <img> tags.
  static List<String> extractImages(String content) {
    final imgPattern = RegExp(r'<img[^>]+src="([^"]+)"');
    return imgPattern
        .allMatches(content)
        .map((m) => m.group(1)!)
        .where((url) => url.contains('jpeg') || url.contains('jpg') || url.contains('png'))
        .toList();
  }
}
