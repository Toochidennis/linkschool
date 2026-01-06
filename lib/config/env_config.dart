import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';

class EnvConfig {
  // Private constructor to prevent instantiation
  EnvConfig._();

  // Static instance for singleton access
  static final EnvConfig _instance = EnvConfig._();

  // Factory constructor to return the singleton instance
  factory EnvConfig() => _instance;

  // Environment variables
  static String get apiKey => dotenv.env['API_KEY'] ?? '';
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'https://linkskool.net/api/v3';
  static String get googleAdsApiKey =>
      dotenv.env['_googleadsApiKey'] ??
      'ca-app-pub-3940256099942544/5224354917'; // Fallback to test ID

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

  // Initialize the environment variables
  static Future<void> init() async {
    await dotenv.load(fileName: ".env");
  }
}

// import 'package:flutter_dotenv/flutter_dotenv.dart';

// class EnvConfig {
//   // Private constructor to prevent instantiation
//   EnvConfig._();

//   // Static instance for singleton access
//   static final EnvConfig _instance = EnvConfig._();

//   // Factory constructor to return the singleton instance
//   factory EnvConfig() => _instance;

//   // Environment variables
//   static String get apiKey => dotenv.env['API_KEY'] ?? '';
//   static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? 'https://linkskool.net/api/v3';
//   static String get dbName => dotenv.env['DB_NAME'] ?? 'aalmgzmy_linkskoo_practice';

//   // Initialize the environment variables
//   static Future<void> init() async {
//     await dotenv.load(fileName: ".env");
//   }
// }
