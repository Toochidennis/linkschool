import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/admin/home/add_staff_model.dart';

import 'package:linkschool/modules/services/admin/home/add_staff_service.dart';

class AddStaffProvider with ChangeNotifier {
  final AddStaffService _addStaffService;

  
 bool isLoading = false;
  bool isFetching = false;
  String? message;
  String? error;
  List<Staff> staffList = [];
  AddStaffProvider(this._addStaffService);


 Future<bool> createStaff(Map<String, dynamic> newStaff) async {
    isLoading = true;
    notifyListeners();
    error = null;
    message = null;
    try {
      await _addStaffService.CreateStaff(newStaff);
      message = "Staff created successfully.";
      return true;
    } catch (e) {
      error = "Failed to create Staff: $e";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }



 Future<void> fetchAllStaff() async {
    isFetching = true;
    error = null;
    notifyListeners();
    
    try {
      staffList = await _addStaffService.fetchAllStaff();
      print("Fetched ${staffList.length} staff members");
    } catch (e) {
      error = "Failed to fetch staff: $e";
      print("Error in provider: $e");
    } finally {
      isFetching = false;
      notifyListeners();
    }
  }


  Future<bool> updateStaff(String staffId, Map<String, dynamic> updatedStaff) async {
    isLoading = true;
    notifyListeners();
    error = null;
    message = null;
    
    try {
      await _addStaffService.updateStaff(staffId, updatedStaff);
      message = "Staff updated successfully.";
      
      // Automatically fetch staff list after updating
      await fetchAllStaff();
      
      return true;
    } catch (e) {
      error = "Failed to update staff: $e";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Delete staff
  Future<bool> deleteStaff(int staffId) async {
    isLoading = true;
    notifyListeners();
    error = null;
    message = null;
    
    try {
      await _addStaffService.deleteStaff(staffId);
      message = "Staff deleted successfully.";
      
      // Remove from local list
      staffList.removeWhere((staff) => staff.id == staffId);
      
      return true;
    } catch (e) {
      error = "Failed to delete staff: $e";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
 
}
