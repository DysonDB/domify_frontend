// 📁 lib/services/api_cache.dart — lightweight TTL cache for API responses
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApiCache {
  static const Duration _ttl = Duration(minutes: 10);
  static final Map<String, _CacheEntry> _mem = {};

  /// Returns cached JSON string if still fresh, otherwise null.
  static Future<String?> get(String key) async {
    // 1. Check in-memory cache first (fastest)
    final mem = _mem[key];
    if (mem != null && !mem.isExpired) return mem.data;

    // 2. Fall back to SharedPreferences (survives hot-restart)
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('cache_$key');
    final ts = prefs.getInt('cache_ts_$key') ?? 0;
    if (raw != null &&
        DateTime.now().millisecondsSinceEpoch - ts < _ttl.inMilliseconds) {
      _mem[key] = _CacheEntry(raw); // warm the in-memory layer
      return raw;
    }
    return null;
  }

  /// Stores a JSON string in both layers.
  static Future<void> set(String key, String data) async {
    _mem[key] = _CacheEntry(data);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cache_$key', data);
    await prefs.setInt(
        'cache_ts_$key', DateTime.now().millisecondsSinceEpoch);
  }

  /// Invalidates a key from both layers.
  static Future<void> invalidate(String key) async {
    _mem.remove(key);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cache_$key');
    await prefs.remove('cache_ts_$key');
  }

  /// Wipe everything (e.g. on pull-to-refresh).
  static Future<void> clear() async {
    _mem.clear();
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('cache_'));
    for (final k in keys) {
      await prefs.remove(k);
    }
  }
}

class _CacheEntry {
  final String data;
  final DateTime _createdAt;
  _CacheEntry(this.data) : _createdAt = DateTime.now();
  bool get isExpired =>
      DateTime.now().difference(_createdAt) > const Duration(minutes: 10);
}
