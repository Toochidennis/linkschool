import 'package:get_it/get_it.dart';
import 'package:linkschool/config/env_config.dart';
import 'package:linkschool/modules/auth/provider/auth_provider.dart';
import 'package:linkschool/modules/auth/service/auth_service.dart';
import 'package:linkschool/modules/providers/admin/attendance_provider.dart';
import 'package:linkschool/modules/providers/admin/behaviour_provider.dart';
import 'package:linkschool/modules/providers/admin/e_learning/admin_comment_provider.dart';
import 'package:linkschool/modules/providers/admin/e_learning/assignment_provider.dart';
import 'package:linkschool/modules/providers/admin/e_learning/comment_provider.dart';
import 'package:linkschool/modules/providers/admin/e_learning/delete_question.dart';
import 'package:linkschool/modules/providers/admin/e_learning/delete_sylabus_content.dart';
import 'package:linkschool/modules/providers/admin/e_learning/mark_assignment_provider.dart';
import 'package:linkschool/modules/providers/admin/e_learning/material_provider.dart';
import 'package:linkschool/modules/providers/admin/e_learning/quiz_provider.dart';
import 'package:linkschool/modules/providers/admin/e_learning/single_content_provider.dart';
import 'package:linkschool/modules/providers/admin/e_learning/syllabus_content_provider.dart';
import 'package:linkschool/modules/providers/admin/e_learning/syllabus_provider.dart';
import 'package:linkschool/modules/providers/admin/e_learning/topic_provider.dart';

import 'package:linkschool/modules/providers/admin/grade_provider.dart';
import 'package:linkschool/modules/providers/admin/home/add_course_provider.dart';
import 'package:linkschool/modules/providers/admin/home/add_staff_provider.dart';
import 'package:linkschool/modules/providers/admin/home/all_feeds.provider.dart';
import 'package:linkschool/modules/providers/admin/home/assign_course_provider.dart';
import 'package:linkschool/modules/providers/admin/home/dashboard_feed_provider.dart';
import 'package:linkschool/modules/providers/admin/home/level_class_provider.dart';
import 'package:linkschool/modules/providers/admin/home/manage_student_provider.dart';
import 'package:linkschool/modules/providers/admin/home/students_metrica.dart';
import 'package:linkschool/modules/providers/admin/payment/account_provider.dart';
import 'package:linkschool/modules/providers/admin/payment/fee_provider.dart';
import 'package:linkschool/modules/providers/admin/skills_behavior_table_provider.dart';
import 'package:linkschool/modules/providers/explore/ebook_provider.dart';
import 'package:linkschool/modules/providers/explore/home/ebook_provider.dart';
import 'package:linkschool/modules/providers/staff/staff_dashboard_provider.dart';
import 'package:linkschool/modules/providers/staff/streams_provider.dart';
import 'package:linkschool/modules/providers/staff/syllabus_provider.dart';
import 'package:linkschool/modules/providers/student/dashboard_provider.dart';
import 'package:linkschool/modules/providers/student/home/student_dashboard_feed_provider.dart';
import 'package:linkschool/modules/providers/student/payment_provider.dart';
import 'package:linkschool/modules/providers/student/payment_submission_provider.dart';
import 'package:linkschool/modules/providers/student/single_elearningcontent_provider.dart';
import 'package:linkschool/modules/providers/student/streams_provider.dart';
import 'package:linkschool/modules/providers/student/student_comment_provider.dart';
import 'package:linkschool/modules/services/admin/attendance_service.dart';
import 'package:linkschool/modules/services/admin/e_learning/activity_service.dart';
import 'package:linkschool/modules/services/admin/e_learning/admin_comment_service.dart';
import 'package:linkschool/modules/services/admin/e_learning/assignment_service.dart';
import 'package:linkschool/modules/services/admin/e_learning/comment_service.dart';
import 'package:linkschool/modules/services/admin/e_learning/delete_question.dart';
import 'package:linkschool/modules/services/admin/e_learning/delete_syllabus_content.dart';
import 'package:linkschool/modules/services/admin/e_learning/marking_service.dart';
import 'package:linkschool/modules/services/admin/e_learning/material_service.dart';
import 'package:linkschool/modules/services/admin/e_learning/quiz_service.dart';
import 'package:linkschool/modules/services/admin/e_learning/single-content_service.dart';
import 'package:linkschool/modules/services/admin/e_learning/syllabus_content_service.dart';
import 'package:linkschool/modules/services/admin/e_learning/syllabus_service.dart';
import 'package:linkschool/modules/services/admin/e_learning/topic_service.dart';
import 'package:linkschool/modules/services/admin/home/add_course_service.dart';
import 'package:linkschool/modules/services/admin/home/add_staff_service.dart';
import 'package:linkschool/modules/services/admin/home/all_feeds.dart';
import 'package:linkschool/modules/services/admin/home/assign_course_service.dart';
import 'package:linkschool/modules/services/admin/home/dashboard_feed_service.dart';
import 'package:linkschool/modules/services/admin/home/level_class_service.dart';
import 'package:linkschool/modules/services/admin/home/manage_student_service.dart';
import 'package:linkschool/modules/services/admin/home/student_metrics.dart';
import 'package:linkschool/modules/services/admin/payment/account_service.dart';
import 'package:linkschool/modules/services/admin/payment/expenditure_service.dart';
import 'package:linkschool/modules/services/admin/payment/fee_service.dart';
import 'package:linkschool/modules/services/admin/payment/payment_service.dart';
import 'package:linkschool/modules/services/admin/payment/vendor_service.dart';
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
import 'package:linkschool/modules/services/explore/ebook_service.dart';
import 'package:linkschool/modules/services/explore/home/ebook_service.dart';
import 'package:linkschool/modules/services/staff/overview_service.dart';
import 'package:linkschool/modules/services/staff/staff_dashboard_service.dart';
import 'package:linkschool/modules/services/staff/streams_service.dart';
import 'package:linkschool/modules/services/staff/syllabus_service.dart';
import 'package:linkschool/modules/services/student/elearningcontent_service.dart';
import 'package:linkschool/modules/services/student/home/student_dashboard_feed_service.dart';
import 'package:linkschool/modules/services/student/payment_services.dart';
import 'package:linkschool/modules/services/student/payment_submission_services.dart';
import 'package:linkschool/modules/services/student/single_elearningcontentservice.dart';
import 'package:linkschool/modules/services/student/streams_service.dart';
import 'package:linkschool/modules/services/student/student_comment_service.dart';
import 'package:linkschool/modules/services/student/student_dasboard_service.dart';

