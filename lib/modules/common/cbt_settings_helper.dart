import 'package:linkschool/modules/model/explore/cbt_settings_model.dart';
import 'package:linkschool/modules/services/explore/cbt_settings_service.dart';

/// Helper class to easily access CBT settings throughout the app
class CbtSettingsHelper {
  static CbtSettingsModel? _cachedSettings;
  static DateTime? _lastFetchTime;
  static const Duration _cacheDuration = Duration(minutes: 30);
  static final CbtSettingsService _service = CbtSettingsService();

  /// Get CBT settings (cached or fetch new)
  static Future<CbtSettingsModel> getSettings() async {
    // Return cached if still fresh
    print('🔍 Checking CBT settings cache...');
    print('🕒 Last fetch time: $_cachedSettings');
    if (_cachedSettings != null && _lastFetchTime != null) {
      final age = DateTime.now().difference(_lastFetchTime!);
      if (age < _cacheDuration) {
        print('📦 Using cached CBT settings');
        return _cachedSettings!;
      }
    }

    try {
      print('🔄 Fetching fresh CBT settings...');
      final settings = await _service.fetchCbtSettings();
      _cachedSettings = settings;
      _lastFetchTime = DateTime.now();
      print(
          '✅ CBT settings loaded: amount=${settings.amount}, discount=${settings.discountRate}, trial=${settings.freeTrialDays}');
      return settings;
    } catch (e) {
      print('❌ Error fetching CBT settings: $e');
      // If we have cached data, use it even if expired
      if (_cachedSettings != null) {
        print('⚠️ Using expired cached settings');
        return _cachedSettings!;
      }
      // Return default settings as fallback
      print('⚠️ Using default fallback settings');
      return _getDefaultSettings();
    }
  }

  /// Get cached settings synchronously (may be null)
  static CbtSettingsModel? getCachedSettings() {
    return _cachedSettings;
  }

  /// Get subscription amount (with discount applied if any)
  static Future<int> getSubscriptionAmount() async {
    final settings = await getSettings();
    if (settings.discountRate > 0) {
      return (settings.amount * (1 - settings.discountRate)).round();
    }
    return settings.amount;
  }

  /// Get original amount (before discount)
  static Future<int> getOriginalAmount() async {
    final settings = await getSettings();
    return settings.amount;
  }

  /// Get discount rate
  static Future<double> getDiscountRate() async {
    final settings = await getSettings();
    return settings.discountRate;
  }

  /// Get free trial days
  static Future<int> getFreeTrialDays() async {
    final settings = await getSettings();
    return settings.freeTrialDays;
  }

  /// Clear cached settings (useful for testing)
  static void clearCache() {
    _cachedSettings = null;
    _lastFetchTime = null;
    print('🗑️ CBT settings cache cleared');
  }

  /// Default settings as fallback
  static CbtSettingsModel _getDefaultSettings() {
    return CbtSettingsModel(
      challengeDurationLimit: 120,
      maxExamsPerChallenge: 5,
      minQuestionsPerExam: 10,
      passingScorePercentage: 50,
      leaderboardEnabled: true,
      notificationEmails: true,
      amount: 400,
      discountRate: 0.0,
      freeTrialDays: 3,
    );
  }
}
