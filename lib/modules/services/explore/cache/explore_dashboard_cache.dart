import 'dart:convert';
import 'package:hive/hive.dart';

class ExploreDashboardCacheEntry {
  final DateTime cachedAt;
  final dynamic data;

  ExploreDashboardCacheEntry({
    required this.cachedAt,
    required this.data,
  });
}

class ExploreDashboardCache {
  static const Duration ttl = Duration(hours: 24);
  static const String _boxName = 'explore_dashboard_cache';

  static String coursesKey({int? profileId, String? dateOfBirth}) {
    final idPart = profileId?.toString() ?? 'public';
    final dobPart = (dateOfBirth == null || dateOfBirth.isEmpty)
        ? 'none'
        : dateOfBirth;
    return 'courses:$idPart:$dobPart';
  }

  static Future<void> save(String key, dynamic data) async {
    final box = await Hive.openBox(_boxName);
    final payload = {
      'cachedAt': DateTime.now().toIso8601String(),
      'data': data,
    };
    await box.put(key, jsonEncode(payload));
  }

  static Future<ExploreDashboardCacheEntry?> load(String key) async {
    final box = await Hive.openBox(_boxName);
    final raw = box.get(key);
    if (raw is! String || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final cachedAtRaw = decoded['cachedAt'];
      final cachedAt = DateTime.tryParse(cachedAtRaw ?? '');
      if (cachedAt == null) return null;
      return ExploreDashboardCacheEntry(
        cachedAt: cachedAt,
        data: decoded['data'],
      );
    } catch (_) {
      return null;
    }
  }

  static bool isStale(DateTime cachedAt) {
    return DateTime.now().difference(cachedAt) > ttl;
  }
}
