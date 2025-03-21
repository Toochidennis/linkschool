import 'package:linkschool/modules/services/api/api_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';

class TermService {
  final ApiService _apiService = locator<ApiService>();

  // Fetch terms for a specific class ID
  Future<List<Map<String, dynamic>>> fetchTerms(String classId) async {
    try {
      final response = await _apiService.get(
        endpoint: 'jsonTerms.php',
        queryParams: {
          '_db': 'linkskoo_practice',
          'class': classId,
        },
      );

      // Debugging: Print the raw API response
      final responseData = response.rawData;
      print('Raw API Response: $responseData');

      // Check if the response is a list
      if (responseData is List) {
        print('API Response is a List');

        // Check if the list is not empty
        if (responseData != null) {
          final termsData =
              responseData[0]; // Access the first item in the list
          print('First Item in List: $termsData');

          // Check if the first item is a map
          if (termsData is Map<String, dynamic>) {
            print('First Item is a Map');

            // Convert the nested terms data into a list of maps
            List<Map<String, dynamic>> terms = [];
            termsData.forEach((year, data) {
              print('Processing Year: $year, Data: $data');

              // Check if the data is a map and contains the 'terms' key
              if (data is Map<String, dynamic> && data.containsKey('terms')) {
                final termsValue = data['terms'];

                // Handle cases where 'terms' is a map or a list
                if (termsValue is Map<String, dynamic>) {
                  print('Year Terms (Map): $termsValue');

                  termsValue.forEach((termId, termName) {
                    terms.add({
                      'year': year,
                      'termId': termId,
                      'termName': termName,
                    });
                  });
                } else if (termsValue is List) {
                  print('Year Terms (List): $termsValue');
                  // Skip or handle lists (e.g., ignore null values)
                  if (termsValue.isNotEmpty && termsValue[0] != null) {
                    print('Skipping non-null list terms');
                  }
                } else {
                  print('Invalid terms format for year: $year');
                }
              } else {
                print('Invalid data format for year: $year');
              }
            });

            return terms;
          } else {
            print('First Item is not a Map');
            throw Exception('Invalid API response format: Expected a Map');
          }
        } else {
          print('API Response List is empty');
          throw Exception('Invalid API response format: Empty List');
        }
      } else {
        print('API Response is not a List');
        throw Exception('Invalid API response format: Expected a List');
      }
    } catch (e) {
      print('Failed to load terms: $e');
      throw Exception('Failed to load terms: $e');
    }
  }
}



// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class TermService {
//   // Fetch terms for a specific class ID
//   Future<List<Map<String, dynamic>>> fetchTerms(String classId) async {
//     final url = Uri.parse(
//         'https://linkskool.com/developmentportal/api/jsonTerms.php?_db=linkskoo_practice&class=$classId');
//     final response = await http.get(url);

//     if (response.statusCode == 200) {
//       final responseData = json.decode(response.body);

//       // Debugging: Print the raw API response
//       print('Raw API Response: $responseData');

//       // Check if the response is a list
//       if (responseData is List) {
//         print('API Response is a List');

//         // Check if the list is not empty
//         if (responseData.isNotEmpty) {
//           final termsData = responseData[0]; // Access the first item in the list
//           print('First Item in List: $termsData');

//           // Check if the first item is a map
//           if (termsData is Map<String, dynamic>) {
//             print('First Item is a Map');

//             // Convert the nested terms data into a list of maps
//             List<Map<String, dynamic>> terms = [];
//             termsData.forEach((year, data) {
//               print('Processing Year: $year, Data: $data');

//               // Check if the data is a map and contains the 'terms' key
//               if (data is Map<String, dynamic> && data.containsKey('terms')) {
//                 final termsValue = data['terms'];

//                 // Handle cases where 'terms' is a map or a list
//                 if (termsValue is Map<String, dynamic>) {
//                   print('Year Terms (Map): $termsValue');

//                   termsValue.forEach((termId, termName) {
//                     terms.add({
//                       'year': year,
//                       'termId': termId,
//                       'termName': termName,
//                     });
//                   });
//                 } else if (termsValue is List) {
//                   print('Year Terms (List): $termsValue');
//                   // Skip or handle lists (e.g., ignore null values)
//                   if (termsValue.isNotEmpty && termsValue[0] != null) {
//                     print('Skipping non-null list terms');
//                   }
//                 } else {
//                   print('Invalid terms format for year: $year');
//                 }
//               } else {
//                 print('Invalid data format for year: $year');
//               }
//             });

//             return terms;
//           } else {
//             print('First Item is not a Map');
//             throw Exception('Invalid API response format: Expected a Map');
//           }
//         } else {
//           print('API Response List is empty');
//           throw Exception('Invalid API response format: Empty List');
//         }
//       } else {
//         print('API Response is not a List');
//         throw Exception('Invalid API response format: Expected a List');
//       }
//     } else {
//       print('Failed to load terms. Status Code: ${response.statusCode}');
//       throw Exception('Failed to load terms');
//     }
//   }
// }