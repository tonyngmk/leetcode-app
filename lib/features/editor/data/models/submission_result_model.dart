import '../../../../core/constants/app_constants.dart';

/// Submission/test result — from check_result() polling response.
class SubmissionResult {
  final String state;
  final int? statusCode;
  final String? statusMsg;
  final List<String> codeAnswer;
  final List<String> expectedCodeAnswer;
  final String? statusRuntime;
  final String? statusMemory;
  final double? runtimePercentile;
  final double? memoryPercentile;
  final String? compileError;
  final String? runtimeError;
  final String? lastTestcase;
  final int? totalCorrect;
  final int? totalTestcases;

  const SubmissionResult({
    required this.state,
    this.statusCode,
    this.statusMsg,
    this.codeAnswer = const [],
    this.expectedCodeAnswer = const [],
    this.statusRuntime,
    this.statusMemory,
    this.runtimePercentile,
    this.memoryPercentile,
    this.compileError,
    this.runtimeError,
    this.lastTestcase,
    this.totalCorrect,
    this.totalTestcases,
  });

  bool get isPending => state != 'SUCCESS';
  bool get isAccepted => statusCode == 10;

  String get statusDisplay =>
      AppConstants.statusCodes[statusCode] ?? statusMsg ?? 'Unknown';

  factory SubmissionResult.fromJson(Map<String, dynamic> json) {
    return SubmissionResult(
      state: json['state'] as String? ?? 'PENDING',
      statusCode: json['status_code'] as int?,
      statusMsg: json['status_msg'] as String?,
      codeAnswer: _toStringList(json['code_answer']),
      expectedCodeAnswer: _toStringList(json['expected_code_answer']),
      statusRuntime: json['status_runtime'] as String?,
      statusMemory: json['status_memory'] as String?,
      runtimePercentile: (json['runtime_percentile'] as num?)?.toDouble(),
      memoryPercentile: (json['memory_percentile'] as num?)?.toDouble(),
      compileError: json['full_compile_error'] as String? ?? json['compile_error'] as String?,
      runtimeError: json['full_runtime_error'] as String? ?? json['runtime_error'] as String?,
      lastTestcase: json['last_testcase'] as String?,
      totalCorrect: json['total_correct'] as int?,
      totalTestcases: json['total_testcases'] as int?,
    );
  }

  static List<String> _toStringList(dynamic value) {
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }
}
