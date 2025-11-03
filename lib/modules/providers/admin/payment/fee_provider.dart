import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/admin/fee_name.dart';
// import 'package:linkschool/modules/admin/payment/models/fee_name.dart';
import 'package:linkschool/modules/services/admin/payment/fee_service.dart';
import 'package:hive/hive.dart';

class FeeProvider with ChangeNotifier {
  final FeeService _feeService;

  FeeProvider(this._feeService);

  List<FeeName> _feeNames = [];
  bool _isLoading = false;
  String? _error;

  List<FeeName> get feeNames => _feeNames;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Helper method to get current year from settings
  String _getCurrentYear() {
    try {
      final userBox = Hive.box('userData');
      final settings = userBox.get('settings');
      if (settings != null && settings is Map && settings.containsKey('year')) {
        return settings['year'].toString();
      }
      // Default fallback to current year
      return DateTime.now().year.toString();
    } catch (e) {
      print('Error getting current year: $e');
      return DateTime.now().year.toString();
    }
  }

  // Helper method to get current term from settings
  String _getCurrentTerm() {
    try {
      final userBox = Hive.box('userData');
      final settings = userBox.get('settings');
      if (settings != null && settings is Map && settings.containsKey('term')) {
        return settings['term'].toString();
      }
      // Default fallback
      return '3';
    } catch (e) {
      print('Error getting current term: $e');
      return '3';
    }
  }

  Future<void> fetchFeeNames() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _feeService.getFeeNames();
      if (response.success && response.data != null) {
        _feeNames = response.data!;
        _error = null;
      } else {
        _error = response.message;
        print('Fee names fetch error: ${response.message}');
      }
    } catch (e) {
      _error = 'Failed to fetch fee names: $e';
      print('Fee names fetch exception: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addFeeName(String feeName, bool isMandatory) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final request = AddFeeNameRequest(
        feeName: feeName,
        isMandatory: isMandatory,
      );

print("kkkk ${feeName}, $isMandatory");
      final response = await _feeService.addFeeName(request);
      if (response.success) {
        // Refresh the fee names list to get the updated data from server
        await fetchFeeNames();
        _error = null;
        return true;
      } else {
        _error = response.message;
        print('Add fee name error: ${response.message}');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Failed to add fee name: $e';
      print('Add fee name exception: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateFeeName(String feeNameId, String feeName, bool isMandatory) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final request = UpdateFeeNameRequest(
        feeName: feeName,
        isMandatory: isMandatory,
      );

      print("kkkk ${feeName}, $isMandatory");

      final response = await _feeService.updateFeeName(feeNameId, request);
      if (response.success) {
        // Update the fee in the local list immediately for better UX
        final feeIndex = _feeNames.indexWhere((fee) => fee.id.toString() == feeNameId);
        if (feeIndex != -1) {
          // Create a new FeeName object with updated values (assuming FeeName has a copyWith method or constructor)
          // You may need to adjust this based on your FeeName model structure
          _feeNames[feeIndex] = FeeName(
            id: _feeNames[feeIndex].id,
            feeName: feeName,
            isMandatory: isMandatory,
            // Add other required fields from your FeeName model
          );
        }
        
        // Also refresh from server to ensure consistency
        await fetchFeeNames();
        _error = null;
        return true;
      } else {
        _error = response.message;
        print('Update fee name error: ${response.message}');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Failed to update fee name: $e';
      print('Update fee name exception: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteFeeName(String feeNameId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Get current year and term for the delete request
      final year = _getCurrentYear();
      final term = _getCurrentTerm();

      final response = await _feeService.deleteFeeName(
        feeNameId, 
        year: year, 
        term: term
      );
      
      if (response.success) {
        // Remove the deleted item from local list immediately for better UX
        _feeNames.removeWhere((fee) => fee.id.toString() == feeNameId);
        
        // Notify listeners immediately for instant UI update
        notifyListeners();
        
        // Also refresh from server to ensure consistency
        await fetchFeeNames();
        _error = null;
        return true;
      } else {
        _error = response.message;
        print('Delete fee name error: ${response.message}');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Failed to delete fee name: $e';
      print('Delete fee name exception: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}




