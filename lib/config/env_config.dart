import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  // Private constructor to prevent instantiation
  EnvConfig._();
  
  // Static instance for singleton access
  static final EnvConfig _instance = EnvConfig._();
  
  // Factory constructor to return the singleton instance
  factory EnvConfig() => _instance;
  
  // Environment variables
  static String get apiKey => dotenv.env['API_KEY'] ?? '';
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? 'https://linkskool.net/api/v3';
  static String get dbName => dotenv.env['DB_NAME'] ?? 'aalmgzmy_linkskoo_practice';
  
  // Initialize the environment variables
  static Future<void> init() async {
    await dotenv.load(fileName: ".env");
  }
}