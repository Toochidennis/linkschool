import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/explore/home/announcement_model.dart';
import 'package:linkschool/modules/services/explore/home/announcement_service.dart';
import 'package:linkschool/modules/services/network/connectivity_service.dart';

class AnnouncementProvider with ChangeNotifier {
  List<AnnouncementModel> _announcements = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<AnnouncementModel> get announcements => _announcements;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Get only published announcements
  List<AnnouncementModel> get publishedAnnouncements {
    return _announcements
        .where((announcement) => announcement.isPublished)
        .toList();
  }

  // Get only sponsored announcements
  List<AnnouncementModel> get sponsoredAnnouncements {
    return _announcements
        .where((announcement) => announcement.sponsored)
        .toList();
  }

  // Get announcements by display position
  List<AnnouncementModel> getAnnouncementsByPosition(String position) {
    return _announcements
        .where((announcement) =>
            announcement.displayPosition.toLowerCase() ==
            position.toLowerCase())
        .toList();
  }

  // Get announcements by author
  List<AnnouncementModel> getAnnouncementsByAuthor(int authorId) {
    return _announcements
        .where((announcement) => announcement.authorId == authorId)
        .toList();
  }

  // Get a single announcement by ID
  AnnouncementModel? getAnnouncementById(int id) {
    try {
      return _announcements.firstWhere((announcement) => announcement.id == id);
    } catch (e) {
      return null;
    }
  }

  final AnnouncementService _announcementService = AnnouncementService();

  void fetchAnnouncements() async {
    final isOnline = await ConnectivityService.isOnline();
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final response = await _announcementService.getAllAnnouncements(
        allowNetwork: isOnline,
      );
      _announcements = response.announcements;

      // Log the fetched announcements for debugging
      print('✅ Fetched ${_announcements.length} announcements');
      print(
          '📊 Published: ${publishedAnnouncements.length}, Sponsored: ${sponsoredAnnouncements.length}');

      if (!isOnline) {
        _errorMessage = 'You are offline. Showing saved announcements.';
      }
    } catch (e) {
      _errorMessage = isOnline
          ? 'Network error. Please try again.'
          : 'No internet connection. Connect and try again.';
      // Log the error for debugging
      print('❌ Error in AnnouncementProvider: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
