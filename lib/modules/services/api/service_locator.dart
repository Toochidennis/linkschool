import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:linkschool/modules/auth/provider/auth_provider.dart';
import 'package:linkschool/modules/auth/service/auth_service.dart';
import 'package:linkschool/modules/providers/admin/attendance_provider.dart';
import 'package:linkschool/modules/providers/admin/behaviour_provider.dart';
import 'package:linkschool/modules/providers/admin/e_learning/assignment_provider.dart';
import 'package:linkschool/modules/providers/admin/e_learning/material_provider.dart';
import 'package:linkschool/modules/providers/admin/e_learning/quiz_provider.dart';
import 'package:linkschool/modules/providers/admin/e_learning/syllabus_provider.dart';
import 'package:linkschool/modules/providers/admin/e_learning/topic_provider.dart';

import 'package:linkschool/modules/providers/admin/grade_provider.dart';
import 'package:linkschool/modules/providers/admin/skills_behavior_table_provider.dart';
import 'package:linkschool/modules/services/admin/attendance_service.dart';
import 'package:linkschool/modules/services/admin/e_learning/assignment_service.dart';
import 'package:linkschool/modules/services/admin/e_learning/material_service.dart';
import 'package:linkschool/modules/services/admin/e_learning/quiz_service.dart';
import 'package:linkschool/modules/services/admin/e_learning/syllabus_service.dart';
import 'package:linkschool/modules/services/admin/e_learning/topic_service.dart';
import 'package:linkschool/modules/services/api/api_service.dart';
import 'package:linkschool/modules/services/admin/class_service.dart';
import 'package:linkschool/modules/services/admin/grade_service.dart';
import 'package:linkschool/modules/services/admin/level_service.dart';
import 'package:linkschool/modules/services/admin/student_service.dart';
import 'package:linkschool/modules/services/admin/term_service.dart';
import 'package:linkschool/modules/services/admin/course_registration_service.dart';
import 'package:linkschool/modules/services/admin/assessment_service.dart';
import 'package:linkschool/modules/providers/admin/student_provider.dart';
import 'package:linkschool/modules/services/admin/behaviour_service.dart';


final GetIt locator = GetIt.instance;

void setupServiceLocator() {
  // // Initialize API Service with proper configuration
  locator.registerLazySingleton<ApiService>(() => ApiService(
    baseUrl: dotenv.env['API_BASE_URL'],
    apiKey: dotenv.env['API_KEY'],
  ));

// Register QuizService with ApiService dependency
  locator.registerLazySingleton<QuizService>(
    () => QuizService(locator<ApiService>())
  );

  locator.registerLazySingleton<QuizProvider>(
    () => QuizProvider(locator<QuizService>())
  );
  
// Register AssignmentService with ApiService dependency
  locator.registerLazySingleton<AssignmentService>(
    () => AssignmentService(locator<ApiService>())
  );

  locator.registerLazySingleton<AssignmentProvider>(
    () => AssignmentProvider(locator<AssignmentService>())
  );

  // Register MaterialService with ApiService dependency
  locator.registerLazySingleton<MaterialService>(
    () => MaterialService(locator<ApiService>())
  );


  locator.registerLazySingleton<MaterialProvider>(
    () => MaterialProvider(locator<MaterialService>())
  );


  // Register SkillService with ApiService dependency
  locator.registerLazySingleton<SkillService>(
    () => SkillService(locator<ApiService>())
  );
 
  locator.registerLazySingleton<SkillsProvider>(
    () => SkillsProvider(locator<SkillService>())
  );

  locator.registerFactory(() => SkillsBehaviorTableProvider(locator<ApiService>()));

 // Register TopicProvider with SkillService dependen
  locator.registerLazySingleton<TopicService>(
    () => TopicService(locator<ApiService>())
  );


  
  locator.registerLazySingleton<TopicProvider>(
    () => TopicProvider(locator<TopicService>())
  );

  // Register StudentService with ApiService dependency
  locator.registerLazySingleton<StudentService>(
    () => StudentService(locator<ApiService>())
  );


  locator.registerLazySingleton<StudentProvider>(
    () => StudentProvider(locator<StudentService>())
  );

  // Register GradeService with ApiService dependency
  locator.registerLazySingleton<GradeService>(
    () => GradeService(locator<ApiService>())
  );

  // Register GradeProvider with GradeService dependency
  locator.registerLazySingleton<GradeProvider>(
    () => GradeProvider(locator<GradeService>())
  );

  locator.registerLazySingleton<SyllabusService>(
    () => SyllabusService(locator<ApiService>())
  );
  locator.registerLazySingleton<SyllabusProvider>(
    () => SyllabusProvider(locator<SyllabusService>())
  );




  locator.registerLazySingleton<ClassService>(() => ClassService());
  locator.registerLazySingleton<LevelService>(() => LevelService());
  // locator.registerLazySingleton<TermService>(() => TermService());
    // Register TermService with ApiService dependency
  locator.registerLazySingleton<TermService>(() {
    final service = TermService();
    service.apiService = locator<ApiService>();
    return service;
  });


 // Register AuthService
  locator.registerLazySingleton<AuthService>(() => AuthService());

  // Register AuthProvider with AuthService dependency
  locator.registerLazySingleton<AuthProvider>(
    () => AuthProvider()
  );

    // Register the missing services
  locator.registerLazySingleton<CourseRegistrationService>(() => CourseRegistrationService());
  locator.registerLazySingleton<AssessmentService>(() => AssessmentService());


  // Register AttendanceService
  locator.registerLazySingleton<AttendanceService>(
    () => AttendanceService(locator<ApiService>())
  );

  // Register AttendanceProvider
  locator.registerLazySingleton<AttendanceProvider>(
    () => AttendanceProvider()
  );
}
