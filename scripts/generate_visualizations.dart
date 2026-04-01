#!/usr/bin/env dart
/// CLI tool to generate algorithm visualization steps using Claude API.
///
/// Usage:
///   dart scripts/generate_visualizations.dart --type array_basic
///   dart scripts/generate_visualizations.dart --slug two-sum
///   dart scripts/generate_visualizations.dart --all

import 'dart:io';
import 'dart:convert';
import 'package:args/args.dart';
import 'lib/problem_classifier.dart';
import 'lib/llm_client.dart';
import 'lib/prompt_builder.dart';
import 'lib/step_validator.dart';
import 'lib/cache_writer.dart';

Future<void> main(List<String> args) async {
  final parser = ArgParser()
    ..addOption('type', help: 'Template type: array_basic, two_pointer, etc.')
    ..addOption('slug', help: 'Single problem slug to generate')
    ..addFlag('all', help: 'Generate for all target problems', negatable: false)
    ..addOption('api-key', help: 'Claude API key (or use CLAUDE_API_KEY env var)')
    ..addFlag('dry-run', help: 'Validate only, do not write', negatable: false)
    ..addFlag('verbose', help: 'Verbose logging', negatable: false)
    ..addFlag('help', help: 'Show help', negatable: false);

  try {
    final results = parser.parse(args);

    if (results['help'] as bool) {
      print(parser.usage);
      exit(0);
    }

    final apiKey = results['api-key'] as String? ??
        Platform.environment['CLAUDE_API_KEY'];
    if (apiKey == null) {
      print('Error: Claude API key required. Set CLAUDE_API_KEY or use --api-key');
      exit(1);
    }

    final verbose = results['verbose'] as bool;
    final dryRun = results['dry-run'] as bool;
    final typeFilter = results['type'] as String?;
    final slugFilter = results['slug'] as String?;
    final generateAll = results['all'] as bool;

    if (!generateAll && typeFilter == null && slugFilter == null) {
      print('Error: specify --type, --slug, or --all');
      print(parser.usage);
      exit(1);
    }

    if (verbose) print('Loading configuration...');

    final solutionCache = await _loadSolutionCache();
    final targetSlugs = await _loadTargetSlugs(typeFilter);
    final classifierOverrides = await _loadClassifierOverrides();

    int generated = 0;
    int validated = 0;
    int failed = 0;

    // Filter to specific slug if provided
    final slugsToProcess = slugFilter != null
        ? [slugFilter]
        : generateAll
            ? targetSlugs
            : targetSlugs;

    for (final slug in slugsToProcess) {
      if (verbose) print('\n--- Processing: $slug ---');

      // Load solution data
      final solutionData = solutionCache[slug];
      if (solutionData == null) {
        if (verbose) print('Warning: solution not found for $slug');
        continue;
      }

      // Load or infer problem metadata
      final problemMetadata = await _loadProblemMetadata(slug);
      if (problemMetadata == null) {
        if (verbose) print('Warning: problem metadata not found for $slug');
        continue;
      }

      // Classify problem type
      final templateType = classifierOverrides[slug] ??
          ProblemClassifier.classify(
            topicTags: problemMetadata['topicTags'] as List<String>? ?? [],
            slug: slug,
            title: problemMetadata['title'] as String? ?? '',
          );

      if (typeFilter != null && templateType != typeFilter) {
        if (verbose) print('Skipping: template type $templateType != $typeFilter');
        continue;
      }

      // Generate steps for each approach
      final approaches = solutionData['approaches'] as List? ?? [];
      final generatedApproaches = <Map<String, dynamic>>[];

      for (int i = 0; i < approaches.length; i++) {
        final approach = approaches[i] as Map;
        final approachName = approach['name'] as String? ?? '';

        if (verbose) print('  Approach $i: $approachName');

        try {
          final prompt = PromptBuilder.buildPrompt(
            slug: slug,
            title: problemMetadata['title'] as String? ?? '',
            approach: approach,
            templateType: templateType,
            exampleTestcases:
                problemMetadata['exampleTestcases'] as String? ?? '',
          );

          if (verbose && prompt.length > 500) {
            print('  Prompt length: ${prompt.length} chars');
          }

          final rawJson =
              await LLMClient.generateSteps(apiKey, prompt, verbose: verbose);

          // Parse steps
          final stepsData = jsonDecode(rawJson) as List;
          final steps = stepsData.cast<Map<String, dynamic>>();

          // Validate
          final isValid = StepValidator.validate(steps, templateType, verbose: verbose);
          if (!isValid) {
            print('  ❌ Validation failed for $approachName');
            failed++;
            continue;
          }

          generatedApproaches.add({
            'name': approachName,
            'array': problemMetadata['exampleArray'] ?? [2, 7, 11, 15],
            'steps': steps,
          });

          validated++;
          if (verbose) print('  ✓ Validated');
        } catch (e) {
          print('  ❌ Error: $e');
          failed++;
        }
      }

      // Write to cache
      if (generatedApproaches.isNotEmpty && !dryRun) {
        await CacheWriter.write(
          slug: slug,
          templateType: templateType,
          approaches: generatedApproaches,
          dryRun: dryRun,
        );
        generated++;
        if (verbose) print('✓ Wrote to visualization_cache.json');
      }
    }

    print(
        '\n=== Summary ===\nGenerated: $generated\nValidated: $validated\nFailed: $failed');
    if (dryRun) print('(dry-run mode — no files written)');
  } on FormatException catch (e) {
    print('Error: ${e.message}');
    exit(1);
  }
}

Future<Map<String, dynamic>> _loadSolutionCache() async {
  final file = File('assets/solution_cache.json');
  if (!await file.exists()) {
    throw 'solution_cache.json not found. Run from project root.';
  }
  return jsonDecode(await file.readAsString()) as Map<String, dynamic>;
}

Future<List<String>> _loadTargetSlugs(String? typeFilter) async {
  final file = File('scripts/data/array_target_slugs.txt');
  if (!await file.exists()) {
    // Fallback: return just two-sum for testing
    return ['two-sum'];
  }
  final lines = await file.readAsLines();
  return lines
      .where((line) => line.trim().isNotEmpty && !line.startsWith('#'))
      .toList();
}

Future<Map<String, String>> _loadClassifierOverrides() async {
  final file = File('scripts/data/classifier_overrides.json');
  if (!await file.exists()) return {};
  final data = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
  return data.cast<String, String>();
}

/// Load problem metadata from fixture or future API call.
Future<Map<String, dynamic>?> _loadProblemMetadata(String slug) async {
  // Hardcode two-sum for now; in Phase 3 extend to fetch from API or fixture.
  final metadata = {
    'two-sum': {
      'title': 'Two Sum',
      'topicTags': ['array', 'hash-table'],
      'exampleTestcases': '[2,7,11,15]\n9',
      'exampleArray': [2, 7, 11, 15],
      'target': 9,
    },
  };
  return metadata[slug];
}
