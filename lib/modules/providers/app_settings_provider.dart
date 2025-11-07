import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _isNotificationsEnabled = true;
  bool _isAutoPlayEnabled = false;
  String _selectedLanguage = 'English';
  String _selectedTextSize = 'Medium';
  
  bool _isInitialized = false;

  // Getters
  bool get isDarkMode => _isDarkMode;
  bool get isNotificationsEnabled => _isNotificationsEnabled;
  bool get isAutoPlayEnabled => _isAutoPlayEnabled;
  String get selectedLanguage => _selectedLanguage;
  String get selectedTextSize => _selectedTextSize;
  bool get isInitialized => _isInitialized;

  // Get text scale factor based on selected size
  double get textScaleFactor {
    switch (_selectedTextSize) {
      case 'Small':
        return 0.85;
      case 'Large':
        return 1.15;
      default:
        return 1.0;
    }
  }

  // Get theme colors
  Color get backgroundColor => _isDarkMode ? Colors.grey[900]! : Colors.white;
  Color get cardColor => _isDarkMode ? Colors.grey[800]! : Colors.white;
  Color get textColor => _isDarkMode ? Colors.white : Colors.black87;
  Color get subtitleColor => _isDarkMode ? Colors.grey[300]! : Colors.grey[600]!;

  // Initialize settings from SharedPreferences
  Future<void> initializeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _isNotificationsEnabled = prefs.getBool('isNotificationsEnabled') ?? true;
    _isAutoPlayEnabled = prefs.getBool('isAutoPlayEnabled') ?? false;
    _selectedLanguage = prefs.getString('selectedLanguage') ?? 'English';
    _selectedTextSize = prefs.getString('selectedTextSize') ?? 'Medium';
    _isInitialized = true;
    notifyListeners();
  }

  // Update dark mode
  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    notifyListeners();
  }

  // Update notifications
  Future<void> setNotifications(bool value) async {
    _isNotificationsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isNotificationsEnabled', value);
    notifyListeners();
  }

  // Update auto-play
  Future<void> setAutoPlay(bool value) async {
    _isAutoPlayEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAutoPlayEnabled', value);
    notifyListeners();
  }

  // Update language
  Future<void> setLanguage(String value) async {
    _selectedLanguage = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', value);
    notifyListeners();
  }

  // Update text size
  Future<void> setTextSize(String value) async {
    _selectedTextSize = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedTextSize', value);
    notifyListeners();
  }
}
