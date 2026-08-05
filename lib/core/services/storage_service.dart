import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_rest_api/core/config/app_constants.dart';
import 'package:flutter_rest_api/core/network/interceptors/auth_interceptor.dart';
import 'package:flutter_rest_api/core/network/interceptors/token_refresh_interceptor.dart';

abstract class IStorageService implements ITokenProvider, ITokenRefreshHandler {
  Future<void> saveTokens({required String accessToken, required String refreshToken});
  Future<void> clearTokens();
  Future<void> saveUserData(Map<String, dynamic> userData);
  Future<Map<String, dynamic>?> getUserData();
  Future<void> clearAll();
}

/// Hybrid Secure & Preferences Storage Service for authentication tokens and session data.
class StorageService implements IStorageService {
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences prefs;

  StorageService({
    FlutterSecureStorage? secureStorage,
    required this.prefs,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  @override
  Future<String?> getAccessToken() async {
    try {
      return await _secureStorage.read(key: AppConstants.keyAccessToken) ??
          prefs.getString(AppConstants.keyAccessToken);
    } catch (_) {
      return prefs.getString(AppConstants.keyAccessToken);
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return await _secureStorage.read(key: AppConstants.keyRefreshToken) ??
          prefs.getString(AppConstants.keyRefreshToken);
    } catch (_) {
      return prefs.getString(AppConstants.keyRefreshToken);
    }
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      await _secureStorage.write(key: AppConstants.keyAccessToken, value: accessToken);
      await _secureStorage.write(key: AppConstants.keyRefreshToken, value: refreshToken);
    } catch (_) {
      // Fallback for platform issues
    }
    await prefs.setString(AppConstants.keyAccessToken, accessToken);
    await prefs.setString(AppConstants.keyRefreshToken, refreshToken);
  }

  @override
  Future<void> clearTokens() async {
    try {
      await _secureStorage.delete(key: AppConstants.keyAccessToken);
      await _secureStorage.delete(key: AppConstants.keyRefreshToken);
    } catch (_) {}
    await prefs.remove(AppConstants.keyAccessToken);
    await prefs.remove(AppConstants.keyRefreshToken);
  }

  @override
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final rawJson = jsonEncode(userData);
    await prefs.setString(AppConstants.keyUserData, rawJson);
  }

  @override
  Future<Map<String, dynamic>?> getUserData() async {
    final rawJson = prefs.getString(AppConstants.keyUserData);
    if (rawJson == null) return null;
    try {
      return jsonDecode(rawJson) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> refreshTokens(String refreshToken) async {
    // Simulated token refresh returning refreshed JWT for demo
    final newAccessToken = 'refreshed_access_token_${DateTime.now().millisecondsSinceEpoch}';
    final newRefreshToken = 'refreshed_refresh_token_${DateTime.now().millisecondsSinceEpoch}';
    await saveTokens(accessToken: newAccessToken, refreshToken: newRefreshToken);
    return true;
  }

  @override
  Future<void> onLogoutRequired() async {
    await clearAll();
  }

  @override
  Future<void> clearAll() async {
    await clearTokens();
    await prefs.remove(AppConstants.keyUserData);
  }
}
