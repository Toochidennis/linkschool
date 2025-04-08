// Import for JSON conversion
import 'package:linkschool/modules/model/admin/getcurrent_registration_model.dart';
import 'package:linkschool/modules/services/api/api_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';

class GetcurrentcourseRegisterationService {
  final ApiService _apiService = locator<ApiService>(); 

  // Fetch current course registration data
  Future<ApiResponse<List<CurrentCourseRegistrationModel>>> getCurrentCourseRegistration(
      String studentId, String classID, String term, String year) async {
    // if (studentId.isEmpty || classID.isEmpty || term.isEmpty || year.isEmpty) {
    //   throw Exception('All parameters must be provided and non-empty');
    // }

    

    final response = await _apiService.get(
      endpoint:'portal/courseRegisteration',
      queryParams:{
        '_db':'aamlmgzmy_linksckoo_practice',
        'student_id':studentId,
        'class_id':classID,
        'term':term,
        'year':year,
      }
    );

    if (response.success && response.rawData != null) {
      final List<dynamic> currentcoursesJson = response.rawData!['data'] ?? response.rawData!;
      final currentcourses = currentcoursesJson.map((json)=>CurrentCourseRegistrationModel.fromJson(json)).toList();
      
      return ApiResponse<List<CurrentCourseRegistrationModel>>(
        success:true,
        message:response.message,
        statusCode:response.statusCode,
        data:currentcourses,
        rawData:response.rawData,
      );
  }

   return ApiResponse<List<CurrentCourseRegistrationModel>>(
        success:false,
        message:response.message,
        statusCode:response.statusCode,
        data:[],
        rawData:response.rawData,
      );
  }

// Post current course registration data
  Future<ApiResponse<bool>> postCurrentCourseRegistration(
      CurrentCourseRegistrationModel currentcourseregistration) async {
  
    final response = await _apiService.post(
      endpoint: 'courseRegistration.php',
      body: currentcourseregistration.toJson());
   

    return ApiResponse(
      success: response.success,
      message: response.message, 
      statusCode: response.statusCode,
      rawData: response.rawData);
  }
}
