// challenge_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ChallengeService {
  static const String _challengesKey = 'saved_challenges';
  
  // Save challenge to SharedPreferences
  static Future<void> saveChallenge(Map<String, dynamic> challenge) async {
    final prefs = await SharedPreferences.getInstance();
    final existingChallenges = await getChallenges();
    
    // Add new challenge
    existingChallenges.add(challenge);
    
    // Save back to SharedPreferences
    await prefs.setString(_challengesKey, json.encode(existingChallenges));
    
    print('💾 Challenge saved: ${challenge['title']}');
    print('📋 Total challenges: ${existingChallenges.length}');
  }
  
  // Get all saved challenges
  static Future<List<Map<String, dynamic>>> getChallenges() async {
    final prefs = await SharedPreferences.getInstance();
    final challengesJson = prefs.getString(_challengesKey);
    
    if (challengesJson == null) {
      return [];
    }
    
    try {
      final List<dynamic> challengesList = json.decode(challengesJson);
      return challengesList.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (e) {
      print('Error parsing challenges: $e');
      return [];
    }
  }
  
  // Remove challenge
  static Future<void> removeChallenge(String challengeId) async {
    final prefs = await SharedPreferences.getInstance();
    final existingChallenges = await getChallenges();
    
    existingChallenges.removeWhere((challenge) => challenge['id'] == challengeId);
    
    await prefs.setString(_challengesKey, json.encode(existingChallenges));
  }
}