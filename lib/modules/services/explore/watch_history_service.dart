import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:linkschool/modules/model/explore/home/video_model.dart';

class WatchHistoryService {
  static const String _watchHistoryKey = 'watch_history';
  static const int _maxHistoryItems = 50; // Limit to 50 most recent videos

  // Add a video to watch history
  static Future<void> addToWatchHistory(Video video) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> history = prefs.getStringList(_watchHistoryKey) ?? [];

      // Convert video to JSON
      final videoJson = jsonEncode({
        'title': video.title,
        'url': video.url,
        'thumbnail': video.thumbnail,
        'watchedAt': DateTime.now().toIso8601String(),
      });

      // Remove if already exists (to move it to the top)
      history.removeWhere((item) {
        final Map<String, dynamic> data = jsonDecode(item);
        return data['url'] == video.url;
      });

      // Add to the beginning of the list
      history.insert(0, videoJson);

      // Limit the history size
      if (history.length > _maxHistoryItems) {
        history = history.sublist(0, _maxHistoryItems);
      }

      // Save to SharedPreferences
      await prefs.setStringList(_watchHistoryKey, history);
    } catch (e) {
      print('Error adding to watch history: $e');
    }
  }

  // Get watch history
  static Future<List<Video>> getWatchHistory({int? limit}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> history = prefs.getStringList(_watchHistoryKey) ?? [];

      // Convert JSON strings back to Video objects
      List<Video> videos = history.map((item) {
        final Map<String, dynamic> data = jsonDecode(item);
        return Video(
          title: data['title'] ?? '',
          url: data['url'] ?? '',
          thumbnail: data['thumbnail'] ?? '',
        );
      }).toList();

      // Return limited or full list
      if (limit != null && limit < videos.length) {
        return videos.sublist(0, limit);
      }

      return videos;
    } catch (e) {
      print('Error getting watch history: $e');
      return [];
    }
  }

  // Clear watch history
  static Future<void> clearWatchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_watchHistoryKey);
    } catch (e) {
      print('Error clearing watch history: $e');
    }
  }

  // Remove a specific video from history
  static Future<void> removeFromWatchHistory(String videoUrl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> history = prefs.getStringList(_watchHistoryKey) ?? [];

      history.removeWhere((item) {
        final Map<String, dynamic> data = jsonDecode(item);
        return data['url'] == videoUrl;
      });

      await prefs.setStringList(_watchHistoryKey, history);
    } catch (e) {
      print('Error removing from watch history: $e');
    }
  }

  // Check if a video is in watch history
  static Future<bool> isInWatchHistory(String videoUrl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> history = prefs.getStringList(_watchHistoryKey) ?? [];

      return history.any((item) {
        final Map<String, dynamic> data = jsonDecode(item);
        return data['url'] == videoUrl;
      });
    } catch (e) {
      print('Error checking watch history: $e');
      return false;
    }
  }
}
