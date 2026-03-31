import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:algoflow/core/network/auth_interceptor.dart';
import 'package:algoflow/features/editor/data/models/submission_result_model.dart';
import 'package:algoflow/features/editor/domain/repositories/judge_repository.dart';
import 'package:algoflow/features/editor/presentation/cubits/judge_cubit.dart';

class MockJudgeRepository extends Mock implements JudgeRepository {}

class MockAuthInterceptor extends Mock implements AuthInterceptor {}

void main() {
  late MockJudgeRepository mockRepository;
  late MockAuthInterceptor mockAuthInterceptor;

  setUpAll(() {
    registerFallbackValue(DioException(
      requestOptions: RequestOptions(path: ''),
    ));
  });

  setUp(() {
    mockRepository = MockJudgeRepository();
    mockAuthInterceptor = MockAuthInterceptor();
  });

  group('JudgeCubit', () {
    group('testSolution', () {
      blocTest<JudgeCubit, JudgeState>(
        'emits [JudgeTesting, JudgeTestResult] on success',
        setUp: () {
          when(() => mockAuthInterceptor.hasCredentials())
              .thenAnswer((_) async => true);
          when(() => mockRepository.testSolution(
                slug: any(named: 'slug'),
                questionId: any(named: 'questionId'),
                lang: any(named: 'lang'),
                code: any(named: 'code'),
                dataInput: any(named: 'dataInput'),
              )).thenAnswer((_) async => const SubmissionResult(
                state: 'SUCCESS',
                statusCode: 10,
              ));
        },
        build: () => JudgeCubit(
          repository: mockRepository,
          authInterceptor: mockAuthInterceptor,
        ),
        act: (cubit) => cubit.testSolution(
          slug: 'two-sum',
          questionId: '1',
          lang: 'python3',
          code: 'class Solution:\n    pass',
        ),
        expect: () => [
          isA<JudgeTesting>(),
          isA<JudgeTestResult>(),
        ],
        verify: (_) {
          verify(() => mockAuthInterceptor.hasCredentials()).called(1);
          verify(() => mockRepository.testSolution(
                slug: 'two-sum',
                questionId: '1',
                lang: 'python3',
                code: 'class Solution:\n    pass',
                dataInput: '',
              )).called(1);
        },
      );

      blocTest<JudgeCubit, JudgeState>(
        'emits [JudgeTesting, JudgeAuthError] when not authenticated',
        setUp: () {
          when(() => mockAuthInterceptor.hasCredentials())
              .thenAnswer((_) async => false);
        },
        build: () => JudgeCubit(
          repository: mockRepository,
          authInterceptor: mockAuthInterceptor,
        ),
        act: (cubit) => cubit.testSolution(
          slug: 'two-sum',
          questionId: '1',
          lang: 'python3',
          code: 'class Solution:\n    pass',
        ),
        expect: () => [
          isA<JudgeTesting>(),
          isA<JudgeAuthError>(),
        ],
        verify: (_) {
          verify(() => mockAuthInterceptor.hasCredentials()).called(1);
          verifyNever(() => mockRepository.testSolution(
                slug: any(named: 'slug'),
                questionId: any(named: 'questionId'),
                lang: any(named: 'lang'),
                code: any(named: 'code'),
                dataInput: any(named: 'dataInput'),
              ));
        },
      );

      blocTest<JudgeCubit, JudgeState>(
        'emits [JudgeTesting, JudgeAuthError] on 499 DioException',
        setUp: () {
          when(() => mockAuthInterceptor.hasCredentials())
              .thenAnswer((_) async => true);
          when(() => mockRepository.testSolution(
                slug: any(named: 'slug'),
                questionId: any(named: 'questionId'),
                lang: any(named: 'lang'),
                code: any(named: 'code'),
                dataInput: any(named: 'dataInput'),
              )).thenThrow(DioException(
                requestOptions: RequestOptions(path: ''),
                response: Response(
                  statusCode: 499,
                  requestOptions: RequestOptions(path: ''),
                ),
                message: 'Client error',
              ));
        },
        build: () => JudgeCubit(
          repository: mockRepository,
          authInterceptor: mockAuthInterceptor,
        ),
        act: (cubit) => cubit.testSolution(
          slug: 'two-sum',
          questionId: '1',
          lang: 'python3',
          code: 'class Solution:\n    pass',
        ),
        expect: () => [
          isA<JudgeTesting>(),
          isA<JudgeAuthError>(),
        ],
      );

      blocTest<JudgeCubit, JudgeState>(
        'emits [JudgeTesting, JudgeAuthError] on 401 DioException',
        setUp: () {
          when(() => mockAuthInterceptor.hasCredentials())
              .thenAnswer((_) async => true);
          when(() => mockRepository.testSolution(
                slug: any(named: 'slug'),
                questionId: any(named: 'questionId'),
                lang: any(named: 'lang'),
                code: any(named: 'code'),
                dataInput: any(named: 'dataInput'),
              )).thenThrow(DioException(
                requestOptions: RequestOptions(path: ''),
                response: Response(
                  statusCode: 401,
                  requestOptions: RequestOptions(path: ''),
                ),
              ));
        },
        build: () => JudgeCubit(
          repository: mockRepository,
          authInterceptor: mockAuthInterceptor,
        ),
        act: (cubit) => cubit.testSolution(
          slug: 'two-sum',
          questionId: '1',
          lang: 'python3',
          code: 'class Solution:\n    pass',
        ),
        expect: () => [
          isA<JudgeTesting>(),
          isA<JudgeAuthError>(),
        ],
      );

      blocTest<JudgeCubit, JudgeState>(
        'emits [JudgeTesting, JudgeError] on generic server error (500)',
        setUp: () {
          when(() => mockAuthInterceptor.hasCredentials())
              .thenAnswer((_) async => true);
          when(() => mockRepository.testSolution(
                slug: any(named: 'slug'),
                questionId: any(named: 'questionId'),
                lang: any(named: 'lang'),
                code: any(named: 'code'),
                dataInput: any(named: 'dataInput'),
              )).thenThrow(DioException(
                requestOptions: RequestOptions(path: ''),
                response: Response(
                  statusCode: 500,
                  requestOptions: RequestOptions(path: ''),
                ),
                message: 'Internal server error',
              ));
        },
        build: () => JudgeCubit(
          repository: mockRepository,
          authInterceptor: mockAuthInterceptor,
        ),
        act: (cubit) => cubit.testSolution(
          slug: 'two-sum',
          questionId: '1',
          lang: 'python3',
          code: 'class Solution:\n    pass',
        ),
        expect: () => [
          isA<JudgeTesting>(),
          isA<JudgeError>().having((e) => e.message, 'message', contains('500')),
        ],
      );

      blocTest<JudgeCubit, JudgeState>(
        'emits [JudgeTesting, JudgeError] on connection timeout',
        setUp: () {
          when(() => mockAuthInterceptor.hasCredentials())
              .thenAnswer((_) async => true);
          when(() => mockRepository.testSolution(
                slug: any(named: 'slug'),
                questionId: any(named: 'questionId'),
                lang: any(named: 'lang'),
                code: any(named: 'code'),
                dataInput: any(named: 'dataInput'),
              )).thenThrow(DioException(
                type: DioExceptionType.connectionTimeout,
                requestOptions: RequestOptions(path: ''),
              ));
        },
        build: () => JudgeCubit(
          repository: mockRepository,
          authInterceptor: mockAuthInterceptor,
        ),
        act: (cubit) => cubit.testSolution(
          slug: 'two-sum',
          questionId: '1',
          lang: 'python3',
          code: 'class Solution:\n    pass',
        ),
        expect: () => [
          isA<JudgeTesting>(),
          isA<JudgeError>().having((e) => e.message, 'message', contains('timed out')),
        ],
      );

      blocTest<JudgeCubit, JudgeState>(
        'emits [JudgeTesting, JudgeError] on connection error',
        setUp: () {
          when(() => mockAuthInterceptor.hasCredentials())
              .thenAnswer((_) async => true);
          when(() => mockRepository.testSolution(
                slug: any(named: 'slug'),
                questionId: any(named: 'questionId'),
                lang: any(named: 'lang'),
                code: any(named: 'code'),
                dataInput: any(named: 'dataInput'),
              )).thenThrow(DioException(
                type: DioExceptionType.connectionError,
                requestOptions: RequestOptions(path: ''),
              ));
        },
        build: () => JudgeCubit(
          repository: mockRepository,
          authInterceptor: mockAuthInterceptor,
        ),
        act: (cubit) => cubit.testSolution(
          slug: 'two-sum',
          questionId: '1',
          lang: 'python3',
          code: 'class Solution:\n    pass',
        ),
        expect: () => [
          isA<JudgeTesting>(),
          isA<JudgeError>().having((e) => e.message, 'message', contains('internet')),
        ],
      );

      blocTest<JudgeCubit, JudgeState>(
        'emits [JudgeTesting, JudgeError] on non-DioException',
        setUp: () {
          when(() => mockAuthInterceptor.hasCredentials())
              .thenAnswer((_) async => true);
          when(() => mockRepository.testSolution(
                slug: any(named: 'slug'),
                questionId: any(named: 'questionId'),
                lang: any(named: 'lang'),
                code: any(named: 'code'),
                dataInput: any(named: 'dataInput'),
              )).thenThrow(Exception('Unexpected error'));
        },
        build: () => JudgeCubit(
          repository: mockRepository,
          authInterceptor: mockAuthInterceptor,
        ),
        act: (cubit) => cubit.testSolution(
          slug: 'two-sum',
          questionId: '1',
          lang: 'python3',
          code: 'class Solution:\n    pass',
        ),
        expect: () => [
          isA<JudgeTesting>(),
          isA<JudgeError>(),
        ],
      );
    });

    group('submitSolution', () {
      blocTest<JudgeCubit, JudgeState>(
        'emits [JudgeSubmitting, JudgeSubmitResult] on success',
        setUp: () {
          when(() => mockAuthInterceptor.hasCredentials())
              .thenAnswer((_) async => true);
          when(() => mockRepository.submitSolution(
                slug: any(named: 'slug'),
                questionId: any(named: 'questionId'),
                lang: any(named: 'lang'),
                code: any(named: 'code'),
              )).thenAnswer((_) async => const SubmissionResult(
                state: 'SUCCESS',
                statusCode: 10,
              ));
        },
        build: () => JudgeCubit(
          repository: mockRepository,
          authInterceptor: mockAuthInterceptor,
        ),
        act: (cubit) => cubit.submitSolution(
          slug: 'two-sum',
          questionId: '1',
          lang: 'python3',
          code: 'class Solution:\n    pass',
        ),
        expect: () => [
          isA<JudgeSubmitting>(),
          isA<JudgeSubmitResult>(),
        ],
      );

      blocTest<JudgeCubit, JudgeState>(
        'emits [JudgeSubmitting, JudgeAuthError] when not authenticated',
        setUp: () {
          when(() => mockAuthInterceptor.hasCredentials())
              .thenAnswer((_) async => false);
        },
        build: () => JudgeCubit(
          repository: mockRepository,
          authInterceptor: mockAuthInterceptor,
        ),
        act: (cubit) => cubit.submitSolution(
          slug: 'two-sum',
          questionId: '1',
          lang: 'python3',
          code: 'class Solution:\n    pass',
        ),
        expect: () => [
          isA<JudgeSubmitting>(),
          isA<JudgeAuthError>(),
        ],
      );

      blocTest<JudgeCubit, JudgeState>(
        'emits [JudgeSubmitting, JudgeAuthError] on 499 DioException',
        setUp: () {
          when(() => mockAuthInterceptor.hasCredentials())
              .thenAnswer((_) async => true);
          when(() => mockRepository.submitSolution(
                slug: any(named: 'slug'),
                questionId: any(named: 'questionId'),
                lang: any(named: 'lang'),
                code: any(named: 'code'),
              )).thenThrow(DioException(
                requestOptions: RequestOptions(path: ''),
                response: Response(
                  statusCode: 499,
                  requestOptions: RequestOptions(path: ''),
                ),
              ));
        },
        build: () => JudgeCubit(
          repository: mockRepository,
          authInterceptor: mockAuthInterceptor,
        ),
        act: (cubit) => cubit.submitSolution(
          slug: 'two-sum',
          questionId: '1',
          lang: 'python3',
          code: 'class Solution:\n    pass',
        ),
        expect: () => [
          isA<JudgeSubmitting>(),
          isA<JudgeAuthError>(),
        ],
      );
    });

    group('reset', () {
      blocTest<JudgeCubit, JudgeState>(
        'emits [JudgeIdle] after reset',
        setUp: () {
          when(() => mockAuthInterceptor.hasCredentials())
              .thenAnswer((_) async => true);
          when(() => mockRepository.testSolution(
                slug: any(named: 'slug'),
                questionId: any(named: 'questionId'),
                lang: any(named: 'lang'),
                code: any(named: 'code'),
                dataInput: any(named: 'dataInput'),
              )).thenAnswer((_) async => const SubmissionResult(
                state: 'SUCCESS',
                statusCode: 10,
              ));
        },
        build: () => JudgeCubit(
          repository: mockRepository,
          authInterceptor: mockAuthInterceptor,
        ),
        act: (cubit) async {
          await cubit.testSolution(
            slug: 'two-sum',
            questionId: '1',
            lang: 'python3',
            code: 'class Solution:\n    pass',
          );
          cubit.reset();
        },
        expect: () => [
          isA<JudgeTesting>(),
          isA<JudgeTestResult>(),
          isA<JudgeIdle>(),
        ],
      );
    });
  });
}
