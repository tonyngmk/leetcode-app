import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/auth_interceptor.dart';
import '../../../profile/data/datasources/profile_remote_datasource.dart';

// --- States ---

sealed class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String username;
  AuthAuthenticated(this.username);
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

// --- Cubit ---

class AuthCubit extends Cubit<AuthState> {
  final AuthInterceptor _authInterceptor;
  final ProfileRemoteDataSource _profileRemote;

  AuthCubit({
    required AuthInterceptor authInterceptor,
    required ProfileRemoteDataSource profileRemote,
  })  : _authInterceptor = authInterceptor,
        _profileRemote = profileRemote,
        super(AuthInitial());

  Future<void> checkAuth() async {
    final creds = await _authInterceptor.getCredentials();
    if (creds != null) {
      emit(AuthAuthenticated(creds.username));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> login({
    required String session,
    required String csrftoken,
  }) async {
    emit(AuthLoading());
    try {
      // Temporarily save credentials for validation
      await _authInterceptor.saveCredentials(
        session: session,
        csrftoken: csrftoken,
        username: '',
      );

      final username = await _profileRemote.validateCredentials();
      if (username != null) {
        await _authInterceptor.saveCredentials(
          session: session,
          csrftoken: csrftoken,
          username: username,
        );
        emit(AuthAuthenticated(username));
      } else {
        await _authInterceptor.clearCredentials();
        emit(AuthError('Invalid credentials. Please check your session cookie and CSRF token.'));
      }
    } catch (e) {
      await _authInterceptor.clearCredentials();
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    await _authInterceptor.clearCredentials();
    emit(AuthUnauthenticated());
  }
}