final GetIt locator = GetIt.instance;

void setupServiceLocator() {
  // CRITICAL: Only register essential services for auth flow
  // Other services are registered lazily on-demand

  // Initialize API Service with proper configuration (required immediately)
  locator.registerLazySingleton<ApiService>(() => ApiService(
        baseUrl: EnvConfig.apiBaseUrl,
        apiKey: EnvConfig.apiKey,
      ));

  // Register Auth Service (required for login check)
  locator.registerLazySingleton<AuthService>(() => AuthService());

  // Register AuthProvider with AuthService dependency
  locator.registerLazySingleton<AuthProvider>(() => AuthProvider());

  // DEFERRED: Register remaining services in background after app is visible
  // This significantly reduces startup time
  Future.microtask(() => _registerDeferredServices());
}

/// Register all non-critical services in the background
/// This is called after the main UI is rendered
void _registerDeferredServices() {
  // _____________Explore portal____________________________

  locator.registerLazySingleton<EbookService>(
      () => EbookService(locator<ApiService>()));

  locator.registerFactory<EbookProvider>(
      () => EbookProvider(ebookService: locator<EbookService>()));

  locator.registerLazySingleton<BookService>(
      () => BookService(locator<ApiService>()));

  // Register BookProvider (if you want to use it directly)
  locator.registerFactory<BookProvider>(
      () => BookProvider(ebookService: locator<BookService>()));

// ______________admin home screen_____________________________

// Student metrics
  locator.registerLazySingleton<StudentMetricsService>(
      () => StudentMetricsService(locator<ApiService>()));
  locator.registerLazySingleton<StudentMetricsProvider>(() =>
      StudentMetricsProvider(metricsService: locator<StudentMetricsService>()));

  locator.registerLazySingleton<AssignCourseService>(
      () => AssignCourseService(locator<ApiService>()));
  locator.registerLazySingleton<AssignCourseProvider>(
      () => AssignCourseProvider(locator<AssignCourseService>()));
// Add courses
  locator.registerLazySingleton<CourseService>(
      () => CourseService(locator<ApiService>()));
  locator.registerLazySingleton<CourseProvider>(
      () => CourseProvider(locator<CourseService>()));

  // Add news feed
// Add news feed
  locator.registerLazySingleton<DashboardFeedService>(
    () => DashboardFeedService(locator<ApiService>()),
  );

  // Feed Providers (ChangeNotifiers)
  locator.registerFactory<DashboardFeedProvider>(
    () => DashboardFeedProvider(locator<DashboardFeedService>()),
  );

  // Add news feed with pagination service and provider
  locator.registerLazySingleton<FeedsPaginationService>(
    () => FeedsPaginationService(locator<ApiService>()),
  );
  locator.registerFactory<FeedsPaginationProvider>(
    () => FeedsPaginationProvider(locator<FeedsPaginationService>()),
  );

// Add student
  locator.registerLazySingleton<ManageStudentService>(
      () => ManageStudentService(locator<ApiService>()));
  locator.registerLazySingleton<ManageStudentProvider>(
      () => ManageStudentProvider(locator<ManageStudentService>()));

//  Add staff

  locator.registerLazySingleton<AddStaffService>(
      () => AddStaffService(locator<ApiService>()));

  locator.registerLazySingleton<AddStaffProvider>(
      () => AddStaffProvider(locator<AddStaffService>()));

//  Add levels
  locator.registerLazySingleton<LevelClassService>(
      () => LevelClassService(locator<ApiService>()));

  // Register LevelClassProvider as a singleton, injecting LevelClassService
  locator.registerLazySingleton<LevelClassProvider>(
      () => LevelClassProvider(locator<LevelClassService>()));

// ******************////************************************* */

// ************** Admin payment*****************************/
  locator.registerLazySingleton<ExpenditureService>(
    () => ExpenditureService(locator<ApiService>()),
  );
  locator.registerLazySingleton<PaymentService>(
    () => PaymentService(locator<ApiService>()),
  );

// admin comment  Api with ApiService dependency
  locator.registerLazySingleton<AdminCommentService>(
      () => AdminCommentService(locator<ApiService>()));

  locator.registerLazySingleton<AdminCommentProvider>(
      () => AdminCommentProvider(locator<AdminCommentService>()));

// mark assignment Api with ApiService dependency
  locator.registerLazySingleton<MarkingService>(
      () => MarkingService(locator<ApiService>()));

  locator.registerLazySingleton<MarkAssignmentProvider>(
      () => MarkAssignmentProvider(locator<MarkingService>()));

  locator.registerLazySingleton<DashboardService>(
      () => DashboardService(locator<ApiService>()));

  // Register DashboardProvider with DashboardService dependency
  locator.registerLazySingleton<DashboardProvider>(() => DashboardProvider());

  // Register CommentService with ApiService dependency
  locator.registerLazySingleton<CommentService>(
      () => CommentService(locator<ApiService>()));
  // Register CommentProvider with CommentService dependency
  locator.registerLazySingleton<CommentProvider>(
      () => CommentProvider(locator<CommentService>()));

  // Register RecentService with ApiService dependency
  locator.registerLazySingleton<OverviewService>(
      () => OverviewService(locator<ApiService>()));

  // register delete singlequestion with api service dependency
  locator.registerLazySingleton<DeleteQuestionService>(
    () => DeleteQuestionService(locator<ApiService>()),
  );
  locator.registerLazySingleton<DeleteQuestionProvider>(
    () => DeleteQuestionProvider(locator<DeleteQuestionService>()),
  );

// register delete syllabusContentService with apiService dependency
  locator.registerLazySingleton<DeleteSyllabusService>(
    () => DeleteSyllabusService(locator<ApiService>()),
  );
  locator.registerLazySingleton<DeleteSyllabusProvider>(
      () => DeleteSyllabusProvider(locator<DeleteSyllabusService>()));

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
      () => QuizService(locator<ApiService>()));

  locator.registerLazySingleton<QuizProvider>(
      () => QuizProvider(locator<QuizService>()));

