import 'package:flutter/foundation.dart';
import 'package:linkschool/modules/model/explore/home/admission_model.dart';
import 'package:linkschool/modules/services/explore/home/admission_service.dart';

class AdmissionProvider extends ChangeNotifier {
  final AdmissionService _service = AdmissionService();

  bool _isLoading = false;
  String? _errorMessage;
  AdmissionResponse? _admissionData;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AdmissionResponse? get admissionData => _admissionData;

  Future<void> loadAdmissions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _service.fetchAdmissions();
      if (data != null) {
        _admissionData = data;
      } else {
        _errorMessage = "Failed to load admissions.";
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
