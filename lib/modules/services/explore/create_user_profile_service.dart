import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:linkschool/config/env_config.dart';

class CreateUserProfileService {
// baseurl: String
  final String baseUrl = "https://linkskool.net/api/v3/public";

  Future<Map<String, dynamic>> createUserProfile(
      Map<String, dynamic> profileData,
      String UserId,
  ) async {
    // Implementation for creating user profile
     try {
      final apiKey = EnvConfig.apiKey;

      if (apiKey.isEmpty) {
        throw Exception("API KEY not found");
      }

      final url = "$baseUrl/learning/profiles";

      final payload = profileData;
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Accept": "application/json",
          "X-API-KEY": apiKey,
        },
        body: payload,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception("Failed: ${response.body}");

      } else {
      }

      final decoded = json.decode(response.body);
      return decoded;
    } catch (e) {
        throw Exception("Error creating profile: $e");
      }
  }


  Future<Map<String, dynamic>> fetchUserProfiles(String userId) async {
    try {
      final apiKey = EnvConfig.apiKey;

     

      final uri = Uri.parse("$baseUrl/learning/profiles").replace(queryParameters: {
        'user_id': userId,
      });

      final response = await http.get(
        uri,
        headers: {
          "Accept": "application/json",
          "X-API-KEY": apiKey,
        },
      );

      if (response.statusCode != 200) {
        throw Exception("Failed: ${response.body}");
      }

      final decoded = json.decode(response.body);
      return decoded;
    } catch (e) {
      throw Exception("Error fetching profiles: $e");
    }
  }

  // Delete user profile
  Future<void> deleteUserProfile(String profileId) async {
    // Implementation for deleting user profile
    try {
      final apiKey = EnvConfig.apiKey;

      if (apiKey.isEmpty) {
        throw Exception("API KEY not found");
      }

      final url = "$baseUrl/learning/profiles/$profileId";

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          "Accept": "application/json",
          "X-API-KEY": apiKey,
        },
        body: {}
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception("Failed: ${response.body}");

      } else {
      }

    } catch (e) {
        throw Exception("Error deleting profile: $e");
      }
    
  }

  // update user profile
  Future<Map<String, dynamic>> updateUserProfile(
  String profileId,
  Map<String, dynamic> profileData,
) async {
  try {
    final apiKey = EnvConfig.apiKey;
    final url = "$baseUrl/learning/profiles/$profileId";

    // If gender is null, some APIs hate that. Remove nulls.
    profileData.removeWhere((k, v) => v == null);

    final bodyJson = jsonEncode(profileData);


    final response = await http.put(
      Uri.parse(url),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "X-API-KEY": apiKey,
      },
      body: bodyJson,
    );


    if (response.statusCode != 200) {
      throw Exception("Failed: ${response.body}");
    }

    return json.decode(response.body) as Map<String, dynamic>;
  } catch (e) {
    throw Exception("Error updating profile: $e");
  }
}


}


