import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_rest_api/core/config/env_config.dart';
import 'package:flutter_rest_api/core/network/api_client.dart';
import 'package:flutter_rest_api/core/network/interceptors/auth_interceptor.dart';
import 'package:flutter_rest_api/core/network/interceptors/error_interceptor.dart';
import 'package:flutter_rest_api/core/network/interceptors/logging_interceptor.dart';
import 'package:flutter_rest_api/core/network/interceptors/retry_interceptor.dart';
import 'package:flutter_rest_api/core/network/interceptors/token_refresh_interceptor.dart';
import 'package:flutter_rest_api/core/repositories/auth_repository.dart';
import 'package:flutter_rest_api/core/repositories/file_repository.dart';
import 'package:flutter_rest_api/core/repositories/user_repository.dart';
import 'package:flutter_rest_api/core/services/connectivity_service.dart';
import 'package:flutter_rest_api/core/services/download_service.dart';
import 'package:flutter_rest_api/core/services/storage_service.dart';

/// Environment Config Provider
final envConfigProvider = Provider<EnvConfig>((ref) {
  return EnvConfig.dev();
});

/// SharedPreferences instance provider (must be overridden in main)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in ProviderScope');
});

/// Storage Service Provider
final storageServiceProvider = Provider<IStorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return StorageService(prefs: prefs);
});

/// Connectivity Service Provider
final connectivityServiceProvider = Provider<IConnectivityService>((ref) {
  return ConnectivityService(connectivity: Connectivity());
});

/// Download Service Provider
final downloadServiceProvider = Provider<IDownloadService>((ref) {
  return DownloadService();
});

/// Dio Instance Provider with full Interceptor Stack
final dioProvider = Provider<Dio>((ref) {
  final env = ref.watch(envConfigProvider);
  final storageService = ref.watch(storageServiceProvider);

  final dio = Dio(BaseOptions(
    baseUrl: env.baseUrl,
    connectTimeout: env.connectTimeout,
    receiveTimeout: env.receiveTimeout,
    sendTimeout: env.sendTimeout,
  ));

  // Interceptor pipeline order:
  // 1. AuthInterceptor
  // 2. TokenRefreshInterceptor
  // 3. RetryInterceptor
  // 4. LoggingInterceptor
  // 5. ErrorInterceptor
  dio.interceptors.addAll([
    AuthInterceptor(tokenProvider: storageService),
    TokenRefreshInterceptor(dio: dio, refreshHandler: storageService),
    RetryInterceptor(dio: dio),
    AppLoggingInterceptor(enabled: env.enableLogging),
    ErrorInterceptor(),
  ]);

  return dio;
});

/// Generic API Client Provider
final apiClientProvider = Provider<IApiClient>((ref) {
  final env = ref.watch(envConfigProvider);
  final dio = ref.watch(dioProvider);
  return ApiClient(config: env, dio: dio);
});

/// Auth Repository Provider
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final storageService = ref.watch(storageServiceProvider);
  return AuthRepository(apiClient: apiClient, storageService: storageService);
});

/// User Repository Provider
final userRepositoryProvider = Provider<IUserRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return UserRepository(apiClient: apiClient);
});

/// File Repository Provider
final fileRepositoryProvider = Provider<IFileRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final downloadService = ref.watch(downloadServiceProvider);
  return FileRepository(apiClient: apiClient, downloadService: downloadService);
});
