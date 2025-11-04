import 'package:hive/hive.dart';
import 'package:linkschool/modules/model/admin/home/dashboard_feed_model.dart';
import 'package:linkschool/modules/services/api/api_service.dart';

class FeedsPaginationService {
  final ApiService _apiService;

  FeedsPaginationService(this._apiService);

  /// Fetch dashboard data including overview and feeds

  /// Fetch paginated feeds (all feeds with pagination for "See More" screen)
  Future<List<Feed>> fetchFeeds({
    required int page,
    int limit = 50,
  }) async {
    final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');

    if (loginData == null || loginData['token'] == null) {
      throw Exception("No valid login data or token found");
    }

    final token = loginData['token'] as String;
    _apiService.setAuthToken(token);

    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        endpoint: 'portal/feeds',
        queryParams: {
          'page': page.toString(),
          'limit': limit.toString(),
          'term': 3, // Make sure this term value is correct
        },
      );

      if (!response.success) {
        throw Exception("Failed to fetch feeds: ${response.message}");
      }

      // CORRECTED: Access the data properly based on your JSON structure
      final data = response.rawData?['data'];
      if (data == null) throw Exception("No feeds data found");

      // Get news and questions from the correct location
      final news = (data['news'] as List? ?? [])
          .map((item) => Feed.fromJson(item))
          .toList();

      final questions = (data['questions'] as List? ?? [])
          .map((item) => Feed.fromJson(item))
          .toList();

      // Combine both news and questions
      final allFeeds = [...news, ...questions];

      // Sort by creation date if needed (newest first)
      allFeeds.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return allFeeds;
    } catch (e) {
      print("Error fetching feeds: $e");
      throw Exception("Failed to fetch feeds: $e");
    }
  }

  Future<void> createFeed(Map<String, dynamic> newFeed) async {
    final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
    final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';

    if (loginData == null || loginData['token'] == null) {
      throw Exception("No valid login data or token found");
    }

    final token = loginData['token'] as String;
    _apiService.setAuthToken(token);
    newFeed['_db'] = dbName;

    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        endpoint: 'portal/feeds',
        body: newFeed,
      );

      if (!response.success) {
        throw Exception("Failed to create feed: ${response.message}");
      }
    } catch (e) {
      print("Error creating feed: $e");
      throw Exception("Failed to create feed: $e");
    }
  }

  Future<void> updateFeed(
      String feedId, Map<String, dynamic> updatedFeed) async {
    final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
    final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';

    if (loginData == null || loginData['token'] == null) {
      throw Exception("No valid login data or token found");
    }

    final token = loginData['token'] as String;
    _apiService.setAuthToken(token);
    updatedFeed['_db'] = dbName;

    try {
      final response = await _apiService.put<Map<String, dynamic>>(
        endpoint: 'portal/feeds/$feedId',
        body: updatedFeed,
      );

      if (!response.success) {
        throw Exception("Failed to update feed: ${response.message}");
      }
    } catch (e) {
      print("Error updating feed: $e");
      throw Exception("Failed to update feed: $e");
    }
  }

  Future<void> deleteFeed(String feedId) async {
    final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
    final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';

    if (loginData == null || loginData['token'] == null) {
      throw Exception("No valid login data or token found");
    }

    final token = loginData['token'] as String;
    _apiService.setAuthToken(token);

    try {
      final response = await _apiService.delete<Map<String, dynamic>>(
        endpoint: 'portal/feeds/$feedId',
        body: {'_db': dbName},
      );

      if (!response.success) {
        throw Exception("Failed to delete feed: ${response.message}");
      }
    } catch (e) {
      print("Error deleting feed: $e");
      throw Exception("Failed to delete feed: $e");
    }
  }
}
