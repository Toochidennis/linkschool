import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/admin/assessment_model.dart';
import 'package:linkschool/modules/services/admin/assessment_service.dart';



class AssessmentProvider with ChangeNotifier {
  final AssessmentService _assessmentService = AssessmentService();
  List<Assessment> _assessments = [];
  bool _isLoading = false;

  List<Assessment> get assessments => _assessments;
  bool get isLoading => _isLoading;

  // Add an assessment
  void addAssessment(Assessment assessment) {
    _assessments.add(assessment);
    notifyListeners();
  }

  // Remove an assessment
  void removeAssessment(Assessment assessment) {
    _assessments.remove(assessment);
    notifyListeners();
  }

  // Save assessments to the API
  Future<void> saveAssessments() async {
    _isLoading = true;
    notifyListeners();

    try {
      final List<Map<String, dynamic>> payload = _assessments.map((assessment) {
        return assessment.toJson();
      }).toList();

      final response = await _assessmentService.saveAssessments(payload);

      if (response['status'] == 'success') {
        // Do not clear the assessments list after successful save
        showToast('Assessments saved successfully');
      } else {
        throw Exception(response['message']);
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear all assessments (optional, for resetting the form)
  void clearAssessments() {
    _assessments.clear();
    notifyListeners();
  }

  // Show a toast message (optional, for UI feedback)
  void showToast(String message) {
    // You can use a global toast utility or ScaffoldMessenger here
    debugPrint(message); // For debugging purposes
  }
}

// class AssessmentProvider with ChangeNotifier {
//   final AssessmentService _assessmentService = AssessmentService();
//   List<Assessment> _assessments = [];
//   bool _isLoading = false;

//   List<Assessment> get assessments => _assessments;
//   bool get isLoading => _isLoading;

//   // Add an assessment
//   void addAssessment(Assessment assessment) {
//     _assessments.add(assessment);
//     notifyListeners();
//   }

//   // Remove an assessment
//   void removeAssessment(Assessment assessment) {
//     _assessments.remove(assessment);
//     notifyListeners();
//   }

//   // Save assessments to the API
//   Future<void> saveAssessments() async {
//     _isLoading = true;
//     notifyListeners();

//     try {
//       final List<Map<String, dynamic>> payload = _assessments.map((assessment) {
//         return assessment.toJson();
//       }).toList();

//       final response = await _assessmentService.saveAssessments(payload);

//       if (response['status'] == 'success') {
//         _assessments.clear(); // Clear the list after successful save
//         notifyListeners();
//       } else {
//         throw Exception(response['message']);
//       }
//     } catch (e) {
//       rethrow;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
// }