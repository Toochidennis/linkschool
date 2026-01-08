import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:linkschool/modules/model/explore/home/announcement_model.dart';
import 'package:http/http.dart' as http;

class AnnouncementResponse {
  final int statusCode;
  final bool success;
  final List<AnnouncementModel> announcements;

  AnnouncementResponse({
    required this.statusCode,
    required this.success,
    required this.announcements,
  });

  factory AnnouncementResponse.fromJson(Map<String, dynamic> json) {
    return AnnouncementResponse(
      statusCode: json['statusCode'] ?? 200,
      success: json['success'] ?? false,
      announcements: (json['data'] as List<dynamic>?)
              ?.map((item) => AnnouncementModel.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class AnnouncementService {
  final String baseUrl = "https://linkskool.net/api/v3/public/advertisements/published";

  Future<AnnouncementResponse> getAllAnnouncements() async {
    try {
      final apiKey = dotenv.env['API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception("API key not found in .env file");
      }

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-API-KEY': apiKey,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        // Check if API call was successful
        if (jsonData['success'] != true) {
          throw Exception(
              jsonData['message'] ?? 'Failed to load announcements');
        }

        print("✅ Announcements fetched successfully: ${jsonData['message']}");
        return AnnouncementResponse.fromJson(jsonData);
      } else {
        print(
            "❌ Failed to load announcements: ${response.statusCode} ${response.body}");
        throw Exception("Failed to load announcements: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error fetching announcements: $e");
      throw Exception("Failed to load announcements: $e");
    }
  }
}
