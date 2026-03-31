import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../injection.dart';
import '../../../problems/data/models/problem_model.dart';
import '../../domain/repositories/judge_repository.dart';
import '../cubits/code_editor_cubit.dart';
import '../cubits/judge_cubit.dart';

class CodeEditorScreen extends StatefulWidget {
  final String slug;
  final Problem? problem;

  const CodeEditorScreen({super.key, required this.slug, this.problem});

  @override
  State<CodeEditorScreen> createState() => _CodeEditorScreenState();
}

class _CodeEditorScreenState extends State<CodeEditorScreen> {
  late final TextEditingController _codeController;

  @override
  void initState() {
    super.initState();
    final initialCode = (widget.problem?.codeSnippets.isNotEmpty == true)
        ? widget.problem!.codeSnippets.first.code
        : '';
    _codeController = TextEditingController(text: initialCode);
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.problem == null) {
      return Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () => context.pop()),
        ),
        body: const Center(child: Text('Failed to load problem')),
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => CodeEditorCubit(snippets: widget.problem!.codeSnippets),
        ),
        BlocProvider(
          create: (_) => JudgeCubit(repository: sl<JudgeRepository>()),
        ),
      ],
      child: _EditorBody(problem: widget.problem!, codeController: _codeController),
    );
  }
}

class _EditorBody extends StatefulWidget {
  final Problem problem;
  final TextEditingController codeController;

  const _EditorBody({required this.problem, required this.codeController});

  @override
  State<_EditorBody> createState() => _EditorBodyState();
}

class _EditorBodyState extends State<_EditorBody> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<CodeEditorCubit, CodeEditorState>(
      listenWhen: (previous, current) => previous.code != current.code,
      listener: (context, state) {
        // Sync controller when language is switched or code is reset.
        // This does not trigger a rebuild loop because the listener
        // runs outside the build phase.
        if (widget.codeController.text != state.code) {
          widget.codeController.text = state.code;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () => context.pop()),
          title: Text(widget.problem.title, overflow: TextOverflow.ellipsis),
          actions: [
            // Language selector: narrow BlocBuilder that rebuilds only on language change.
            BlocBuilder<CodeEditorCubit, CodeEditorState>(
              buildWhen: (previous, current) =>
                  previous.selectedLang != current.selectedLang ||
                  previous.snippets != current.snippets,
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
            // Code editor: TextField is completely outside BlocBuilder.
            // It never rebuilds due to cubit changes during typing because
            // we removed onChanged callback. This eliminates UI jank and
            // platform channel thrashing on iOS.
            Expanded(
              flex: 3,
              child: ColoredBox(
                color: AppColors.surface,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.s),
                  child: TextField(
                    controller: widget.codeController,
                    maxLines: null,
                    style: AppTypography.code().copyWith(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      fillColor: Colors.transparent,
                      filled: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    // Removed onChanged — code is captured from controller.text
                    // at Run/Submit/Reset time, never continuously synced to cubit.
                  ),
                ),
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
                // Reset: triggers CodeEditorCubit.resetCode() which emits
                // a new state. BlocListener fires and syncs controller.
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Reset code',
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    context.read<CodeEditorCubit>().resetCode();
                  },
                ),
                const Spacer(),
                // Run: reads code from controller directly at press time.
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
                          slug: widget.problem.titleSlug,
                          questionId: widget.problem.questionId ?? '',
                          lang: editorState.selectedLang,
                          code: widget.codeController.text,
                          dataInput: widget.problem.exampleTestcases ?? '',
                        );
                  },
                ),
                const Gap(AppSpacing.s),
                // Submit: shows confirmation dialog and reads code at that time.
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
      ),
    );
  }

  void _showSubmitConfirmation(BuildContext context) {
    // Capture code and language before dialog opens to avoid
    // stale context issues if user navigates away or dialog
    // is dismissed by system events.
    final editorState = context.read<CodeEditorCubit>().state;
    final currentCode = widget.codeController.text;

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
              context.read<JudgeCubit>().submitSolution(
                    slug: widget.problem.titleSlug,
                    questionId: widget.problem.questionId ?? '',
                    lang: editorState.selectedLang,
                    code: currentCode,
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
