import 'package:hive/hive.dart';
class EnvConfig {
  // Private constructor to prevent instantiation
  EnvConfig._();

  // Static instance for singleton access
  static final EnvConfig _instance = EnvConfig._();

  // Factory constructor to return the singleton instance
  factory EnvConfig() => _instance;

  // Environment variables
  static String get apiKey => const String.fromEnvironment('API_KEY',
      defaultValue: 'JMNNKyryPpQsy+bmuELQ3DWngnxFlOobbcgG4nebj0sLjVvxKSAMw/fWTDOsEVkm0ooKYua9VSjudC1L5hG0zg==');

  static String get apiBaseUrl => const String.fromEnvironment('API_BASE_URL',
      defaultValue: 'https://linkskool.net/api/v3');
  static String get googleAdsApiKey =>
      const String.fromEnvironment('_googleadsApiKey',
          defaultValue:
              'ca-app-pub-3940256099942544/5224354917'); // Fallback to test ID

  static String get deepSeekApiKey =>
      const String.fromEnvironment('DEEP_SEEK_API_KEY',
          defaultValue: 'sk-958c40e31ad941e4a31cf13ea3583f80');

  static String get deepSeekUrl => const String.fromEnvironment('DEEP_SEEK_URL',
      defaultValue: 'https://api.deepseek.com/v1/chat/completions');

  static String get paystackSecretKey =>
      const String.fromEnvironment('PAYSTACK_SECRET_KEY',
          defaultValue: 'sk_test_96d9c3448796ac0b090dfc18a818c67a292faeea');

  // Dynamic database name - gets from current user session
  static String get dbName {
    try {
      final userBox = Hive.box('userData');
      final db = userBox.get('_db');
      if (db != null && db.toString().isNotEmpty) {
        return db.toString();
      }
      // Fallback - but this should ideally never be used in production
      print('Warning: No dynamic database found, using fallback');
      return 'aalmgzmy_linkskoo_practice';
    } catch (e) {
      print('Error getting dynamic database: $e');
      return 'aalmgzmy_linkskoo_practice';
    }
  }

  // Method to get database with explicit error handling
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

  // // Initialize the environment variables
  // static Future<void> init() async {
  //   await dotenv.load(fileName: ".env");
  // }
}
