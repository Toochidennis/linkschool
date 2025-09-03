import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:linkschool/modules/auth/provider/auth_provider.dart';
import 'package:linkschool/modules/auth/service/auth_service.dart';
import 'package:linkschool/modules/providers/admin/attendance_provider.dart';
import 'package:linkschool/modules/providers/admin/behaviour_provider.dart';
import 'package:linkschool/modules/providers/admin/e_learning/assignment_provider.dart';
// import 'package:linkschool/modules/providers/admin/e_learning/comment_provider.dart';
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
import 'package:linkschool/modules/providers/student/payment_provider.dart';
import 'package:linkschool/modules/providers/student/payment_submission_provider.dart';
import 'package:linkschool/modules/services/admin/attendance_service.dart';
import 'package:linkschool/modules/services/admin/e_learning/activity_service.dart';
import 'package:linkschool/modules/services/admin/e_learning/assignment_service.dart';
// import 'package:linkschool/modules/services/admin/e_learning/comment_service.dart';
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
import 'package:linkschool/modules/services/student/elearningcontent_service.dart';
import 'package:linkschool/modules/services/student/payment_services.dart';
import 'package:linkschool/modules/services/student/payment_submission_services.dart';
import 'package:linkschool/modules/services/student/streams_service.dart';
import 'package:linkschool/modules/providers/student/streams_provider.dart';
import 'package:linkschool/modules/providers/student/marked_assignment_provider.dart';
import 'package:linkschool/modules/services/student/marked_assignment_service.dart';
// import 'package:linkschool/modules/services/student/marked_assignment_service.dart';
// import 'package:linkschool/modules/services/student/streams_service.dart';

import '../../providers/student/comment_provider.dart';
import '../student/comment_service.dart';
import '../student/student_dasboard_service.dart';


final GetIt locator = GetIt.instance;

void setupServiceLocator() {
  // // Initialize API Service with proper configuration
  locator.registerLazySingleton<ApiService>(() => ApiService(
    baseUrl: dotenv.env['API_BASE_URL'],
    apiKey: dotenv.env['API_KEY'],
  ));

  // Register paymentServices with ApiService dependency
  locator.registerLazySingleton< PaymentSubmissionService>(
    () =>  PaymentSubmissionService(locator<ApiService>())
  );
  // Register InvoiceProvider with InvoiceService dependency
  locator.registerLazySingleton<PaymentProvider>(
    () => PaymentProvider(locator< PaymentSubmissionService>() )
  );

  
 

  
  // Register paymentServices with ApiService dependency
  locator.registerLazySingleton<InvoiceService>(
    () => InvoiceService(locator<ApiService>())
  );
  // Register InvoiceProvider with InvoiceService dependency
  locator.registerLazySingleton<InvoiceProvider>(
    () => InvoiceProvider(locator<InvoiceService>())
  );

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
    () => MaterialService(locator<ApiService>())
  );


  locator.registerLazySingleton<MaterialProvider>(
    () => MaterialProvider(locator<MaterialService>())
  );


  // Register SkillService with ApiService dependency
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
    () => SyllabusService(locator<ApiService>()),
  );
  locator.registerLazySingleton<DashboardService>(()
  => DashboardService(locator<ApiService>()));
  locator.registerLazySingleton<ElearningContentService>(()
  => ElearningContentService());
  locator.registerLazySingleton<SyllabusProvider>(
    () => SyllabusProvider(locator<SyllabusService>())
  );
  locator.registerLazySingleton<CommentService>(
          () => CommentService(locator<ApiService>())
  );

  locator.registerLazySingleton<CommentProvider>(
          () => CommentProvider(locator<CommentService>())
  );

  locator.registerLazySingleton<StreamsService>(
          () => StreamsService(locator<ApiService>())
  );
  locator.registerLazySingleton<MarkedAssignmentService>(
          () => MarkedAssignmentService(locator<ApiService>())
  );
  locator.registerLazySingleton<StreamsProvider>(
          () => StreamsProvider(locator<StreamsService>())
  );
  locator.registerLazySingleton<MarkedAssignmentProvider>(
          () => MarkedAssignmentProvider(locator<MarkedAssignmentService>())
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
