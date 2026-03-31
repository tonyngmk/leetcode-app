import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:algoflow/core/network/auth_interceptor.dart';
import 'package:algoflow/features/problems/data/models/code_snippet_model.dart';
import 'package:algoflow/features/problems/data/models/problem_model.dart';
import 'package:algoflow/features/editor/domain/repositories/judge_repository.dart';
import 'package:algoflow/features/editor/data/models/submission_result_model.dart';
import 'package:algoflow/features/editor/presentation/screens/code_editor_screen.dart';

void main() {
  late Problem testProblem;
  late List<CodeSnippet> snippets;

  setUpAll(() {
    final getIt = GetIt.instance;
    if (getIt.isRegistered<JudgeRepository>()) {
      getIt.unregister<JudgeRepository>();
    }
    getIt.registerSingleton<JudgeRepository>(_FakeJudgeRepository());
    // JudgeCubit now requires AuthInterceptor — register a stub so the
    // screen can create the cubit without network dependencies.
    if (getIt.isRegistered<AuthInterceptor>()) {
      getIt.unregister<AuthInterceptor>();
    }
    getIt.registerSingleton<AuthInterceptor>(_FakeAuthInterceptor());
  });

  tearDownAll(() {
    final getIt = GetIt.instance;
    if (getIt.isRegistered<JudgeRepository>()) {
      getIt.unregister<JudgeRepository>();
    }
    if (getIt.isRegistered<AuthInterceptor>()) {
      getIt.unregister<AuthInterceptor>();
    }
  });

  setUp(() {
    snippets = [
      const CodeSnippet(
        lang: 'Python',
        langSlug: 'python3',
        code: 'class Solution:\n    pass',
      ),
      const CodeSnippet(
        lang: 'JavaScript',
        langSlug: 'javascript',
        code: '/** @param {number[]} nums */\nvar foo = function(nums) {};',
      ),
    ];

    testProblem = Problem(
      questionId: '1',
      questionFrontendId: '1',
      title: 'Two Sum',
      titleSlug: 'two-sum',
      difficulty: 'Easy',
      exampleTestcases: '[2,7,11,15]\n9',
      codeSnippets: snippets,
    );
  });

  Widget buildTestScreen({Problem? problem}) {
    return MaterialApp(
      home: CodeEditorScreen(
        slug: problem?.titleSlug ?? 'test',
        problem: problem,
      ),
    );
  }

  group('CodeEditorScreen layout', () {
    testWidgets('renders without BoxConstraints layout errors', (tester) async {
      await tester.pumpWidget(buildTestScreen(problem: testProblem));
      await tester.pumpAndSettle();

      // If the old "BoxConstraints forces an infinite width" bug were present,
      // the test framework would throw a LayoutBuilder constraint error here.
      expect(find.byType(CodeEditorScreen), findsOneWidget);
    });

    testWidgets('shows Run and Submit buttons', (tester) async {
      await tester.pumpWidget(buildTestScreen(problem: testProblem));
      await tester.pumpAndSettle();

      expect(find.text('Run'), findsOneWidget);
      expect(find.text('Submit'), findsOneWidget);
    });

    testWidgets('shows reset button and problem title', (tester) async {
      await tester.pumpWidget(buildTestScreen(problem: testProblem));
      await tester.pumpAndSettle();

      expect(find.text('Two Sum'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('shows idle state hint text', (tester) async {
      await tester.pumpWidget(buildTestScreen(problem: testProblem));
      await tester.pumpAndSettle();

      expect(find.text('Run or submit your code'), findsOneWidget);
    });

    testWidgets('renders language selector with default language', (tester) async {
      await tester.pumpWidget(buildTestScreen(problem: testProblem));
      await tester.pumpAndSettle();

      // Default language is python3 -> 'Python3' (see AppConstants.langSlugs)
      expect(find.text('Python3'), findsWidgets);
    });
  });

  group('CodeEditorScreen null problem', () {
    testWidgets('shows failed to load problem message', (tester) async {
      await tester.pumpWidget(buildTestScreen(problem: null));
      await tester.pumpAndSettle();

      expect(find.text('Failed to load problem'), findsOneWidget);
    });
  });
}

/// Fake JudgeRepository — never makes network calls, safe for widget tests.
class _FakeJudgeRepository implements JudgeRepository {
  @override
  Future<SubmissionResult> testSolution({
    required String slug,
    required String questionId,
    required String lang,
    required String code,
    String dataInput = '',
  }) async {
    return const SubmissionResult(state: 'SUCCESS', statusCode: 10);
  }

  @override
  Future<SubmissionResult> submitSolution({
    required String slug,
    required String questionId,
    required String lang,
    required String code,
  }) async {
    return const SubmissionResult(state: 'SUCCESS', statusCode: 10);
  }
}

/// Fake AuthInterceptor — always "authenticated", safe for widget tests.
class _FakeAuthInterceptor extends AuthInterceptor {}
