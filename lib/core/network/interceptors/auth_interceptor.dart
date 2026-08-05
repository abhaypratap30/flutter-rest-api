import 'package:dio/dio.dart';
import 'package:flutter_rest_api/core/config/app_constants.dart';

abstract class ITokenProvider {
  Future<String?> getAccessToken();
}

/// Authorization Interceptor injecting Bearer tokens to outgoing HTTP requests.
class AuthInterceptor extends Interceptor {
  final ITokenProvider tokenProvider;

  AuthInterceptor({required this.tokenProvider});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip adding auth header if endpoint explicitly opts out or is login
    final requiresAuth = options.extra['requiresAuth'] ?? true;
    if (requiresAuth && !options.path.contains(AppConstants.endpointLogin)) {
      final token = await tokenProvider.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers[AppConstants.headerAuthorization] =
            '${AppConstants.headerBearerPrefix}$token';
      }
    }
    handler.next(options);
  }
}
