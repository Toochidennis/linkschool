import 'dart:convert';

import 'package:linkschool/modules/model/explore/cbt_active_session_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CbtActiveSessionService {
  static const String _sessionKey = 'cbt_active_session';

  Future<void> saveSession(CbtActiveSessionModel session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, jsonEncode(session.toJson()));
  }

  Future<CbtActiveSessionModel?> getActiveSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_sessionKey);
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return CbtActiveSessionModel.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return null;
    }
  }

  Future<void> clearActiveSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }
}
