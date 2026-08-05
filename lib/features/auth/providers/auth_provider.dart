import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_rest_api/core/models/auth_model.dart';
import 'package:flutter_rest_api/core/models/user_model.dart';
import 'package:flutter_rest_api/core/providers/core_providers.dart';
import 'package:flutter_rest_api/core/repositories/auth_repository.dart';

class AuthState {
  final UserModel? user;
  final bool isAuthenticated;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.user,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.errorMessage,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isAuthenticated,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final IAuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AuthState()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    final isAuth = await _authRepository.isAuthenticated();
    if (isAuth) {
      final userResult = await _authRepository.getCurrentUser();
      userResult.when(
        success: (user) {
          state = state.copyWith(
            user: user,
            isAuthenticated: true,
            isLoading: false,
          );
        },
        failure: (msg, code, ex) {
          state = state.copyWith(
            isAuthenticated: false,
            isLoading: false,
            errorMessage: msg,
          );
        },
      );
    } else {
      state = state.copyWith(isAuthenticated: false, isLoading: false);
    }
  }

  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final request = LoginRequest(username: username, password: password);
    final result = await _authRepository.login(request);

    return result.when(
      success: (response) {
        state = state.copyWith(
          user: response.user,
          isAuthenticated: true,
          isLoading: false,
        );
        return true;
      },
      failure: (msg, code, ex) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: msg,
        );
        return false;
      },
    );
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await _authRepository.logout();
    state = const AuthState();
  }
}
