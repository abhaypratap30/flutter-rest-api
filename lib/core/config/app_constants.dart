/// Centralized application constants including API endpoints, storage keys,
/// network timeouts, and cache settings.
abstract class AppConstants {
  // --- Storage Keys ---
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserData = 'user_data';
  static const String keyThemeMode = 'theme_mode';

  // --- API Endpoints ---
  static const String endpointLogin = '/auth/login';
  static const String endpointRefreshToken = '/auth/refresh';
  static const String endpointCurrentUser = '/auth/me';
  static const String endpointUsers = '/users';
  static const String endpointSearchUsers = '/users/search';
  static const String endpointFileUpload = '/http/200'; // Mock success endpoint for upload demo
  static const String endpointFileDownload = '/users';   // Json payload for file download simulation

  // --- Header Keys ---
  static const String headerAuthorization = 'Authorization';
  static const String headerBearerPrefix = 'Bearer ';
  static const String headerContentType = 'Content-Type';
  static const String headerAccept = 'Accept';
  static const String headerJson = 'application/json';

  // --- Pagination Defaults ---
  static const int defaultPageSize = 10;
  static const int initialPage = 1;

  // --- Network Cache ---
  static const Duration defaultCacheDuration = Duration(minutes: 5);
}
