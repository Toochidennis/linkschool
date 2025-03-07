import 'package:http/http.dart' as http;
import 'dart:convert';

class TermService {
  // Fetch terms for a specific class ID
  Future<List<dynamic>> fetchTerms(String classId) async {
    final url = Uri.parse(
        'https://linkskool.com/developmentportal/api/jsonTerms.php?_db=linkskoo_practice&class=$classId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData['terms']; // API returns a list of terms
    } else {
      throw Exception('Failed to load terms');
    }
  }
}