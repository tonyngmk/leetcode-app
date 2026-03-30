import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../injection.dart';
import '../../../problems/data/models/problem_model.dart';
import '../../../problems/domain/repositories/problems_repository.dart';
import '../../domain/repositories/judge_repository.dart';
import '../cubits/code_editor_cubit.dart';
import '../cubits/judge_cubit.dart';

class CodeEditorScreen extends StatefulWidget {
  final String slug;

  const CodeEditorScreen({super.key, required this.slug});

  @override
  State<CodeEditorScreen> createState() => _CodeEditorScreenState();
}

class _CodeEditorScreenState extends State<CodeEditorScreen> {
  Problem? _problem;
  bool _loading = true;
  final _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProblem();
  }

  Future<void> _loadProblem() async {
    try {
      final problem = await sl<ProblemsRepository>().getProblemDetail(widget.slug);
      if (mounted) {
        setState(() {
          _problem = problem;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_problem == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Failed to load problem')),
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => CodeEditorCubit(snippets: _problem!.codeSnippets),
        ),
        BlocProvider(
          create: (_) => JudgeCubit(repository: sl<JudgeRepository>()),
        ),
      ],
      child: _EditorBody(problem: _problem!, codeController: _codeController),
    );
  }
}

class _EditorBody extends StatelessWidget {
  final Problem problem;
  final TextEditingController codeController;

  const _EditorBody({required this.problem, required this.codeController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(problem.title, overflow: TextOverflow.ellipsis),
        actions: [
          // Language selector
          BlocBuilder<CodeEditorCubit, CodeEditorState>(
            builder: (context, state) {
              return PopupMenuButton<String>(
                initialValue: state.selectedLang,
                onSelected: (lang) {
                  context.read<CodeEditorCubit>().selectLanguage(lang);
                },
                itemBuilder: (context) {
                  return state.snippets.map((s) {
                    return PopupMenuItem(
                      value: s.langSlug,
                      child: Text(AppConstants.langSlugs[s.langSlug] ?? s.lang),
                    );
                  }).toList();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppConstants.langSlugs[state.selectedLang] ?? state.selectedLang,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.primary,
                            ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: AppColors.primary, size: 18),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Code editor
          Expanded(
            flex: 3,
            child: BlocBuilder<CodeEditorCubit, CodeEditorState>(
              builder: (context, state) {
                if (codeController.text != state.code) {
                  codeController.text = state.code;
                }
                return Container(
                  color: AppColors.surface,
                  padding: const EdgeInsets.all(AppSpacing.s),
                  child: TextField(
                    controller: codeController,
                    maxLines: null,
                    expands: true,
                    style: AppTypography.code().copyWith(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      fillColor: Colors.transparent,
                      filled: true,
                      contentPadding: EdgeInsets.all(AppSpacing.s),
                    ),
                    onChanged: (code) {
                      context.read<CodeEditorCubit>().updateCode(code);
                    },
                  ),
                );
              },
            ),
          ),
          // Divider with drag handle appearance
          Container(
            height: 4,
            color: AppColors.divider,
          ),
          // Results panel
          Expanded(
            flex: 2,
            child: BlocBuilder<JudgeCubit, JudgeState>(
              builder: (context, state) {
                return Container(
                  color: AppColors.background,
                  padding: const EdgeInsets.all(AppSpacing.m),
                  child: switch (state) {
                    JudgeIdle() => Center(
                        child: Text(
                          'Run or submit your code',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ),
                    JudgeTesting() => const Center(child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          Gap(AppSpacing.s),
                          Text('Running tests...'),
                        ],
                      )),
                    JudgeSubmitting() => const Center(child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          Gap(AppSpacing.s),
                          Text('Submitting...'),
                        ],
                      )),
                    JudgeTestResult(:final result) || JudgeSubmitResult(:final result) =>
                      _ResultView(result: result),
                    JudgeError(:final message) => Center(
                        child: Text(
                          message,
                          style: TextStyle(color: AppColors.hard),
                        ),
                      ),
                  },
                );
              },
            ),
          ),
        ],
      ),
      // Action bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSpacing.s),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Reset
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Reset code',
                onPressed: () {
                  HapticFeedback.lightImpact();
                  context.read<CodeEditorCubit>().resetCode();
                },
              ),
              const Spacer(),
              // Run
              FilledButton.icon(
                icon: const Icon(Icons.play_arrow, size: 18),
                label: const Text('Run'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.card,
                  foregroundColor: AppColors.textPrimary,
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  final editorState = context.read<CodeEditorCubit>().state;
                  context.read<JudgeCubit>().testSolution(
                        slug: problem.titleSlug,
                        questionId: problem.questionId ?? '',
                        lang: editorState.selectedLang,
                        code: editorState.code,
                        dataInput: problem.exampleTestcases ?? '',
                      );
                },
              ),
              const Gap(AppSpacing.s),
              // Submit
              FilledButton.icon(
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Submit'),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _showSubmitConfirmation(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSubmitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Submit Solution'),
        content: const Text('Are you sure you want to submit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              final editorState = context.read<CodeEditorCubit>().state;
              context.read<JudgeCubit>().submitSolution(
                    slug: problem.titleSlug,
                    questionId: problem.questionId ?? '',
                    lang: editorState.selectedLang,
                    code: editorState.code,
                  );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  final dynamic result;

  const _ResultView({required this.result});

  @override
  Widget build(BuildContext context) {
    final isAccepted = result.isAccepted == true;
    final statusColor = isAccepted ? AppColors.easy : AppColors.hard;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status
          Row(
            children: [
              Icon(
                isAccepted ? Icons.check_circle : Icons.cancel,
                color: statusColor,
              ),
              const Gap(AppSpacing.s),
              Text(
                result.statusDisplay,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const Gap(AppSpacing.s),
          // Runtime / Memory
          if (result.statusRuntime != null)
            Text(
              'Runtime: ${result.statusRuntime}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          if (result.statusMemory != null)
            Text(
              'Memory: ${result.statusMemory}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          // Test cases
          if (result.totalCorrect != null && result.totalTestcases != null) ...[
            const Gap(AppSpacing.s),
            Text(
              '${result.totalCorrect}/${result.totalTestcases} test cases passed',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          // Errors
          if (result.compileError != null) ...[
            const Gap(AppSpacing.s),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.s),
              decoration: BoxDecoration(
                color: AppColors.hard.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
              ),
              child: Text(
                result.compileError,
                style: AppTypography.code(fontSize: 12).copyWith(color: AppColors.hard),
              ),
            ),
          ],
          if (result.runtimeError != null) ...[
            const Gap(AppSpacing.s),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.s),
              decoration: BoxDecoration(
                color: AppColors.hard.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
              ),
              child: Text(
                result.runtimeError,
                style: AppTypography.code(fontSize: 12).copyWith(color: AppColors.hard),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
