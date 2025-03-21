import 'package:get_it/get_it.dart';
import 'package:linkschool/modules/auth/service/auth_service.dart';
import 'package:linkschool/modules/services/api/api_service.dart';
import 'package:linkschool/modules/services/admin/class_service.dart';
import 'package:linkschool/modules/services/admin/grade_service.dart';
import 'package:linkschool/modules/services/admin/level_service.dart';
import 'package:linkschool/modules/services/admin/student_service.dart';
import 'package:linkschool/modules/services/admin/term_service.dart';
import 'package:linkschool/modules/services/admin/course_registration_service.dart'; // Add this
import 'package:linkschool/modules/services/admin/assessment_service.dart'; // Add this

final GetIt locator = GetIt.instance;

void setupServiceLocator() {
  // Register API Service as a singleton
  locator.registerLazySingleton<ApiService>(() => ApiService());

  // Register other services as lazySingletons
  locator.registerLazySingleton<ClassService>(() => ClassService());
  locator.registerLazySingleton<GradeService>(() => GradeService());
  locator.registerLazySingleton<LevelService>(() => LevelService());
  locator.registerLazySingleton<StudentService>(() => StudentService());
  locator.registerLazySingleton<TermService>(() => TermService());

  // Register the missing services
  locator.registerLazySingleton<AuthService>(() => AuthService());
  locator.registerLazySingleton<CourseRegistrationService>(() => CourseRegistrationService());
  locator.registerLazySingleton<AssessmentService>(() => AssessmentService());
}


// import 'package:get_it/get_it.dart';

// import 'api_service.dart';


// final GetIt locator = GetIt.instance;

// void setupServiceLocator() {
//   // Register API Service as a singleton
//   locator.registerLazySingleton<ApiService>(() => ApiService());
// }