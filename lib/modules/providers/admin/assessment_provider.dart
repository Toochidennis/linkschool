import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/admin/assessment_model.dart';
import 'package:linkschool/modules/services/admin/assessment_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';

class AssessmentProvider with ChangeNotifier {
  final AssessmentService _assessmentService = locator<AssessmentService>();
  final List<Assessment> _assessments = [];
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

      if (response.success) {
        // Do not clear the assessments list after successful save
        showToast('Assessments saved successfully');
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      showToast('Failed to save assessments: ${e.toString()}');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch assessments from the API
  Future<void> fetchAssessments(String classId, String termId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _assessmentService.getAssessments(classId, termId);

      if (response.success && response.rawData != null) {
        _assessments.clear();

        // Parse the response data
        final List<dynamic> assessmentsJson = response.rawData!['data'] ?? [];
        for (var json in assessmentsJson) {
          _assessments.add(Assessment.fromJson(json));
        }
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      showToast('Failed to fetch assessments: ${e.toString()}');
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

  // Show a toast message for UI feedback
  void showToast(String message) {
    // You can use a global toast utility or ScaffoldMessenger here
    debugPrint(message); // For debugging purposes
  }
}


// import 'package:flutter/material.dart';
// import 'package:linkschool/modules/model/admin/assessment_model.dart';
// import 'package:linkschool/modules/services/admin/assessment_service.dart';



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
//         // Do not clear the assessments list after successful save
//         showToast('Assessments saved successfully');
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

//   // Clear all assessments (optional, for resetting the form)
//   void clearAssessments() {
//     _assessments.clear();
//     notifyListeners();
//   }

//   // Show a toast message (optional, for UI feedback)
//   void showToast(String message) {
//     // You can use a global toast utility or ScaffoldMessenger here
//     debugPrint(message); // For debugging purposes
//   }
// }

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