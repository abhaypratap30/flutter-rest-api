import 'package:flutter_rest_api/core/models/user_model.dart';

class LoginRequest {
  final String username;
  final String password;
  final int expiresInMins;

  const LoginRequest({
    required this.username,
    required this.password,
    this.expiresInMins = 60,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'expiresInMins': expiresInMins,
    };
  }
}

class AuthTokens {
  final String accessToken;
  final String refreshToken;

  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['accessToken'] as String? ?? json['token'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }
}

class AuthResponse {
  final UserModel user;
  final AuthTokens tokens;

  const AuthResponse({
    required this.user,
    required this.tokens,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final user = UserModel.fromJson(json);
    final tokens = AuthTokens.fromJson(json);
    return AuthResponse(user: user, tokens: tokens);
  }
}
