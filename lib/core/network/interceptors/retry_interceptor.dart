import 'dart:async';
import 'package:dio/dio.dart';

/// Exponential Backoff Retry Interceptor for transient network & server failures.
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Duration retryInterval;

  RetryInterceptor({
    required this.dio,
    this.maxRetries = 2,
    this.retryInterval = const Duration(seconds: 1),
  });

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final extra = err.requestOptions.extra;
    final retries = (extra['retry_count'] as int?) ?? 0;

    final shouldRetry = _shouldRetry(err) && retries < maxRetries;

    if (shouldRetry) {
      extra['retry_count'] = retries + 1;
      
      // Calculate delay with exponential backoff
      final delay = retryInterval * (1 << retries);
      await Future.delayed(delay);

      try {
        final response = await dio.fetch(err.requestOptions);
        return handler.resolve(response);
      } catch (retryErr) {
        if (retryErr is DioException) {
          return super.onError(retryErr, handler);
        }
      }
    }

    return super.onError(err, handler);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.response != null &&
            err.response!.statusCode != null &&
            err.response!.statusCode! >= 500);
  }
}
