import 'package:dio/dio.dart';
import 'package:flutter_rest_api/core/config/env_config.dart';
import 'package:flutter_rest_api/core/network/api_exception.dart';
import 'package:flutter_rest_api/core/network/api_response.dart';
import 'package:flutter_rest_api/core/network/cache_manager.dart';

/// Generic HTTP API Client interface
abstract class IApiClient {
  Future<ApiResult<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool useCache = false,
    Duration? cacheTtl,
    required T Function(dynamic data) decoder,
  });

  Future<ApiResult<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    required T Function(dynamic data) decoder,
  });

  Future<ApiResult<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    required T Function(dynamic data) decoder,
  });

  Future<ApiResult<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    required T Function(dynamic data) decoder,
  });

  Future<ApiResult<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    required T Function(dynamic data) decoder,
  });

  Future<ApiResult<T>> uploadMultipart<T>(
    String path, {
    required FormData formData,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
    required T Function(dynamic data) decoder,
  });

  Future<ApiResult<String>> downloadFile(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  });
}

/// Generic Dio API Client Implementation
class ApiClient implements IApiClient {
  final Dio dio;
  final CacheManager _cacheManager;

  ApiClient({
    required EnvConfig config,
    required this.dio,
    CacheManager? cacheManager,
  }) : _cacheManager = cacheManager ?? CacheManager() {
    dio.options = BaseOptions(
      baseUrl: config.baseUrl,
      connectTimeout: config.connectTimeout,
      receiveTimeout: config.receiveTimeout,
      sendTimeout: config.sendTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
  }

  @override
  Future<ApiResult<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool useCache = false,
    Duration? cacheTtl,
    required T Function(dynamic data) decoder,
  }) async {
    final cacheKey = '$path:${queryParameters.toString()}';

    if (useCache) {
      final cachedData = _cacheManager.get<T>(cacheKey);
      if (cachedData != null) {
        return ApiResult.success(cachedData);
      }
    }

    try {
      final response = await dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      final result = decoder(response.data);
      if (useCache) {
        _cacheManager.set(cacheKey, result, ttl: cacheTtl);
      }
      return ApiResult.success(result);
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      return ApiResult.failure('Failed to parse response: $e');
    }
  }

  @override
  Future<ApiResult<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    required T Function(dynamic data) decoder,
  }) async {
    try {
      final response = await dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      final result = decoder(response.data);
      return ApiResult.success(result);
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      return ApiResult.failure('Failed to parse response: $e');
    }
  }

  @override
  Future<ApiResult<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    required T Function(dynamic data) decoder,
  }) async {
    try {
      final response = await dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      final result = decoder(response.data);
      return ApiResult.success(result);
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      return ApiResult.failure('Failed to parse response: $e');
    }
  }

  @override
  Future<ApiResult<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    required T Function(dynamic data) decoder,
  }) async {
    try {
      final response = await dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      final result = decoder(response.data);
      return ApiResult.success(result);
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      return ApiResult.failure('Failed to parse response: $e');
    }
  }

  @override
  Future<ApiResult<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    required T Function(dynamic data) decoder,
  }) async {
    try {
      final response = await dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      final result = decoder(response.data);
      return ApiResult.success(result);
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      return ApiResult.failure('Failed to parse response: $e');
    }
  }

  @override
  Future<ApiResult<T>> uploadMultipart<T>(
    String path, {
    required FormData formData,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
    required T Function(dynamic data) decoder,
  }) async {
    try {
      final response = await dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );

      final result = decoder(response.data);
      return ApiResult.success(result);
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      return ApiResult.failure('Multipart upload failed: $e');
    }
  }

  @override
  Future<ApiResult<String>> downloadFile(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      await dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );
      return ApiResult.success(savePath);
    } on DioException catch (e) {
      return _handleDioError<String>(e);
    } catch (e) {
      return ApiResult.failure('File download failed: $e');
    }
  }

  ApiResult<T> _handleDioError<T>(DioException e) {
    if (e.error is ApiException) {
      final apiEx = e.error as ApiException;
      return ApiResult.failure(
        apiEx.toUserFriendlyMessage(),
        statusCode: apiEx.statusCode,
        exception: apiEx,
      );
    }

    final mappedException = ApiException.fromDioException(e);
    return ApiResult.failure(
      mappedException.toUserFriendlyMessage(),
      statusCode: mappedException.statusCode,
      exception: mappedException,
    );
  }
}
