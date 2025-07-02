import 'package:linkschool/modules/model/admin/e_learning/syllabus_model.dart';

class SyllabusService {
  Future<Map<String, dynamic>> saveSyllabus(Syllabus syllabus) async {
    // Simulate network delay
    await Future.delayed(Duration(seconds: 1));
    
    // Print the syllabus data being "sent" to the API
    print('Saving syllabus with data:');
    print(syllabus.toJson());
    
    // Simulate a successful API response
    return {
      'status': 'success',
      'message': 'Syllabus saved successfully',
      'data': {
        ...syllabus.toJson(),
        'id': 'generated_id_123', // Simulate generated ID from server
        'created_at': DateTime.now().toIso8601String(),
      }
    };
  }
}