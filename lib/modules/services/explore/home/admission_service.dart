import 'package:http/http.dart' as http;

import 'package:linkschool/modules/model/explore/home/admission_model.dart';

class AdmissionService {
  static const String baseUrl =
      "https://linkskool.net/api/v3/public/admissions";

  Future<AdmissionResponse?> fetchAdmissions() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        return admissionResponseFromJson(response.body);
      } else {
        print("❌ Failed with status: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("⚠️ Exception fetching admissions: $e");
      return null;
    }
  }
}
