
import 'package:hive/hive.dart';
import 'package:linkschool/modules/services/api/api_service.dart';

class  AssignmentService {
 final  ApiService _apiService;
 AssignmentService(this._apiService);
Future<void> AddAssignment(Map assignment) async {
  final userBox = Hive.box('userData');
  final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
  final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';

  if (loginData == null || loginData['token'] == null) {
    throw Exception("No valid login data or token found");
  }

  final token = loginData['token'] as String;
  print("Set token: $token");
  _apiService.setAuthToken(token);

  assignment['_db'] = dbName;
  print("Request Payload: $assignment");

  try {
    final response = await _apiService.post<Map<String, dynamic>>(
      endpoint: 'portal/elearning/assignment',
      body: assignment,
    );

    print("Response Status Code: ${response.statusCode}");

    if (!response.success) {
      print("Failed to add Material");
      print("Error: ${response.message ?? 'No error message provided'}");
      throw Exception("Failed to Add Material: ${response.message}");
    } else {
      print(' Material added successfully.');
      print('Status Code: ${response.statusCode}');
      print(' ${response.message}');
      
    }
  } catch (e) {
    print("Error adding material: $e");
    throw Exception("Failed to Add Material: $e");
  }
}

}