// Register AssignmentService with ApiService dependency
  locator.registerLazySingleton<AssignmentService>(
      () => AssignmentService(locator<ApiService>()));

  locator.registerLazySingleton<AssignmentProvider>(
      () => AssignmentProvider(locator<AssignmentService>()));

  // Register MaterialService with ApiService dependency
  locator.registerLazySingleton<MaterialService>(
      () => MaterialService(locator<ApiService>()));

  locator.registerLazySingleton<MaterialProvider>(
      () => MaterialProvider(locator<MaterialService>()));

  // Register SkillService with ApiService dependency
  locator.registerLazySingleton<SkillService>(
      () => SkillService(locator<ApiService>()));

  locator.registerLazySingleton<SkillsProvider>(
      () => SkillsProvider(locator<SkillService>()));

  locator.registerFactory(
      () => SkillsBehaviorTableProvider(locator<ApiService>()));

  // Register TopicProvider with SkillService dependen
  locator.registerLazySingleton<TopicService>(
      () => TopicService(locator<ApiService>()));

  locator.registerLazySingleton<TopicProvider>(
      () => TopicProvider(locator<TopicService>()));

  // Register StudentService with ApiService dependency
  locator.registerLazySingleton<StudentService>(
      () => StudentService(locator<ApiService>()));

  locator.registerLazySingleton<StudentProvider>(
      () => StudentProvider(locator<StudentService>()));
  // ------------------ Student portal ----------------------------
  locator.registerLazySingleton<StudentDashboardFeedService>(
    () => StudentDashboardFeedService(locator<ApiService>()),
  );

  // Feed Providers (ChangeNotifiers)
  locator.registerFactory<StudentDashboardFeedProvider>(
    () => StudentDashboardFeedProvider(locator<StudentDashboardFeedService>()),
  );
