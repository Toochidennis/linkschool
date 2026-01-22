import 'package:flutter/material.dart';
import 'package:linkschool/modules/services/explore/create_user_profile_service.dart';
import 'package:linkschool/modules/model/cbt_user_model.dart';

class CreateUserProfileProvider extends ChangeNotifier {
  final CreateUserProfileService _createUserProfileService =
      CreateUserProfileService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;


  Future<List<CbtUserProfile>> createUserProfile(Map<String, dynamic> profileData, String USerId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final responseJson = await _createUserProfileService.createUserProfile(profileData, USerId);

      // Expected shape: { statusCode, status, message, data: [ {...}, {...} ] }
      final data = responseJson['data'];
      if (data == null) throw Exception('No profile data returned from server');

      List<CbtUserProfile> profiles = [];
      if (data is List) {
        profiles = data.map((e) => CbtUserProfile.fromJson(e as Map<String, dynamic>)).toList();
      } else if (data is Map<String, dynamic>) {
        profiles = [CbtUserProfile.fromJson(data)];
      } else {
        throw Exception('Unexpected profile data format');
      }

      return profiles;
    } catch (e) {
      throw Exception("Error in provider while creating profile: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete user profile
  Future<void> deleteUserProfile(String profileId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _createUserProfileService.deleteUserProfile(profileId);
    } catch (e) {
      throw Exception("Error in provider while deleting profile: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}


