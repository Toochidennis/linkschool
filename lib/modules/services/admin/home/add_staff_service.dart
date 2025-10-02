import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/model/admin/home/add_staff_model.dart';
import 'package:linkschool/modules/services/api/api_service.dart';

class AddStaffService {
 final ApiService _apiService;
 AddStaffService(this._apiService);



Future<void> CreateStaff(Map<String, dynamic> newStaff) async {
    final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
    final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';
    if (loginData == null || loginData['token'] == null) {
      throw Exception("No valid login data or token found");
    }

    final token = loginData['token'] as String;
  
    _apiService.setAuthToken(token);

    newStaff['_db'] = dbName;
    print("Request Payload: $newStaff");

    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        endpoint: 'portal/staff',
        body: newStaff,
      );

      print("Response Status Code: ${response.statusCode}");

      if (!response.success) {
        print("Failed to create staff");

        print("Error: ${response.message ?? 'No error message provided'}");
        SnackBar(
          content: Text("${response.message}"),
          backgroundColor: Colors.red,
        );
        throw Exception("Failed to Create staff: ${response.message}");
      } else {
        print('staff created successfully.');
        print('Status Code: ${response.statusCode}');
        SnackBar(
          content: Text('staff created successfully.'),
          backgroundColor: Colors.green,
        );
        print('${response.message}');
      }
    } catch (e) {
      print("Error creating staff: $e");
      throw Exception("Failed to Create staff: $e");
    }

  }



 Future<List<Staff>> fetchAllStaff() async {
    final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
    final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';
    
    if (loginData == null || loginData['token'] == null) {
      throw Exception("No valid login data or token found");
    }

    final token = loginData['token'] as String;
    _apiService.setAuthToken(token);

    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        endpoint: 'portal/staff',
        queryParams: {
          '_db': dbName,
        },
      );

      print("Fetch Staff Response Status Code: ${response.statusCode}");

      if (!response.success) {
        print("Failed to fetch staff");
        print("Error: ${response.message ?? 'No error message provided'}");
        throw Exception("Failed to fetch staff: ${response.message}");
      }

      // Parse the response
      final data = response.rawData?['response'];
      
      if (data is List) {
        print('Staff fetched successfully: ${data.length} staff members found.');
        return data.map((json) => Staff.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        print("Unexpected response format");
        throw Exception("Unexpected response format");
      }
    } catch (e) {
      print("Error fetching staff: $e");
      throw Exception("Failed to fetch staff: $e");
    }
  }
 

 Future<void> updateStaff(String staffId, Map<String, dynamic> updatedStaff) async {
    final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
    final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';
    
    if (loginData == null || loginData['token'] == null) {
      throw Exception("No valid login data or token found");
    }

    final token = loginData['token'] as String;
    _apiService.setAuthToken(token);

    updatedStaff['_db'] = dbName;
    print("Update Request Payload: $updatedStaff");

    try {
      final response = await _apiService.put<Map<String, dynamic>>(
        endpoint: 'portal/staff/$staffId',
        body: updatedStaff,
      );

      if (!response.success) {
        print("Failed to update staff");
        print("Error: ${response.message ?? 'No error message provided'}");
        throw Exception("Failed to update staff: ${response.message}");
      } else {
        print('Staff updated successfully.');
      }
    } catch (e) {
      print("Error updating staff: $e");
      throw Exception("Failed to update staff: $e");
    }
  }



  Future<void> deleteStaff(int staffId) async {
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
        endpoint: 'portal/staff/$staffId',
        body: {
          '_db': dbName,
        },
      );

      if (!response.success) {
        print("Failed to delete staff");
        print("Error: ${response.message ?? 'No error message provided'}");
        throw Exception("Failed to delete staff: ${response.message}");
      } else {
        print('Staff deleted successfully.');
      }
    } catch (e) {
      print("Error deleting staff: $e");
      throw Exception("Failed to delete staff: $e");
    }
  }
}