import 'package:dio/dio.dart';
import 'package:flutter_rest_api/core/config/app_constants.dart';

abstract class ITokenRefreshHandler {
  Future<String?> getRefreshToken();
  Future<bool> refreshTokens(String refreshToken);
  Future<void> onLogoutRequired();
}

/// Thread-Safe Interceptor that handles HTTP 401 Unauthorized responses by
/// refreshing access tokens and retrying original requests.
class TokenRefreshInterceptor extends Interceptor {
  final Dio dio;
  final ITokenRefreshHandler refreshHandler;
  bool _isRefreshing = false;
  final List<_PendingRequest> _pendingRequests = [];

  TokenRefreshInterceptor({
    required this.dio,
    required this.refreshHandler,
  });

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final response = err.response;

    // Handle 401 Unauthorized errors
    if (response?.statusCode == 401 && !_isAuthEndpoint(err.requestOptions.path)) {
      final requestOptions = err.requestOptions;

      // Prevent infinite loop if request already retried once
      final isRetry = requestOptions.extra['isRetry'] ?? false;
      if (isRetry) {
        handler.next(err);
        return;
      }

      if (_isRefreshing) {
        // Queue pending request while refresh is in progress
        _pendingRequests.add(_PendingRequest(requestOptions, handler));
        return;
      }

      _isRefreshing = true;

      try {
        final refreshToken = await refreshHandler.getRefreshToken();
        if (refreshToken == null || refreshToken.isEmpty) {
          await _failAllPendingAndLogout(err, handler);
          return;
        }

        final success = await refreshHandler.refreshTokens(refreshToken);
        if (success) {
          // Mark as retried
          requestOptions.extra['isRetry'] = true;

          // Retry current original request
          final response = await dio.fetch(requestOptions);
          handler.resolve(response);

          // Retry queued pending requests
          _retryPendingRequests();
        } else {
          await _failAllPendingAndLogout(err, handler);
        }
      } catch (refreshErr) {
        await _failAllPendingAndLogout(err, handler);
      } finally {
        _isRefreshing = false;
      }
      return;
    }

    handler.next(err);
  }

  bool _isAuthEndpoint(String path) {
    return path.contains(AppConstants.endpointLogin) ||
        path.contains(AppConstants.endpointRefreshToken);
  }

  Future<void> _failAllPendingAndLogout(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    handler.next(err);
    for (final pending in _pendingRequests) {
      pending.handler.next(err);
    }
    _pendingRequests.clear();
    await refreshHandler.onLogoutRequired();
  }

  void _retryPendingRequests() {
    for (final pending in _pendingRequests) {
      pending.requestOptions.extra['isRetry'] = true;
      dio.fetch(pending.requestOptions).then(
        (response) => pending.handler.resolve(response),
        onError: (e) {
          if (e is DioException) {
            pending.handler.reject(e);
          } else {
            pending.handler.next(DioException(
              requestOptions: pending.requestOptions,
              error: e,
            ));
          }
        },
      );
    }
    _pendingRequests.clear();
  }
}

class _PendingRequest {
  final RequestOptions requestOptions;
  final ErrorInterceptorHandler handler;

  _PendingRequest(this.requestOptions, this.handler);
}
