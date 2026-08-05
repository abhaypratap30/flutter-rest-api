import 'package:flutter_rest_api/core/config/app_constants.dart';

class CacheEntry<T> {
  final T data;
  final DateTime createdAt;
  final Duration ttl;

  CacheEntry(this.data, {Duration? ttl})
      : createdAt = DateTime.now(),
        ttl = ttl ?? AppConstants.defaultCacheDuration;

  bool get isExpired => DateTime.now().difference(createdAt) > ttl;
}

/// In-Memory Caching mechanism with TTL Expiration Strategy
class CacheManager {
  static final CacheManager _instance = CacheManager._internal();
  factory CacheManager() => _instance;
  CacheManager._internal();

  final Map<String, CacheEntry<dynamic>> _cache = {};

  /// Store data in cache with key and optional TTL
  void set<T>(String key, T data, {Duration? ttl}) {
    _cache[key] = CacheEntry<T>(data, ttl: ttl);
  }

  /// Retrieve cached data if present and not expired
  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;

    if (entry.isExpired) {
      _cache.remove(key);
      return null;
    }

    return entry.data as T?;
  }

  /// Check if valid cache key exists
  bool hasValid(String key) {
    return get(key) != null;
  }

  /// Remove key from cache
  void remove(String key) {
    _cache.remove(key);
  }

  /// Clear all cached data
  void clear() {
    _cache.clear();
  }
}
