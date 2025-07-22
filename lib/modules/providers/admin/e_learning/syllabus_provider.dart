import 'package:flutter/material.dart';
import 'package:linkschool/modules/services/admin/e_learning/syllabus_service.dart';
import 'package:linkschool/modules/model/admin/e_learning/syllabus_model.dart';

class SyllabusProvider extends ChangeNotifier {
  final SyllabusService _syllabusService;

  SyllabusProvider(this._syllabusService);

  SyllabusService get syllabusService => _syllabusService; // <-- Add this line

  String title = '';
  String description = '';
  String selectedClass = 'Select classes';
  String selectedTeacher = 'Select teachers';
  String backgroundImagePath = 'assets/images/result/bg_box3.svg';

  Future<Map<String, dynamic>> saveSyllabus() async {
    try {
      // Create a syllabus model from the current state
      final syllabus = Syllabus(
        title: title,
        description: description,
        image: backgroundImagePath,
        imageName: backgroundImagePath.split('/').last,
        courseId: 'course_1', // You'll need to get this from somewhere
        levelId: 'level_1', // You'll need to get this from somewhere
        classes: [
          Class(id: 'class_1', className: selectedClass),
        ],
        creatorRole: 'teacher', // Or get this from user data
        term: 'First Term', // You'll need to get this
        year: '2023', // You'll need to get this
      );
      print('Syllabus to be saved: ${syllabus.toJson()}');

      // Call the service to save
      final response = await syllabusService.saveSyllabus(syllabus);
      
      print('Server response: $response');
      
      return response;
    } catch (e) {
      print('Error saving syllabus: $e');
        print('Syllabus to be saved: $e');
      rethrow;
    }
  }

  void setTitle(String value) {
    title = value;
    notifyListeners();
  }

  void setDescription(String value) {
    description = value;
    notifyListeners();
  }

  void setSelectedClass(String value) {
    selectedClass = value;
    notifyListeners();
  }

  void setSelectedTeacher(String value) {
    selectedTeacher = value;
    notifyListeners();
  }

  void setBackgroundImagePath(String path) {
    backgroundImagePath = path;
    notifyListeners();
  }
}