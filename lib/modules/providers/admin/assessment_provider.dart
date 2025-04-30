import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/model/admin/assessment_model.dart';
import 'package:linkschool/modules/services/admin/assessment_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';

class AssessmentProvider with ChangeNotifier {
  final AssessmentService _assessmentService = locator<AssessmentService>();
  final List<Assessment> _assessments = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Assessment> get assessments => _assessments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void addAssessment(Assessment assessment) {
    _assessments.add(assessment);
    _setError(null);
    notifyListeners();
  }

  void removeAssessment(Assessment assessment) {
    _assessments.remove(assessment);
    notifyListeners();
  }
  
Future<void> saveAssessments(BuildContext context) async {  // Added context parameter
  if (_assessments.isEmpty) {
    _setError('No assessments to save');
    _showToast(context, 'No assessments to save', isSuccess: false);
    return;
  }

  _setLoading(true);
  _setError(null);

  try {
    final userBox = Hive.box('userData');
    final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';

    for (final assessment in _assessments) {
      final payload = {
        'assessment_name': assessment.assessmentName,
        'max_score': assessment.assessmentScore,
        'level_id': assessment.levelId,
        'assessment_type': assessment.assessmentType,
        '_db': dbName,
      };

      final response = await _assessmentService.createAssessment(payload);
      
      if (!response.success) {
        throw Exception(response.message ?? 'Failed to save assessment');
      }
    }

    // Refresh assessments after saving
    await fetchAssessments();
    _showToast(context, 'Assessments saved successfully');
  } catch (e) {
    _setError('Failed to save assessments: ${e.toString()}');
    _showToast(context, 'Failed to save assessments: ${e.toString()}', isSuccess: false);
  } finally {
    _setLoading(false);
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

// Add this helper method to AssessmentProvider
void _showToast(BuildContext context, String message, {bool isSuccess = true}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isSuccess ? Colors.green : Colors.red,
    ),
  );
}

Future<void> fetchAssessments() async {
  _setLoading(true);
  _setError(null);

  try {
    final userBox = Hive.box('userData');
    final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';
    
    final response = await _assessmentService.getAssessments(dbName);

    if (response.success && response.rawData?['response'] != null) {
      _assessments.clear();
      final assessmentsData = response.rawData!['response'] as Map<String, dynamic>;

      assessmentsData.forEach((levelName, levelData) {
        final levelAssessments = (levelData['assessments'] as List?) ?? [];
        for (var assessment in levelAssessments) {
          _assessments.add(Assessment(
            id: assessment['id']?.toString(),
            assessmentName: assessment['assessment_name'],
            assessmentScore: assessment['max_score'] ?? 0,
            assessmentType: assessment['type'] ?? 0,
            levelId: levelData['level_id'],
          ));
        }
      });
    } else {
      throw Exception(response.message ?? 'Failed to fetch assessments');
    }
  } catch (e) {
    _setError('Failed to fetch assessments: ${e.toString()}');
    debugPrint('Error fetching assessments: ${e.toString()}');
  } finally {
    _setLoading(false);
  }
}

  void clearError() {
    _setError(null);
  }
}

