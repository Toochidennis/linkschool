import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/admin/fee_name.dart';
// import 'package:linkschool/modules/admin/payment/models/fee_name.dart';
import 'package:linkschool/modules/services/admin/payment/fee_service.dart';

class FeeProvider with ChangeNotifier {
  final FeeService _feeService;

  FeeProvider(this._feeService);

  List<FeeName> _feeNames = [];
  bool _isLoading = false;
  String? _error;

  List<FeeName> get feeNames => _feeNames;
  bool get isLoading => _isLoading;
  String? get error => _error;

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
      }
    } catch (e) {
      _error = 'Failed to fetch fee names: $e';
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

      final response = await _feeService.addFeeName(request);
      if (response.success) {
        // Add the new fee name to the beginning of the list
        final newFeeName = FeeName(
          id: DateTime.now().millisecondsSinceEpoch, // Temporary ID
          feeName: feeName,
          isMandatory: isMandatory,
        );
        _feeNames.insert(0, newFeeName);
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Failed to add fee name: $e';
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
