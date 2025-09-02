import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:linkschool/modules/auth/provider/auth_provider.dart';
import 'package:linkschool/modules/auth/service/auth_service.dart';
import 'package:linkschool/modules/providers/admin/attendance_provider.dart';
import 'package:linkschool/modules/providers/admin/behaviour_provider.dart';
import 'package:linkschool/modules/providers/admin/e_learning/assignment_provider.dart';
import 'package:linkschool/modules/providers/admin/e_learning/comment_provider.dart';
import 'package:linkschool/modules/providers/admin/e_learning/delete_question.dart';
import 'package:linkschool/modules/providers/admin/e_learning/delete_sylabus_content.dart';
import 'package:linkschool/modules/providers/admin/e_learning/mark_assignment_provider.dart';
import 'package:linkschool/modules/providers/admin/e_learning/material_provider.dart';
import 'package:linkschool/modules/providers/admin/e_learning/quiz_provider.dart';
import 'package:linkschool/modules/providers/admin/e_learning/syllabus_content_provider.dart';
import 'package:linkschool/modules/providers/admin/e_learning/syllabus_provider.dart';
import 'package:linkschool/modules/providers/admin/e_learning/topic_provider.dart';
import 'package:linkschool/modules/providers/admin/grade_provider.dart';
import 'package:linkschool/modules/providers/admin/payment/account_provider.dart';
import 'package:linkschool/modules/providers/admin/payment/fee_provider.dart';
import 'package:linkschool/modules/providers/admin/performance_provider.dart';
import 'package:linkschool/modules/providers/admin/skills_behavior_table_provider.dart';
import 'package:linkschool/modules/services/admin/attendance_service.dart';
import 'package:linkschool/modules/services/admin/e_learning/activity_service.dart';
import 'package:linkschool/modules/services/admin/e_learning/assignment_service.dart';
import 'package:linkschool/modules/services/admin/e_learning/comment_service.dart';
import 'package:linkschool/modules/services/admin/e_learning/delete_question.dart';
import 'package:linkschool/modules/services/admin/e_learning/delete_syllabus_content.dart';
import 'package:linkschool/modules/services/admin/e_learning/marking_service.dart';
import 'package:linkschool/modules/services/admin/e_learning/material_service.dart';
import 'package:linkschool/modules/services/admin/e_learning/quiz_service.dart';
import 'package:linkschool/modules/services/admin/e_learning/syllabus_content_service.dart';
import 'package:linkschool/modules/services/admin/e_learning/syllabus_service.dart';
import 'package:linkschool/modules/services/admin/e_learning/topic_service.dart';
import 'package:linkschool/modules/services/admin/payment/account_service.dart';
import 'package:linkschool/modules/services/admin/payment/expenditure_service.dart';
import 'package:linkschool/modules/services/admin/payment/fee_service.dart';
import 'package:linkschool/modules/services/admin/payment/vendor_service.dart';
import 'package:linkschool/modules/services/admin/performance_service.dart';
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

import '../admin/payment/payment_service.dart';

final GetIt locator = GetIt.instance;

