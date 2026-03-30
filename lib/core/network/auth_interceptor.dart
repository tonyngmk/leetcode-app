import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Injects LeetCode session cookie + CSRF token on authenticated requests.
/// Ported from leetcode-bot/leetcode.py _auth_headers() + _auth_cookies().
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;

  static const _sessionKey = 'leetcode_session';
  static const _csrfKey = 'csrftoken';
  static const _usernameKey = 'leetcode_username';

  AuthInterceptor({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.extra['requiresAuth'] == true) {
      final session = await _storage.read(key: _sessionKey);
      final csrf = await _storage.read(key: _csrfKey);
      if (session != null && csrf != null) {
        options.headers['Cookie'] = 'LEETCODE_SESSION=$session; csrftoken=$csrf';
        options.headers['X-CSRFToken'] = csrf;
      }
    }
    handler.next(options);
  }

  Future<void> saveCredentials({
    required String session,
    required String csrftoken,
    required String username,
  }) async {
    await _storage.write(key: _sessionKey, value: session);
    await _storage.write(key: _csrfKey, value: csrftoken);
    await _storage.write(key: _usernameKey, value: username);
  }

  Future<({String session, String csrftoken, String username})?> getCredentials() async {
    final session = await _storage.read(key: _sessionKey);
    final csrf = await _storage.read(key: _csrfKey);
    final username = await _storage.read(key: _usernameKey);
    if (session == null || csrf == null || username == null) return null;
    return (session: session, csrftoken: csrf, username: username);
  }

  Future<bool> hasCredentials() async {
    final session = await _storage.read(key: _sessionKey);
    return session != null;
  }

  Future<void> clearCredentials() async {
    await _storage.delete(key: _sessionKey);
    await _storage.delete(key: _csrfKey);
    await _storage.delete(key: _usernameKey);
  }
}
