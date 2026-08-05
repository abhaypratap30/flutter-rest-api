import 'dart:developer' as developer;
import 'package:dio/dio.dart';

/// Formatted Logging Interceptor for HTTP Requests, Responses, and Errors.
class AppLoggingInterceptor extends Interceptor {
  final bool enabled;

  AppLoggingInterceptor({this.enabled = true});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (enabled) {
      developer.log('====================================================', name: 'HTTP-REQ');
      developer.log('🚀 [${options.method}] ${options.uri}', name: 'HTTP-REQ');
      if (options.headers.isNotEmpty) {
        developer.log('Headers: ${options.headers}', name: 'HTTP-REQ');
      }
      if (options.queryParameters.isNotEmpty) {
        developer.log('QueryParams: ${options.queryParameters}', name: 'HTTP-REQ');
      }
      if (options.data != null) {
        developer.log('Body: ${options.data}', name: 'HTTP-REQ');
      }
      developer.log('====================================================', name: 'HTTP-REQ');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (enabled) {
      developer.log('====================================================', name: 'HTTP-RES');
      developer.log('✅ [${response.statusCode}] ${response.requestOptions.uri}', name: 'HTTP-RES');
      developer.log('Data: ${response.data}', name: 'HTTP-RES');
      developer.log('====================================================', name: 'HTTP-RES');
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (enabled) {
      developer.log('====================================================', name: 'HTTP-ERR');
      developer.log('❌ [${err.response?.statusCode ?? 'N/A'}] ${err.requestOptions.uri}', name: 'HTTP-ERR');
      developer.log('Error Type: ${err.type}', name: 'HTTP-ERR');
      developer.log('Message: ${err.message}', name: 'HTTP-ERR');
      if (err.response?.data != null) {
        developer.log('Response Payload: ${err.response?.data}', name: 'HTTP-ERR');
      }
      developer.log('====================================================', name: 'HTTP-ERR');
    }
    super.onError(err, handler);
  }
}