void setupServiceLocator() {
  // Initialize API Service with proper configuration
  locator.registerLazySingleton<ApiService>(() => ApiService(
        baseUrl: dotenv.env['API_BASE_URL'],
        apiKey: dotenv.env['API_KEY'],
      ));

  // Register VendorService with ApiService dependency
  locator.registerLazySingleton<VendorService>(
    () => VendorService(locator<ApiService>()),
  );

  // Register ExpenditureService with ApiService dependency
  locator.registerLazySingleton<ExpenditureService>(
    () => ExpenditureService(locator<ApiService>()),
  );

  // Register FeeService with ApiService dependency
  locator.registerLazySingleton<FeeService>(
    () => FeeService(locator<ApiService>()),
  );

  // Register FeeProvider with FeeService dependency
  locator.registerLazySingleton<FeeProvider>(
    () => FeeProvider(locator<FeeService>()),
  );

  // Register AccountService with ApiService dependency
  locator.registerLazySingleton<AccountService>(
    () => AccountService(locator<ApiService>()),
  );

  // Register AccountProvider with AccountService dependency
  locator.registerLazySingleton<AccountProvider>(
    () => AccountProvider(locator<AccountService>()),
  );

  // Register PerformanceService with ApiService dependency
  locator.registerLazySingleton<PerformanceService>(
    () => PerformanceService(locator<ApiService>()),
  );

  // Register PerformanceProvider with PerformanceService dependency
  locator.registerLazySingleton<PerformanceProvider>(
    () => PerformanceProvider(locator<PerformanceService>()),
  );

// mark assignment Api with ApiService dependency
 locator.registerLazySingleton<MarkingService>(
    () => MarkingService(locator<ApiService>())
  );

   locator.registerLazySingleton<MarkAssignmentProvider>(
    () => MarkAssignmentProvider(locator<MarkingService>())
  );


  // Register CommentService with ApiService dependency
  locator.registerLazySingleton<CommentService>(
    () => CommentService(locator<ApiService>())
  );
  // Register CommentProvider with CommentService dependency
  locator.registerLazySingleton<CommentProvider>(
    () => CommentProvider(locator<CommentService>())
  );

  // Register RecentService with ApiService dependency
 locator.registerLazySingleton<OverviewService>(()
  => OverviewService( locator<ApiService>()));


  // register delete singlequestion with api service dependency
  locator.registerLazySingleton<DeleteQuestionService>(() => DeleteQuestionService(locator<ApiService>()),);
  locator.registerLazySingleton<DeleteQuestionProvider>(() => DeleteQuestionProvider(locator<DeleteQuestionService>()),);


// register delete syllabusContentService with apiService dependency
locator.registerLazySingleton<DeleteSyllabusService>(() =>DeleteSyllabusService(locator<ApiService>()),);
locator.registerLazySingleton<DeleteSyllabusProvider>(() => DeleteSyllabusProvider(locator<DeleteSyllabusService>()));


  // Register SyllabusContentService with ApiService dependency
  locator.registerLazySingleton<SyllabusContentService>(
    () => SyllabusContentService(locator<ApiService>()),
  );

  // Register SyllabusContentProvider with SyllabusContentService dependency
  locator.registerLazySingleton<SyllabusContentProvider>(
    () => SyllabusContentProvider(locator<SyllabusContentService>()),
  );

  // Register QuizService with ApiService dependency
  locator.registerLazySingleton<QuizService>(
    () => QuizService(locator<ApiService>()),
  );

  locator.registerLazySingleton<QuizProvider>(
    () => QuizProvider(locator<QuizService>()),
  );

  // Register AssignmentService with ApiService dependency
  locator.registerLazySingleton<AssignmentService>(
    () => AssignmentService(locator<ApiService>()),
  );

  locator.registerLazySingleton<AssignmentProvider>(
    () => AssignmentProvider(locator<AssignmentService>()),
  );

  // Register TopicService with ApiService dependency
  locator.registerLazySingleton<TopicService>(
    () => TopicService(locator<ApiService>()),
  );

  // Register TopicProvider with TopicService dependency
  locator.registerLazySingleton<TopicProvider>(
    () => TopicProvider(locator<TopicService>()),
  );

  // Register MaterialService with ApiService dependency
  locator.registerLazySingleton<MaterialService>(
    () => MaterialService(locator<ApiService>()),
  );

  locator.registerLazySingleton<MaterialProvider>(
    () => MaterialProvider(locator<MaterialService>()),
  );

  // Register SkillService with ApiService dependency
  locator.registerLazySingleton<SkillService>(
    () => SkillService(locator<ApiService>()),
  );

  // Register SkillsBehaviorTableProvider with ApiService dependency
  locator.registerLazySingleton<SkillsBehaviorTableProvider>(
    () => SkillsBehaviorTableProvider(locator<ApiService>()),
  );

  locator.registerLazySingleton<SkillsProvider>(
    () => SkillsProvider(locator<SkillService>()),
  );

  // Register StudentService with ApiService dependency
  locator.registerLazySingleton<StudentService>(
    () => StudentService(locator<ApiService>()),
  );

  locator.registerLazySingleton<StudentProvider>(
    () => StudentProvider(locator<StudentService>()),
  );

  // Register GradeService with ApiService dependency
  locator.registerLazySingleton<GradeService>(
    () => GradeService(locator<ApiService>()),
  );

  // Register GradeProvider with GradeService dependency
  locator.registerLazySingleton<GradeProvider>(
    () => GradeProvider(locator<GradeService>()),
  );

  locator.registerLazySingleton<SyllabusService>(
    () => SyllabusService(locator<ApiService>()),
  );

  locator.registerLazySingleton<SyllabusProvider>(
    () => SyllabusProvider(locator<SyllabusService>()),
  );

  // Register ClassService and LevelService
  locator.registerLazySingleton<ClassService>(() => ClassService());
  locator.registerLazySingleton<LevelService>(() => LevelService());

  // Register TermService with ApiService dependency
  locator.registerLazySingleton<TermService>(() {
    final service = TermService();
    service.apiService = locator<ApiService>();
    return service;
  });

  // Register AuthService
  locator.registerLazySingleton<AuthService>(() => AuthService());

  // Register AuthProvider
  locator.registerLazySingleton<AuthProvider>(
    () => AuthProvider(),
  );

  // Register CourseRegistrationService and AssessmentService
  locator.registerLazySingleton<CourseRegistrationService>(() => CourseRegistrationService());
  locator.registerLazySingleton<AssessmentService>(() => AssessmentService());

  // Register AttendanceService
  locator.registerLazySingleton<AttendanceService>(
    () => AttendanceService(locator<ApiService>()),
  );

  // Register AttendanceProvider
  locator.registerLazySingleton<AttendanceProvider>(
    () => AttendanceProvider(),
  );

  // Register PaymentService with ApiService dependency
  locator.registerLazySingleton<PaymentService>(
    () => PaymentService(locator<ApiService>()),
  );
}





// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:get_it/get_it.dart';
// import 'package:linkschool/modules/auth/provider/auth_provider.dart';
// import 'package:linkschool/modules/auth/service/auth_service.dart';
// import 'package:linkschool/modules/providers/admin/attendance_provider.dart';
// import 'package:linkschool/modules/providers/admin/behaviour_provider.dart';
// import 'package:linkschool/modules/providers/admin/e_learning/assignment_provider.dart';
// import 'package:linkschool/modules/providers/admin/e_learning/material_provider.dart';
// import 'package:linkschool/modules/providers/admin/e_learning/quiz_provider.dart';
// import 'package:linkschool/modules/providers/admin/e_learning/syllabus_content_provider.dart';
// import 'package:linkschool/modules/providers/admin/e_learning/syllabus_provider.dart';
// import 'package:linkschool/modules/providers/admin/e_learning/topic_provider.dart';
// import 'package:linkschool/modules/providers/admin/grade_provider.dart';
// import 'package:linkschool/modules/providers/admin/payment/account_provider.dart';
// import 'package:linkschool/modules/providers/admin/payment/fee_provider.dart';
// import 'package:linkschool/modules/providers/admin/performance_provider.dart';
// import 'package:linkschool/modules/providers/admin/skills_behavior_table_provider.dart';
// import 'package:linkschool/modules/services/admin/attendance_service.dart';
// import 'package:linkschool/modules/services/admin/e_learning/assignment_service.dart';
// import 'package:linkschool/modules/services/admin/e_learning/material_service.dart';
// import 'package:linkschool/modules/services/admin/e_learning/quiz_service.dart';
// import 'package:linkschool/modules/services/admin/e_learning/syllabus_content_service.dart';
// import 'package:linkschool/modules/services/admin/e_learning/syllabus_service.dart';
// import 'package:linkschool/modules/services/admin/e_learning/topic_service.dart';
// import 'package:linkschool/modules/services/admin/payment/account_service.dart';
// import 'package:linkschool/modules/services/admin/payment/expenditure_service.dart';
// import 'package:linkschool/modules/services/admin/payment/fee_service.dart';
// import 'package:linkschool/modules/services/admin/payment/vendor_service.dart';
// import 'package:linkschool/modules/services/admin/performance_service.dart';
// import 'package:linkschool/modules/services/api/api_service.dart';
// import 'package:linkschool/modules/services/admin/class_service.dart';
// import 'package:linkschool/modules/services/admin/grade_service.dart';
// import 'package:linkschool/modules/services/admin/level_service.dart';
// import 'package:linkschool/modules/services/admin/student_service.dart';
// import 'package:linkschool/modules/services/admin/term_service.dart';
// import 'package:linkschool/modules/services/admin/course_registration_service.dart';
// import 'package:linkschool/modules/services/admin/assessment_service.dart';
// import 'package:linkschool/modules/providers/admin/student_provider.dart';
// import 'package:linkschool/modules/services/admin/behaviour_service.dart';
// // import 'package:linkschool/modules/model/vendor.dart';
// // import 'package:linkschool/modules/services/admin/vendor_service.dart';

// final GetIt locator = GetIt.instance;

// void setupServiceLocator() {
//   // Initialize API Service with proper configuration
//   locator.registerLazySingleton<ApiService>(() => ApiService(
//         baseUrl: dotenv.env['API_BASE_URL'],
//         apiKey: dotenv.env['API_KEY'],
//       ));

//   // Register VendorService with ApiService dependency
//   locator.registerLazySingleton<VendorService>(
//     () => VendorService(locator<ApiService>()),
//   );

//   // Register FeeService with ApiService dependency
//   locator.registerLazySingleton<FeeService>(
//     () => FeeService(locator<ApiService>()),
//   );

//   // Register FeeProvider with FeeService dependency
//   locator.registerLazySingleton<FeeProvider>(
//     () => FeeProvider(locator<FeeService>()),
//   );

//   // Register AccountService with ApiService dependency
//   locator.registerLazySingleton<AccountService>(
//     () => AccountService(locator<ApiService>()),
//   );

//   // Register AccountProvider with AccountService dependency
//   locator.registerLazySingleton<AccountProvider>(
//     () => AccountProvider(locator<AccountService>()),
//   );

