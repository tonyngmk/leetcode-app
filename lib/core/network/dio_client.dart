import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import 'auth_interceptor.dart';

class DioClient {
  final Dio dio;
  final AuthInterceptor _authInterceptor;

  DioClient({required AuthInterceptor authInterceptor})
      : _authInterceptor = authInterceptor,
        dio = Dio(BaseOptions(
          baseUrl: ApiConstants.leetcodeBaseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {
            'Content-Type': 'application/json',
            'Referer': 'https://leetcode.com',
            'User-Agent':
                'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36',
          },
        )) {
    dio.interceptors.add(_authInterceptor);
    dio.interceptors.add(_retryInterceptor());
  }

  /// GraphQL query (public — no auth required).
  Future<Map<String, dynamic>> graphql(
    String query, {
    Map<String, dynamic>? variables,
  }) async {
    final response = await dio.post<Map<String, dynamic>>(
      ApiConstants.leetcodeGraphqlUrl,
      data: {
        'query': query,
        if (variables != null) 'variables': variables,
      },
    );
    final data = response.data!;
    if (data.containsKey('errors')) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: (data['errors'] as List).first['message'] as String,
      );
    }
    return data['data'] as Map<String, dynamic>;
  }

  /// GraphQL query with authentication headers/cookies.
  Future<Map<String, dynamic>> graphqlAuth(
    String query, {
    Map<String, dynamic>? variables,
  }) async {
    final response = await dio.post<Map<String, dynamic>>(
      ApiConstants.leetcodeGraphqlUrl,
      data: {
        'query': query,
        if (variables != null) 'variables': variables,
      },
      options: Options(extra: {'requiresAuth': true}),
    );
    final data = response.data!;
    if (data.containsKey('errors')) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: (data['errors'] as List).first['message'] as String,
      );
    }
    return data['data'] as Map<String, dynamic>;
  }

  Interceptor _retryInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) async {
        if (error.response?.statusCode == 429) {
          // Rate limited — wait and retry once
          await Future<void>.delayed(const Duration(seconds: 2));
          try {
            final response = await dio.fetch(error.requestOptions);
            return handler.resolve(response);
          } catch (e) {
            return handler.next(error);
          }
        }
        return handler.next(error);
      },
    );
  }
}
