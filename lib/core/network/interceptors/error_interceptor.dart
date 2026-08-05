import 'package:dio/dio.dart';
import 'package:flutter_rest_api/core/network/api_exception.dart';

/// Interceptor mapping HTTP & Network DioExceptions into strongly typed [ApiException]s.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final apiException = ApiException.fromDioException(err);
    
    // Wrap error object inside DioException for downstream catch blocks
    final customErr = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: apiException,
      message: apiException.message,
    );

    handler.next(customErr);
  }
}
