import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:linkschool/modules/explore/cbt/cbt_challange/challange_modal.dart';


class ChallengeService {
  final String _baseUrl = "https://linkskool.net/api/v3/public";

 Future<ChallengeResponse> fetchChallenges({required int authorId, required int examTypeId}) async {
  try {
    final apiKey = dotenv.env['API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception("API KEY not found");
    }

    final url = "$_baseUrl/cbt/challenges?author_id=$authorId &exam_type_id=$examTypeId";
    print("📡 Fetching Challenges → $url");

    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Accept": "application/json",
        "X-API-KEY": apiKey,
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Failed: ${response.body}");
    }

    final decoded = json.decode(response.body);

    return ChallengeResponse.fromJson(decoded);

  } catch (e) {
    throw Exception("Error: $e");
  }
}

  // Already created method (Create Challenge)
  Future<void> createChallenge({
    required Map<String, dynamic> payload,
  }) async {
    try {
      final apiKey = dotenv.env['API_KEY'];

      if (apiKey == null || apiKey.isEmpty) {
        throw Exception("❌ API key not found in .env file");
      }

      final url = "$_baseUrl/cbt/challenges";

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-API-KEY': apiKey,
        },
        body: json.encode(payload),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception("Server error: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error creating Challenge: $e.");
    }
  }

   Future<void> updateChallenge({
    required int challengeId,
    required Map<String, dynamic> payload,}) async {
    try {
      final apiKey = dotenv.env['API_KEY'];

      if (apiKey == null || apiKey.isEmpty) {
        throw Exception("❌ API key not found in .env file");
      }

      final url = "$_baseUrl/cbt/challenges/$challengeId/";

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-API-KEY': apiKey,
        },
        body: json.encode(payload),
      );

      if (response.statusCode != 200) {
        throw Exception("Server error: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error updating Challenge: $e.");
    }
}

    Future<void> deleteChallenge({required int challengeId,required int authorId}) async {
    try {
      final apiKey = dotenv.env['API_KEY'];

      if (apiKey == null || apiKey.isEmpty) {
        throw Exception("❌ API key not found in .env file");
      }

      final url = "$_baseUrl/cbt/challenges/$challengeId";

      print('complete url : $url');

      final response = await http.delete(
        Uri.parse(url),
        headers: {
           'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-API-KEY': apiKey,
        }, 
        body: json.encode({
          'author_id': authorId,
        
        })
        );
     
      if (response.statusCode != 200) {
        print(response.body);
        throw Exception("Server error: ${response.body}"); }}    catch (e) {
      throw Exception("Error deleting Challenge: $e.");
        }}

        //  update challange status
    Future<void> updateChallengeStatus({
    required int challengeId, required String status}) async {
      try {
      final apiKey = dotenv.env['API_KEY'];

      if (apiKey == null || apiKey.isEmpty) {
        throw Exception("❌ API key not found in .env file");
      }

      final url = "$_baseUrl/cbt/challenges/status/$challengeId";

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-API-KEY': apiKey,
        },
        body: json.encode({
          'status': status,
        }),
      );
      print("📡 Updating Challenge Status → $url");
      print ("this is challenge id $challengeId");
      print("this is challenge status $status");
      print("this is response status code ${response.statusCode}");

      if (response.statusCode != 200) {
        print("this is response body ${response.body}");
        throw Exception("Server error: ${response.body}");
        
      }
    } catch (e) {
      throw Exception("Error updating Challenge status: $e.");
    }
    }

}