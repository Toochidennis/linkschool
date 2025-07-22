import 'package:hive/hive.dart';
import 'package:linkschool/modules/model/admin/behaviour_model.dart';
import 'package:linkschool/modules/services/api/api_service.dart';

class SkillService {
  final ApiService _apiService;
  final String _db;

  SkillService(this._apiService) : _db = 'aalmgzmy_linkskoo_practice';

  Future<List<Skills>> getSkills() async {
    final response = await _apiService.get<List<Skills>>(
      endpoint: 'portal/skill-behavior',
      queryParams: {'_db': _db},
      fromJson: (json) {
        if (json.containsKey('response')) {
          final List<dynamic> data = json['response'];
          final userBox = Hive.box('userData');
          final levels = List<Map<String, dynamic>>.from(userBox.get('levels') ?? []);
          
          return data.map((skillJson) {
            final levelId = skillJson['level']?.toString();
            final level = levels.firstWhere(
              (level) => level['id'].toString() == levelId,
              orElse: () => {'level_name': 'General (All level)'},
            );
            
            return Skills.fromJson({
              ...skillJson,
              'level_name': level['level_name'],
            });
          }).toList();
        }
        throw Exception('Invalid API response: Missing "response" key');
      },
    );

    if (response.success) {
      return response.data ?? [];
    } else {
      throw Exception('Failed to load skills: ${response.message}');
    }
  }

  Future<ApiResponse<void>> addSkill({
    required String skillName,
    required String type,
    required String levelId,
  }) async {
    final response = await _apiService.post<void>(
      endpoint: 'portal/skill-behavior',
      body: {
        'skill_name': skillName,
        'type': type,
        'level_id': levelId,
        '_db': _db,
      },
    );
    return response;
  }

  Future<ApiResponse<void>> updateSkill({
    required String id,
    required String skillName,
    required String type,
    required String levelId,
  }) async {
    final response = await _apiService.put<void>(
      endpoint: 'portal/skill-behavior/$id',
      body: {
        'skill_name': skillName,
        'type': type,
        'level_id': levelId,
        '_db': _db,
      },
    );
    return response;
  }

  Future<void> deleteSkill(String id) async {
    final response = await _apiService.delete<void>(
      endpoint: 'portal/skill-behavior/$id',
      queryParams: {'_db': _db},
    );

    if (!response.success) {
      throw Exception('Failed to delete skill: ${response.message}');
    }
  }
}




// import 'package:linkschool/modules/model/admin/behaviour_model.dart';
// import 'package:linkschool/modules/services/api/api_service.dart';

// class SkillService {
//   final ApiService _apiService;

//   SkillService(this._apiService);
  
//   Future<List<Skills>> getSkills() async {
//     final response = await _apiService.get<List<Skills>>(
//       endpoint: 'skills.php',
//       fromJson: (json) {
//         if (json.containsKey('skills')) {
//           final List<dynamic> data = json['skills'];
//           return data.map((skillJson) => Skills.fromJson(skillJson)).toList();
//         }
//         throw Exception('Invalid API response: Missing "skills" key');
//       },
//     );

//     if (response.success) {
//       return response.data ?? [];
//     } else {
//       throw Exception('Failed to load skills: ${response.message}');
//     }
//   }
  
//   Future<void> addSkill(Skills skill) async {
//     final response = await _apiService.post<Map<String, dynamic>>(
//       endpoint: 'skills.php',
//       body: skill.toJson(),
//     );

//     if (!response.success) {
//       throw Exception('Failed to add skill: ${response.message}');
//     }
//   }
  
//   Future<void> deleteSkill(String id) async {
//     final response = await _apiService.delete<Map<String, dynamic>>(
//       endpoint: 'skills.php',
//       body: {'id': id},
//     );

//     if (!response.success) {
//       throw Exception('Failed to delete skill: ${response.message}');
//     }
//   }
// }