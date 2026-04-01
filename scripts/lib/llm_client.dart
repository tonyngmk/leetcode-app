import 'dart:convert';
import 'package:http/http.dart' as http;

/// Wrapper around Claude API for generating visualization steps.
abstract class LLMClient {
  static const _apiUrl = 'https://api.anthropic.com/v1/messages';
  static const _model = 'claude-opus-4-6';

  /// Calls Claude API to generate steps.
  /// Returns raw JSON string (array of step objects).
  /// Throws on API error or parse failure.
  static Future<String> generateSteps(
    String apiKey,
    String prompt, {
    bool verbose = false,
  }) async {
    if (verbose) print('  Calling Claude API...');

    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json',
      },
      body: jsonEncode({
        'model': _model,
        'max_tokens': 4096,
        'system': _systemPrompt,
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw 'API error ${response.statusCode}: ${response.body}';
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final content = data['content'] as List?;
    if (content == null || content.isEmpty) {
      throw 'Empty response from API';
    }

    final text = (content[0] as Map<String, dynamic>)['text'] as String?;
    if (text == null) {
      throw 'No text in API response';
    }

    // Extract JSON array from response (may be wrapped in markdown)
    final jsonStr = _extractJson(text);
    if (verbose) print('  API response: ${jsonStr.length} chars');

    return jsonStr;
  }

  /// Extracts JSON array from response (handles markdown code blocks).
  static String _extractJson(String text) {
    // Try to find JSON in markdown code block
    final match = RegExp(r'```(?:json)?\s*(\[[\s\S]*?\])\s*```').firstMatch(text);
    if (match != null) {
      return match.group(1)!;
    }

    // Try to find raw JSON array
    final arrayMatch = RegExp(r'(\[[\s\S]*\])').firstMatch(text);
    if (arrayMatch != null) {
      return arrayMatch.group(1)!;
    }

    // Fallback: return as-is
    return text;
  }
}

const _systemPrompt = '''You are an algorithm teaching assistant. Your task is to generate a step-by-step
visualisation of an algorithm for use in a mobile app.

You will be given:
- A problem slug and title
- An algorithm approach name and explanation
- The solution code
- An example input and expected output
- The visualisation template type to use

You must output ONLY a valid JSON array of step objects. Do not include any prose,
markdown fences, or explanation outside the JSON.

Rules:
1. 5 to 12 steps per approach. Fewer is better if the algorithm is clear.
2. Every step must have a "description" field (max 3 lines, max 120 chars each).
3. All pointer/index values must be valid indices into the example input array.
4. State must be internally consistent: e.g. hashMap in step N must be a superset
   of hashMap in step N-1 (entries are never removed mid-algorithm unless the
   algorithm explicitly removes them).
5. The final step must show the correct answer and include a complexity summary.
6. Do not hallucinate intermediate states — trace the algorithm faithfully on the
   given example input.
''';
