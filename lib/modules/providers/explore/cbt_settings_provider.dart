import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/explore/cbt_settings_model.dart';
import 'package:linkschool/modules/services/explore/cbt_settings_service.dart';


class CbtSettingsProvider extends ChangeNotifier {
  final CbtSettingsService _service;

  CbtSettingsModel? settings;
  bool loading = false;
  String? error;
  
  // Cached settings for quick access
  static CbtSettingsModel? _cachedSettings;
  static DateTime? _lastFetchTime;
  static const Duration _cacheDuration = Duration(minutes: 50);

  CbtSettingsProvider(this._service);

  Future<void> loadSettings() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      settings = await _service.fetchCbtSettings();
      _cachedSettings = settings;
      _lastFetchTime = DateTime.now();
    } catch (e) {
      error = e.toString();
    }

    loading = false;
    notifyListeners();
  }
  
  /// Get cached settings or fetch if needed
  Future<CbtSettingsModel?> getSettings() async {
    // Return cached if still fresh
    if (_cachedSettings != null && _lastFetchTime != null) {
      final age = DateTime.now().difference(_lastFetchTime!);
      if (age < _cacheDuration) {
        return _cachedSettings;
      }
    }
    
    // Fetch fresh settings
    try {
      settings = await _service.fetchCbtSettings();
      _cachedSettings = settings;
      _lastFetchTime = DateTime.now();
      return settings;
    } catch (e) {
      error = e.toString();
      // Return cached even if expired, better than nothing
      return _cachedSettings;
    }
  }
  
  /// Static method to get cached settings without provider
  static CbtSettingsModel? getCachedSettings() {
    return _cachedSettings;
  }
}
