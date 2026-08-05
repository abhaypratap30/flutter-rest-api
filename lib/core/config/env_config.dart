enum AppEnvironment { dev, staging, prod }

/// Global environment configuration supporting multiple deployment environments
/// (Development, Staging, Production).
class EnvConfig {
  final AppEnvironment environment;
  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;
  final bool enableLogging;

  const EnvConfig({
    required this.environment,
    required this.baseUrl,
    this.connectTimeout = const Duration(seconds: 15),
    this.receiveTimeout = const Duration(seconds: 15),
    this.sendTimeout = const Duration(seconds: 15),
    this.enableLogging = true,
  });

  /// Factory constructor for Development Environment
  factory EnvConfig.dev() {
    return const EnvConfig(
      environment: AppEnvironment.dev,
      baseUrl: 'https://dummyjson.com',
      enableLogging: true,
    );
  }

  /// Factory constructor for Staging Environment
  factory EnvConfig.staging() {
    return const EnvConfig(
      environment: AppEnvironment.staging,
      baseUrl: 'https://dummyjson.com',
      enableLogging: true,
    );
  }

  /// Factory constructor for Production Environment
  factory EnvConfig.prod() {
    return const EnvConfig(
      environment: AppEnvironment.prod,
      baseUrl: 'https://dummyjson.com',
      enableLogging: false,
    );
  }

  bool get isDev => environment == AppEnvironment.dev;
  bool get isStaging => environment == AppEnvironment.staging;
  bool get isProd => environment == AppEnvironment.prod;
}
