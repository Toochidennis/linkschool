import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/model/admin/home/dashboard_feed_model.dart';
import 'package:linkschool/modules/services/api/api_service.dart';

class DashboardFeedService {
  final ApiService _apiService;

  DashboardFeedService(this._apiService);

  /// Fetch dashboard data including overview and feeds
  Future<DashboardData> fetchDashboardData() async {
    final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');

    if (loginData == null || loginData['token'] == null) {
      throw Exception("No valid login data or token found");
    }

    final processedData = loginData is String
        ? json.decode(loginData)
        : loginData as Map<String, dynamic>;
    final responseData = processedData['response'] ?? processedData;
    final data = responseData['data'] ?? responseData;
    final profile = data['profile'] ?? {};
    final settings = data['settings'] ?? {};
    final academicYear = settings['year']?.toString();
    final academicTerm = settings['term'] as int?;

    final token = loginData['token'] as String;
    _apiService.setAuthToken(token);

    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        endpoint: 'portal/dashboard/admin',
        queryParams: {
          'term': academicTerm,
        },
      );

      if (!response.success) {
        throw Exception("Failed to fetch dashboard data: ${response.message}");
      }

      final data = response.rawData?['data'];
      if (data == null) throw Exception("No data found");

      return DashboardData.fromJson(data);
    } catch (e) {
      print("Error fetching dashboard data: $e");
      throw Exception("Failed to fetch dashboard data: $e");
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

  Future<void> updateFeed(String feedId, Map<String, dynamic> updatedFeed) async {
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