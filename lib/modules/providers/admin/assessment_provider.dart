import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/model/admin/assessment_model.dart';
import 'package:linkschool/modules/services/admin/assessment_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';

class AssessmentProvider with ChangeNotifier {
  final AssessmentService _assessmentService = locator<AssessmentService>();
  final List<Assessment> _assessments = [];
  final List<Assessment> _newlyAddedAssessments = []; // Track newly added assessments
  bool _isLoading = false;
  String? _errorMessage;

  List<Assessment> get assessments => _assessments;
  List<Assessment> get newlyAddedAssessments => _newlyAddedAssessments;
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
    _newlyAddedAssessments.add(assessment); // Track this as a newly added assessment
    _setError(null);
    notifyListeners();
  }

  void removeAssessment(Assessment assessment) {
    _assessments.remove(assessment);
    _newlyAddedAssessments.remove(assessment); // Also remove from newly added if present
    notifyListeners();
  }

  // Edit assessment method with dual logic
  Future<bool> editAssessment(Assessment assessment, String newName, int newScore, int newType) async {
    // Check if this is a newly added assessment
    final isNewlyAdded = _newlyAddedAssessments.contains(assessment);
    
    if (isNewlyAdded) {
      // Update locally for newly added assessment
      final index = _assessments.indexOf(assessment);
      if (index != -1) {
        _assessments[index] = Assessment(
          id: assessment.id,
          assessmentName: newName,
          assessmentScore: newScore,
          assessmentType: newType,
          levelId: assessment.levelId,
        );
        
        // Update in newly added list as well
        final newlyAddedIndex = _newlyAddedAssessments.indexOf(assessment);
        if (newlyAddedIndex != -1) {
          _newlyAddedAssessments[newlyAddedIndex] = _assessments[index];
        }
        
        notifyListeners();
        return true;
      }
      return false;
    } else {
      // Use API for existing assessment
      return await _editAssessmentViaAPI(assessment, newName, newScore, newType);
    }
  }

  // Delete assessment method with dual logic
  Future<bool> deleteAssessment(Assessment assessment) async {
    // Check if this is a newly added assessment
    final isNewlyAdded = _newlyAddedAssessments.contains(assessment);
    
    if (isNewlyAdded) {
      // Delete locally for newly added assessment
      removeAssessment(assessment);
      return true;
    } else {
      // Use API for existing assessment
      return await _deleteAssessmentViaAPI(assessment);
    }
  }

  // Private method to edit assessment via API
  Future<bool> _editAssessmentViaAPI(Assessment assessment, String newName, int newScore, int newType) async {
    if (assessment.id == null) {
      _setError('Cannot edit assessment without ID');
      return false;
    }

    _setLoading(true);
    _setError(null);

    try {
      final userBox = Hive.box('userData');
      final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';
      
      final payload = {
        'level_id': assessment.levelId,
        'assessment_name': newName,
        'max_score': newScore,
        'type': newType,
        '_db': dbName,
      };

      final response = await _assessmentService.editAssessment(assessment.id!, payload);
      
      if (response.success) {
        // Update local assessment after successful API call
        final index = _assessments.indexOf(assessment);
        if (index != -1) {
          _assessments[index] = Assessment(
            id: assessment.id,
            assessmentName: newName,
            assessmentScore: newScore,
            assessmentType: newType,
            levelId: assessment.levelId,
          );
          notifyListeners();
        }
        return true;
      } else {
        throw Exception(response.message ?? 'Failed to update assessment');
      }
    } catch (e) {
      _setError('Failed to update assessment: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Private method to delete assessment via API
  Future<bool> _deleteAssessmentViaAPI(Assessment assessment) async {
    if (assessment.id == null) {
      _setError('Cannot delete assessment without ID');
      return false;
    }

    _setLoading(true);
    _setError(null);

    try {
      final response = await _assessmentService.deleteAssessment(assessment.id!);
      
      if (response.success) {
        // Remove from local list after successful API call
        removeAssessment(assessment);
        return true;
      } else {
        throw Exception(response.message ?? 'Failed to delete assessment');
      }
    } catch (e) {
      _setError('Failed to delete assessment: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> saveAssessments(BuildContext context, String selectedLevelId) async {
    // Only save newly added assessments for the selected level
    final newAssessmentsForLevel = _newlyAddedAssessments
        .where((assessment) => assessment.levelId.toString() == selectedLevelId)
        .toList();
    
    if (newAssessmentsForLevel.isEmpty) {
      _setError('No new assessments to save');
      return;
    }

    _setLoading(true);
    _setError(null);

    try {
      final userBox = Hive.box('userData');
      final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';
      
      // Get level name for the selected level
      String levelName = "General";
      
      // If we're not using "General", get the actual level name
      if (selectedLevelId != "0") {
        final levels = userBox.get('levels');
        if (levels != null && levels is List) {
          final selectedLevel = levels.firstWhere(
            (level) => level['level_id'].toString() == selectedLevelId || level['id'].toString() == selectedLevelId,
            orElse: () => {'level_name': 'Unknown Level'},
          );
          levelName = selectedLevel['level_name'] ?? 'Unknown Level';
        }
      }
      
      // Prepare the payload according to API format - only including newly added assessments
      final Map<String, dynamic> payload = {
        'level_id': int.parse(selectedLevelId),
        'level_name': levelName,
        'general': 0, // Default to 0 for "General" option
        'assessments': newAssessmentsForLevel.map((assessment) => {
          'assessment_name': assessment.assessmentName,
          'max_score': assessment.assessmentScore,
          'level_id': assessment.levelId,
          'type': assessment.assessmentType,
        }).toList(),
        '_db': dbName,
      };

      // Send to API
      final response = await _assessmentService.createAssessment(payload);
      
      if (!response.success) {
        throw Exception(response.message ?? 'Failed to save assessment');
      }

      // After successful save, clear the newly added assessments for this level
      _newlyAddedAssessments.removeWhere((assessment) => assessment.levelId.toString() == selectedLevelId);
      
      // Refresh assessments after saving
      await fetchAssessments();
    } catch (e) {
      _setError('Failed to save assessments: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchAssessments() async {
    _setLoading(true);
    _setError(null);

    try {
      final userBox = Hive.box('userData');
      final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';
      
      final response = await _assessmentService.getAssessments(dbName);

      if (response.success && response.rawData != null) {
        _assessments.clear();
        
        // Parse the response according to the API format
        if (response.rawData!.containsKey('assessments')) {
          final assessmentsList = response.rawData!['assessments'] as List;
          
          for (var levelData in assessmentsList) {
            final levelId = levelData['level_id'] ?? 0;
            final levelAssessments = levelData['assessments'] as List? ?? [];
            
            for (var assessment in levelAssessments) {
              _assessments.add(Assessment(
                id: assessment['id']?.toString(),
                assessmentName: assessment['assessment_name'] ?? '',
                assessmentScore: assessment['assessment_score'] ?? 0,
                assessmentType: assessment['type'] ?? 0,
                levelId: levelId,
              ));
            }
          }
        }
        
        // Clear newly added assessments after fetch since they're now saved
        _newlyAddedAssessments.clear();
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





// import 'package:flutter/material.dart';
// import 'package:hive/hive.dart';
// import 'package:linkschool/modules/model/admin/assessment_model.dart';
// import 'package:linkschool/modules/services/admin/assessment_service.dart';
// import 'package:linkschool/modules/services/api/service_locator.dart';

// class AssessmentProvider with ChangeNotifier {
//   final AssessmentService _assessmentService = locator<AssessmentService>();
//   final List<Assessment> _assessments = [];
//   final List<Assessment> _newlyAddedAssessments = []; // Track newly added assessments
//   bool _isLoading = false;
//   String? _errorMessage;

//   List<Assessment> get assessments => _assessments;
//   List<Assessment> get newlyAddedAssessments => _newlyAddedAssessments;
//   bool get isLoading => _isLoading;
//   String? get errorMessage => _errorMessage;

//   void _setLoading(bool loading) {
//     _isLoading = loading;
//     notifyListeners();
//   }

//   void _setError(String? message) {
//     _errorMessage = message;
//     notifyListeners();
//   }

//   void addAssessment(Assessment assessment) {
//     _assessments.add(assessment);
//     _newlyAddedAssessments.add(assessment); // Track this as a newly added assessment
//     _setError(null);
//     notifyListeners();
//   }

//   void removeAssessment(Assessment assessment) {
//     _assessments.remove(assessment);
//     _newlyAddedAssessments.remove(assessment); // Also remove from newly added if present
//     notifyListeners();
//   }
  
//   Future<void> saveAssessments(BuildContext context, String selectedLevelId) async {
//     // Only save newly added assessments for the selected level
//     final newAssessmentsForLevel = _newlyAddedAssessments
//         .where((assessment) => assessment.levelId.toString() == selectedLevelId)
//         .toList();
    
//     if (newAssessmentsForLevel.isEmpty) {
//       _setError('No new assessments to save');
//       return;
//     }

//     _setLoading(true);
//     _setError(null);

//     try {
//       final userBox = Hive.box('userData');
//       final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';
      
//       // Get level name for the selected level
//       String levelName = "General";
      
//       // If we're not using "General", get the actual level name
//       if (selectedLevelId != "0") {
//         final levels = userBox.get('levels');
//         if (levels != null && levels is List) {
//           final selectedLevel = levels.firstWhere(
//             (level) => level['level_id'].toString() == selectedLevelId || level['id'].toString() == selectedLevelId,
//             orElse: () => {'level_name': 'Unknown Level'},
//           );
//           levelName = selectedLevel['level_name'] ?? 'Unknown Level';
//         }
//       }
      
//       // Prepare the payload according to API format - only including newly added assessments
//       final Map<String, dynamic> payload = {
//         'level_id': int.parse(selectedLevelId),
//         'level_name': levelName,
//         'general': 0, // Default to 0 for "General" option
//         'assessments': newAssessmentsForLevel.map((assessment) => {
//           'assessment_name': assessment.assessmentName,
//           'max_score': assessment.assessmentScore,
//           'level_id': assessment.levelId,
//           'type': assessment.assessmentType,
//         }).toList(),
//         '_db': dbName,
//       };

//       // Send to API
//       final response = await _assessmentService.createAssessment(payload);
      
//       if (!response.success) {
//         throw Exception(response.message ?? 'Failed to save assessment');
//       }

//       // After successful save, clear the newly added assessments for this level
//       _newlyAddedAssessments.removeWhere((assessment) => assessment.levelId.toString() == selectedLevelId);
      
//       // Refresh assessments after saving
//       await fetchAssessments();
//     } catch (e) {
//       _setError('Failed to save assessments: ${e.toString()}');
//     } finally {
//       _setLoading(false);
//     }
//   }

//   Future<void> fetchAssessments() async {
//     _setLoading(true);
//     _setError(null);

//     try {
//       final userBox = Hive.box('userData');
//       final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';
      
//       final response = await _assessmentService.getAssessments(dbName);

//       if (response.success && response.rawData != null) {
//         _assessments.clear();
        
//         // Parse the response according to the API format
//         if (response.rawData!.containsKey('assessments')) {
//           final assessmentsList = response.rawData!['assessments'] as List;
          
//           for (var levelData in assessmentsList) {
//             final levelId = levelData['level_id'] ?? 0;
//             final levelAssessments = levelData['assessments'] as List? ?? [];
            
//             for (var assessment in levelAssessments) {
//               _assessments.add(Assessment(
//                 id: assessment['id']?.toString(),
//                 assessmentName: assessment['assessment_name'] ?? '',
//                 assessmentScore: assessment['assessment_score'] ?? 0,
//                 assessmentType: assessment['type'] ?? 0,
//                 levelId: levelId,
//               ));
//             }
//           }
//         }
        
//         // Clear newly added assessments after fetch since they're now saved
//         _newlyAddedAssessments.clear();
//       } else {
//         throw Exception(response.message ?? 'Failed to fetch assessments');
//       }
//     } catch (e) {
//       _setError('Failed to fetch assessments: ${e.toString()}');
//       debugPrint('Error fetching assessments: ${e.toString()}');
//     } finally {
//       _setLoading(false);
//     }
//   }

//   void clearError() {
//     _setError(null);
//   }
// }