// ----------------------------------------------------------

//------------------- Staff portal ----------------------------

  locator.registerLazySingleton<StaffDashboardService>(
    () => StaffDashboardService(locator<ApiService>()),
  );

  // Feed Providers (ChangeNotifiers)
  locator.registerFactory<StaffDashboardProvider>(
    () => StaffDashboardProvider(locator<StaffDashboardService>()),
  );

// *************************************************************************

//  Rgister invoice service and provider
  locator.registerLazySingleton<InvoiceService>(
      () => InvoiceService(locator<ApiService>()));
  locator.registerLazySingleton<InvoiceProvider>(
      () => InvoiceProvider(locator<InvoiceService>()));
  // Register GradeService with ApiService dependency
  locator.registerLazySingleton<GradeService>(
      () => GradeService(locator<ApiService>()));

  // Register GradeProvider with GradeService dependency
  locator.registerLazySingleton<GradeProvider>(
      () => GradeProvider(locator<GradeService>()));

  locator.registerLazySingleton<SyllabusService>(
      () => SyllabusService(locator<ApiService>()));
  locator.registerLazySingleton<SyllabusProvider>(
      () => SyllabusProvider(locator<SyllabusService>()));

  locator.registerLazySingleton<ClassService>(() => ClassService());
  locator.registerLazySingleton<LevelService>(() => LevelService());

  // Register TermService with ApiService dependency
  locator.registerLazySingleton<TermService>(() {
    final service = TermService();
    service.apiService = locator<ApiService>();
    return service;
  });

  // Register the missing services
  locator.registerLazySingleton<CourseRegistrationService>(
      () => CourseRegistrationService());
  locator.registerLazySingleton<AssessmentService>(() => AssessmentService());

  // Register AttendanceService
  locator.registerLazySingleton<AttendanceService>(
      () => AttendanceService(locator<ApiService>()));

  // Register AttendanceProvider
  locator.registerLazySingleton<AttendanceProvider>(() => AttendanceProvider());

  // Admin account settings provider and service
  locator.registerLazySingleton<AccountService>(
      () => AccountService(locator<ApiService>()));

  locator.registerLazySingleton<AccountProvider>(
      () => AccountProvider(locator<AccountService>()));

  // Register feeSettings Service and provider
  locator.registerLazySingleton<FeeService>(
      () => FeeService(locator<ApiService>()));
  locator.registerLazySingleton<FeeProvider>(
      () => FeeProvider(locator<FeeService>()));

  // register vendor service and provider
  locator.registerLazySingleton<VendorService>(
      () => VendorService(locator<ApiService>()));
  //Register Staff Provider and service api

  locator.registerLazySingleton<StaffOverviewService>(
      () => StaffOverviewService(locator<ApiService>()));

  locator.registerLazySingleton<StaffSyllabusService>(
      () => StaffSyllabusService(locator<ApiService>()));
  locator.registerLazySingleton<StaffSyllabusProvider>(
      () => StaffSyllabusProvider(locator<StaffSyllabusService>()));

  // Register SingleContentService with ApiService dependency
  locator.registerLazySingleton<SingleAssessmentService>(
      () => SingleAssessmentService());
  // Register SingleContentProvider with SingleContentService dependency
  locator.registerLazySingleton<SingleContentProvider>(
      () => SingleContentProvider());

  locator.registerLazySingleton<ElearningContentService>(
      () => ElearningContentService());

  locator.registerLazySingleton<SingleElearningcontentservice>(
      () => SingleElearningcontentservice());

  locator.registerLazySingleton<StudentCommentService>(
      () => StudentCommentService(locator<ApiService>()));

  locator.registerLazySingleton<StudentCommentProvider>(
      () => StudentCommentProvider(locator<StudentCommentService>()));

  locator.registerLazySingleton<SingleelearningcontentProvider>(
      () => SingleelearningcontentProvider());

  locator.registerLazySingleton<StaffStreamsProvider>(
      () => StaffStreamsProvider(locator<StaffStreamsService>()));
  locator.registerLazySingleton<StaffStreamsService>(
      () => StaffStreamsService(locator<ApiService>()));

  locator.registerLazySingleton<PaymentSubmissionService>(
      () => PaymentSubmissionService(locator<ApiService>()));
  // Register InvoiceProvider with InvoiceService dependency
  locator.registerLazySingleton<PaymentProvider>(
      () => PaymentProvider(locator<PaymentSubmissionService>()));

  locator.registerLazySingleton<StreamsProvider>(
      () => StreamsProvider(locator<StreamsService>()));
  locator.registerLazySingleton<StreamsService>(
      () => StreamsService(locator<ApiService>()));

  print('✅ Deferred services registered in background');
}