//   // Register PerformanceService with ApiService dependency
//   locator.registerLazySingleton<PerformanceService>(
//     () => PerformanceService(locator<ApiService>()),
//   );

//   // Register PerformanceProvider with PerformanceService dependency
//   locator.registerLazySingleton<PerformanceProvider>(
//     () => PerformanceProvider(locator<PerformanceService>()),
//   );

//   // Register SyllabusContentService with ApiService dependency
//   locator.registerLazySingleton<SyllabusContentService>(
//     () => SyllabusContentService(locator<ApiService>()),
//   );

//   // Register SyllabusContentProvider with SyllabusContentService dependency
//   locator.registerLazySingleton<SyllabusContentProvider>(
//     () => SyllabusContentProvider(locator<SyllabusContentService>()),
//   );

//   // Register QuizService with ApiService dependency
//   locator.registerLazySingleton<QuizService>(
//     () => QuizService(locator<ApiService>()),
//   );

//   locator.registerLazySingleton<QuizProvider>(
//     () => QuizProvider(locator<QuizService>()),
//   );

//   // Register AssignmentService with ApiService dependency
//   locator.registerLazySingleton<AssignmentService>(
//     () => AssignmentService(locator<ApiService>()),
//   );

//   locator.registerLazySingleton<AssignmentProvider>(
//     () => AssignmentProvider(locator<AssignmentService>()),
//   );

//   // Register TopicService with ApiService dependency
//   locator.registerLazySingleton<TopicService>(
//     () => TopicService(locator<ApiService>()),
//   );

//   // Register TopicProvider with TopicService dependency
//   locator.registerLazySingleton<TopicProvider>(
//     () => TopicProvider(locator<TopicService>()),
//   );

//   // Register MaterialService with ApiService dependency
//   locator.registerLazySingleton<MaterialService>(
//     () => MaterialService(locator<ApiService>()),
//   );

//   locator.registerLazySingleton<MaterialProvider>(
//     () => MaterialProvider(locator<MaterialService>()),
//   );

//   // Register SkillService with ApiService dependency
//   locator.registerLazySingleton<SkillService>(
//     () => SkillService(locator<ApiService>()),
//   );

//   // Register SkillsBehaviorTableProvider with ApiService dependency
//   locator.registerLazySingleton<SkillsBehaviorTableProvider>(
//     () => SkillsBehaviorTableProvider(locator<ApiService>()),
//   );

//   locator.registerLazySingleton<SkillsProvider>(
//     () => SkillsProvider(locator<SkillService>()),
//   );

//   // Register StudentService with ApiService dependency
//   locator.registerLazySingleton<StudentService>(
//     () => StudentService(locator<ApiService>()),
//   );

//   locator.registerLazySingleton<StudentProvider>(
//     () => StudentProvider(locator<StudentService>()),
//   );

//   // Register GradeService with ApiService dependency
//   locator.registerLazySingleton<GradeService>(
//     () => GradeService(locator<ApiService>()),
//   );

//   // Register GradeProvider with GradeService dependency
//   locator.registerLazySingleton<GradeProvider>(
//     () => GradeProvider(locator<GradeService>()),
//   );

//   locator.registerLazySingleton<SyllabusService>(
//     () => SyllabusService(locator<ApiService>()),
//   );

//   locator.registerLazySingleton<SyllabusProvider>(
//     () => SyllabusProvider(locator<SyllabusService>()),
//   );

//   // Register ClassService and LevelService
//   locator.registerLazySingleton<ClassService>(() => ClassService());
//   locator.registerLazySingleton<LevelService>(() => LevelService());

//   // Register TermService with ApiService dependency
//   locator.registerLazySingleton<TermService>(() {
//     final service = TermService();
//     service.apiService = locator<ApiService>();
//     return service;
//   });

//   // Register AuthService
//   locator.registerLazySingleton<AuthService>(() => AuthService());

//   // Register AuthProvider
//   locator.registerLazySingleton<AuthProvider>(
//     () => AuthProvider(),
//   );

//   // Register CourseRegistrationService and AssessmentService
//   locator.registerLazySingleton<CourseRegistrationService>(() => CourseRegistrationService());
//   locator.registerLazySingleton<AssessmentService>(() => AssessmentService());

//   // Register AttendanceService
//   locator.registerLazySingleton<AttendanceService>(
//     () => AttendanceService(locator<ApiService>()),
//   );

//   // Register AttendanceProvider
//   locator.registerLazySingleton<AttendanceProvider>(
//     () => AttendanceProvider(),
//   );

//   // Update to service_locator.dart (add this line)
// locator.registerLazySingleton<ExpenditureService>(() => ExpenditureService(locator<ApiService>()));
// }