import 'package:hive/hive.dart';

class EnvConfig {
  static const String _unsetValue = '__SET_VIA_DART_DEFINE__';

  EnvConfig._();

  static final EnvConfig _instance = EnvConfig._();

  factory EnvConfig() => _instance;

  // Build-time environment variables injected via --dart-define.
  // Keep real values out of source control and provide them from local/CI define files.
  static String get apiKey =>
      const String.fromEnvironment('API_KEY', defaultValue: _unsetValue);

  static String get apiBaseUrl => const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'https://linkskool.net/api/v3',
      );

  static String get googleAdsApiKey => const String.fromEnvironment(
        '_googleadsApiKey',
        defaultValue: _unsetValue,
      );

  static String get googleBannerAdsApiKey => const String.fromEnvironment(
        '_googlebanneradsApiKey',
        defaultValue: _unsetValue,
      );

  static String get cbtAdsOpenApiKey => const String.fromEnvironment(
        '_googlecbtopenadskey',
        defaultValue: _unsetValue,
      );

  static String get programAdsOpenApiKey => const String.fromEnvironment(
        '_googleprogramopenadskey',
        defaultValue: _unsetValue,
      );

  static String get newsAdsOpenApiKey => const String.fromEnvironment(
        '_googlenewsopenadskey',
        defaultValue: _unsetValue,
      );

  static String get googleCbtInterstitialAdsApiKey =>
      const String.fromEnvironment(
        '_googleCbtInterstitialAdsApiKey',
        defaultValue: _unsetValue,
      );

  static String get NewsInterstitialAdsApiKey => const String.fromEnvironment(
        '_newsinterstitialadsApiKey',
        defaultValue: _unsetValue,
      );

  static String get programRewardsAdsKey => const String.fromEnvironment(
        'programrewardsAdsKey',
        defaultValue: _unsetValue,
      );

  static String get programBannersAdsKey => const String.fromEnvironment(
        'programbannersAdsKey',
        defaultValue: _unsetValue,
      );

  static String get programInterstitialAdsApiKey =>
      const String.fromEnvironment(
        '_programinterstitialadsApiKey',
        defaultValue: _unsetValue,
      );

  static String get newsNativeAds => const String.fromEnvironment(
        '_newsnativeadsApiKey',
        defaultValue: _unsetValue,
      );

  static String get deepSeekApiKey => const String.fromEnvironment(
        'DEEP_SEEK_API_KEY',
        defaultValue: _unsetValue,
      );

  static String get deepSeekUrl => const String.fromEnvironment(
        'DEEP_SEEK_URL',
        defaultValue: 'https://api.deepseek.com/v1/chat/completions',
      );

  static String get paystackSecretKey => const String.fromEnvironment(
        'PAYSTACK_SECRET_KEY',
        defaultValue: _unsetValue,
      );

  static String get gamifyAdOpenKey => const String.fromEnvironment(
        'GAMIFY_AD_OPEN_KEY',
        defaultValue: _unsetValue,
      );

  static String get gamifyInterstitialKey => const String.fromEnvironment(
        'GAMIFY_INTERSTITIAL_KEY',
        defaultValue: _unsetValue,
      );

  static String get gamifyRewardKey => const String.fromEnvironment(
        'GAMIFY_REWARD_KEY',
        defaultValue: _unsetValue,
      );

  static String get gamifyBannerAdKey => const String.fromEnvironment(
        'GAMIFY_BANNER_AD_KEY',
        defaultValue: _unsetValue,
      );

  static String get studyAdOpenKey => const String.fromEnvironment(
        'STUDY_AD_OPEN_KEY',
        defaultValue: _unsetValue,
      );

  static String get studyInterstitialKey => const String.fromEnvironment(
        'STUDY_INTERSTITIAL_KEY',
        defaultValue: _unsetValue,
      );

  static String get studyRewardKey => const String.fromEnvironment(
        'STUDY_REWARD_KEY',
        defaultValue: _unsetValue,
      );

  static String get challengeAdOpenKey => const String.fromEnvironment(
        'CHALLENGE_AD_OPEN_KEY',
        defaultValue: _unsetValue,
      );

  static String get challengeInterstitialKey => const String.fromEnvironment(
        'CHALLENGE_INTERSTITIAL_KEY',
        defaultValue: _unsetValue,
      );

  static String get challengeRewardKey => const String.fromEnvironment(
        'CHALLENGE_REWARD_KEY',
        defaultValue: _unsetValue,
      );

  static String get challengeBannerAdKey => const String.fromEnvironment(
        'CHALLENGE_BANNER_AD_KEY',
        defaultValue: _unsetValue,
      );

  static String get homeBannerAdKey => const String.fromEnvironment(
        'HOME_BANNER_AD_KEY',
        defaultValue: _unsetValue,
      );

  static String get homeAdsOpenKey => const String.fromEnvironment(
        'HOME_ADS_OPEN_KEY',
        defaultValue: _unsetValue,
      );

  static String get linkSkoolAiHomeBannerAdKey => const String.fromEnvironment(
        'LINKSKOOL_AI_HOME_BANNER_AD_KEY',
        defaultValue: _unsetValue,
      );

  static String get linkSkoolAiInterstitialAdKey =>
      const String.fromEnvironment(
        'LINKSKOOL_AI_INTERSTITIAL_AD_KEY',
        defaultValue: _unsetValue,
      );

  static String get linkSkoolAiAdOpenKey => const String.fromEnvironment(
        'LINKSKOOL_AI_AD_OPEN_KEY',
        defaultValue: _unsetValue,
      );

  static String get discussionBannerAdKey => const String.fromEnvironment(
        'DISCUSSION_BANNER_AD_KEY',
        defaultValue: _unsetValue,
      );

  static String get discussionAdsOpenKey => const String.fromEnvironment(
        'DISCUSSION_ADS_OPEN_KEY',
        defaultValue: _unsetValue,
      );

  static String get discussionInterstitialAdKey => const String.fromEnvironment(
        'DISCUSSION_INTERSTITIAL_AD_KEY',
        defaultValue: _unsetValue,
      );

  // Dynamic database name - gets from current user session
  static String get dbName {
    try {
      final userBox = Hive.box('userData');
      final db = userBox.get('_db');
      if (db != null && db.toString().isNotEmpty) {
        return db.toString();
      }
      return 'aalmgzmy_linkskoo_practice';
    } catch (e) {
      return 'aalmgzmy_linkskoo_practice';
    }
  }

  static String getDatabaseName() {
    try {
      final userBox = Hive.box('userData');
      final db = userBox.get('_db');
      if (db == null || db.toString().isEmpty) {
        throw Exception('No database configuration found. Please login again.');
      }
      return db.toString();
    } catch (e) {
      throw Exception('Failed to get database configuration: $e');
    }
  }
}
