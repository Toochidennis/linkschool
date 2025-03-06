import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  Future<Map<String, dynamic>> login(String username, String password, String schoolCode) async {
    final url = Uri.parse('http://linkskool.com/developmentportal/api/login.php?username=$username&password=$password&token=$schoolCode');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print('API Response: $responseData');
      // Extract user data from the response
      if (responseData['status'] == 'success') {
        // Assuming the user data is in the 'profile' key
        final userData = responseData['profile'];
        return {
          'id': userData['id'],
          'name': userData['name'],
          'access_level': userData['access_level'],
          'status': 'success',
        };
      } else {
        throw Exception('Invalid credentials');
      }
    } else {
      throw Exception('Failed to login');
    }
  }
}


// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class AuthService {
//   Future<Map<String, dynamic>> login(String username, String password, String schoolCode) async {
//     final url = Uri.parse('http://linkskool.com/developmentportal/api/login.php?username=$username&password=$password&token=$schoolCode');
//     final response = await http.get(url);

//     if (response.statusCode == 200) {
//       return json.decode(response.body);
//     } else {
//       throw Exception('Failed to login');
//     }
//   }
// }


// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// class AuthService {
//   static const String baseUrl = 'http://linkskool.com/developmentportal/api';

//   Future<Map<String, dynamic>> login(String username, String password, String pin) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/login.php?username=practice&password=portal&token=5416'),
//         // body: {
//         //   'username': username,
//         //   'password': password,
//         //   'token': pin,
//         // },
//       );

//       if(response.statusCode == 200) { print(response.body);}
      

//       if (response.statusCode == 200) {
//         final jsonResponse = json.decode(response.body);
        
//         if (jsonResponse['status'] == 'success') {
//           final prefs = await SharedPreferences.getInstance();
//           await prefs.setBool('loginStatus', true);
//           await prefs.setString('username', username);
//           await prefs.setString('userpassword', password);
//           await prefs.setString('schoolcode', pin);
          
//           return jsonResponse;
//         } else {
//           throw Exception(jsonResponse['message'] ?? 'Login failed');
//         }
//       } else {
//         throw Exception('Server error');
//       }
//     } catch (e) {
//       throw Exception('Network error: $e');
//     }
//   }

//   Future<void> logout() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.clear();
//   }
// }