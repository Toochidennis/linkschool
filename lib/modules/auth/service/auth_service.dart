import 'package:linkschool/modules/auth/model/user.dart';
import 'package:linkschool/modules/services/api/api_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';


class AuthService {
  final ApiService _apiService = locator<ApiService>();

  Future<ApiResponse<Map<String, dynamic>>> login(String username, String password, String schoolCode) async {
    return await _apiService.get(
      endpoint: 'login.php',
      queryParams: {
        'username': username,
        'password': password,
        'token': schoolCode,
      },
    );
  }
  
  // Additional auth methods can be added here
  Future<ApiResponse<User>> getUserProfile(String userId) async {
    return await _apiService.get(
      endpoint: 'user_profile.php',
      queryParams: {
        'user_id': userId,
      },
      fromJson: (json) => User.fromJson(json),
    );
  }
}



// import 'package:http/http.dart' as http;
// import 'dart:convert';



// class AuthService {
//   Future<Map<String, dynamic>> login(String username, String password, String schoolCode) async {
//     final url = Uri.parse('http://linkskool.com/developmentportal/api/login.php?username=$username&password=$password&token=$schoolCode');
//     final response = await http.get(url);

//     if (response.statusCode == 200) {
//       final responseData = json.decode(response.body);
//       print('API Response: $responseData');

//       if (responseData['status'] == 'success') {
//         // Return the entire API response
//         return responseData;
//       } else {
//         throw Exception('Invalid credentials');
//       }
//     } else {
//       throw Exception('Failed to login');
//     }
//   }
// }