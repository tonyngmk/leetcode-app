import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../problems/data/models/code_snippet_model.dart';

// --- States ---

class CodeEditorState {
  final String selectedLang;
  final String code;
  final List<CodeSnippet> snippets;

  const CodeEditorState({
    required this.selectedLang,
    required this.code,
    required this.snippets,
  });

  CodeEditorState copyWith({String? selectedLang, String? code}) {
    return CodeEditorState(
      selectedLang: selectedLang ?? this.selectedLang,
      code: code ?? this.code,
      snippets: snippets,
    );
  }
}

// --- Cubit ---

class CodeEditorCubit extends Cubit<CodeEditorState> {
  CodeEditorCubit({required List<CodeSnippet> snippets})
      : super(CodeEditorState(
          selectedLang: snippets.isNotEmpty ? snippets.first.langSlug : 'python3',
          code: snippets.isNotEmpty ? snippets.first.code : '',
          snippets: snippets,
        ));

  void selectLanguage(String langSlug) {
    final snippet = state.snippets.where((s) => s.langSlug == langSlug).firstOrNull;
    emit(state.copyWith(
      selectedLang: langSlug,
      code: snippet?.code ?? '',
    ));
  }

  void updateCode(String code) {
    emit(state.copyWith(code: code));
  }

  void resetCode() {
    final snippet = state.snippets
        .where((s) => s.langSlug == state.selectedLang)
        .firstOrNull;
    emit(state.copyWith(code: snippet?.code ?? ''));
  }
}
