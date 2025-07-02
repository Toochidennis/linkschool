// import 'package:linkschool/modules/model/admin/course_registration_history.dart';
// import 'package:linkschool/modules/services/api/api_service.dart';


// class RegistrationHistoryService {
//   final ApiService _apiService;

//   RegistrationHistoryService(this._apiService);

//   Future<ApiResponse<RegistrationHistoryResponse>> getRegisteredCoursesHistory(String classId) async {
//     return await _apiService.get<RegistrationHistoryResponse>(
//       endpoint: 'portal/classes/$classId/course-registrations/history',
//       queryParams: {'_db': 'aalmgzmy_linkskoo_practice'},
//       fromJson: (json) {
//         print('Raw API Response: $json');
//         // Handle the actual API response structure
//         if (json.containsKey('data')) {
//           return RegistrationHistoryResponse.fromJson(json['data']);
//         } else {
//           // If data is at root level
//           return RegistrationHistoryResponse.fromJson(json);
//         }
//       },
//     );
//   }
// }


// // class RegistrationHistoryService {
// //   final ApiService _apiService;

// //   RegistrationHistoryService(this._apiService);

// //   Future<ApiResponse<RegistrationHistoryResponse>> getRegisteredCoursesHistory(String classId) async {
// //     return await _apiService.get<RegistrationHistoryResponse>(
// //       endpoint: 'portal/classes/$classId/course-registrations/history',
// //       queryParams: {'_db': 'aalmgzmy_linkskoo_practice'},
// //       fromJson: (json) => RegistrationHistoryResponse.fromJson(json['data']),
// //     );
// //   }
// // }