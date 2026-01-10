import 'package:linkschool/modules/auth/provider/auth_provider.dart';
import 'package:linkschool/modules/providers/admin/assessment_provider.dart';
import 'package:linkschool/modules/providers/admin/attendance_provider.dart';
import 'package:linkschool/modules/providers/admin/behaviour_provider.dart';
import 'package:linkschool/modules/providers/admin/class_provider.dart';
import 'package:linkschool/modules/providers/admin/course_registration_provider.dart';
import 'package:linkschool/modules/providers/admin/e_learning/activity_provider.dart';
import 'package:linkschool/modules/providers/admin/e_learning/assignment_provider.dart';
import 'package:linkschool/modules/providers/admin/e_learning/admin_comment_provider.dart';
import 'package:linkschool/modules/providers/admin/e_learning/comment_provider.dart';
import 'package:linkschool/modules/providers/admin/e_learning/delete_question.dart';
import 'package:linkschool/modules/providers/admin/e_learning/delete_sylabus_content.dart';
import 'package:linkschool/modules/providers/admin/e_learning/mark_assignment_provider.dart';
import 'package:linkschool/modules/providers/admin/e_learning/material_provider.dart';
import 'package:linkschool/modules/providers/admin/e_learning/quiz_provider.dart';
import 'package:linkschool/modules/providers/admin/e_learning/single_content_provider.dart';
import 'package:linkschool/modules/providers/admin/e_learning/syllabus_content_provider.dart';
import 'package:linkschool/modules/providers/admin/e_learning/syllabus_provider.dart';
import 'package:linkschool/modules/providers/admin/course_result_provider.dart';
import 'package:linkschool/modules/providers/admin/e_learning/topic_provider.dart';
import 'package:linkschool/modules/providers/admin/home/add_staff_provider.dart';
import 'package:linkschool/modules/providers/admin/home/add_course_provider.dart';
import 'package:linkschool/modules/providers/admin/home/all_feeds.provider.dart';
import 'package:linkschool/modules/providers/admin/home/assign_course_provider.dart';
import 'package:linkschool/modules/providers/admin/home/dashboard_feed_provider.dart';
import 'package:linkschool/modules/providers/admin/home/level_class_provider.dart';
import 'package:linkschool/modules/providers/admin/home/manage_student_provider.dart';
import 'package:linkschool/modules/providers/admin/home/students_metrica.dart';
import 'package:linkschool/modules/providers/admin/level_provider.dart';
import 'package:linkschool/modules/providers/admin/payment/account_provider.dart';
import 'package:linkschool/modules/providers/admin/payment/fee_provider.dart';
import 'package:linkschool/modules/providers/admin/performance_provider.dart';
import 'package:linkschool/modules/providers/admin/skills_behavior_table_provider.dart';
import 'package:linkschool/modules/providers/admin/student_provider.dart';
import 'package:linkschool/modules/providers/admin/term_provider.dart';
import 'package:linkschool/modules/providers/admin/view_course_result_provider.dart';
import 'package:linkschool/modules/providers/cbt_user_provider.dart';
import 'package:linkschool/modules/providers/explore/cbt_provider.dart';
import 'package:linkschool/modules/providers/explore/challenge/challenge_provider.dart';
import 'package:linkschool/modules/providers/explore/challenge/challenge_questions.dart';
import 'package:linkschool/modules/providers/explore/courses/lesson_provider.dart';
import 'package:linkschool/modules/providers/explore/ebook_provider.dart';
import 'package:linkschool/modules/providers/explore/exam_provider.dart';
import 'package:linkschool/modules/providers/explore/for_you_provider.dart';
import 'package:linkschool/modules/providers/explore/home/admission_provider.dart';
import 'package:linkschool/modules/providers/explore/home/announcement_provider.dart';
import 'package:linkschool/modules/providers/explore/home/ebook_provider.dart';
import 'package:linkschool/modules/providers/explore/home/news_provider.dart';
import 'package:linkschool/modules/providers/explore/courses/course_provider.dart';
import 'package:linkschool/modules/providers/explore/studies_question_provider.dart';
import 'package:linkschool/modules/providers/explore/subject_provider.dart';
import 'package:linkschool/modules/providers/explore/subject_topic_provider.dart';
import 'package:linkschool/modules/providers/explore/videos/video_provider.dart';
import 'package:linkschool/modules/providers/login/schools_provider.dart';
import 'package:linkschool/modules/providers/staff/overview.dart';
import 'package:linkschool/modules/providers/staff/staff_dashboard_provider.dart';
import 'package:linkschool/modules/providers/staff/streams_provider.dart';
import 'package:linkschool/modules/providers/staff/syllabus_provider.dart';
import 'package:linkschool/modules/providers/student/elearningcontent_provider.dart';
import 'package:linkschool/modules/providers/student/home/student_dashboard_feed_provider.dart';
import 'package:linkschool/modules/providers/student/payment_provider.dart';
import 'package:linkschool/modules/providers/student/payment_submission_provider.dart';
import 'package:linkschool/modules/providers/student/marked_assignment_provider.dart';
import 'package:linkschool/modules/providers/student/single_elearningcontent_provider.dart';
import 'package:linkschool/modules/providers/student/streams_provider.dart';
import 'package:linkschool/modules/providers/student/student_comment_provider.dart';
import 'package:linkschool/modules/providers/student/student_result_provider.dart';
import 'package:linkschool/modules/providers/explore/game/game_provider.dart';
import 'package:linkschool/modules/providers/admin/grade_provider.dart';
import 'package:linkschool/modules/providers/student/dashboard_provider.dart';
import 'package:linkschool/modules/providers/app_settings_provider.dart';
import 'package:linkschool/modules/providers/explore/challenge/challenge_leader_provider.dart';
import 'package:linkschool/modules/providers/admin/registered_terms_provider.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';
import 'package:linkschool/modules/services/explore/cbt_service.dart';
import 'package:linkschool/modules/services/explore/challange/challange_leader_service.dart';
import 'package:linkschool/modules/services/explore/challange/challenge_service.dart';
import 'package:linkschool/modules/services/explore/courses/lessons_service.dart';
import 'package:linkschool/modules/services/explore/studies_question_service.dart';
import 'package:linkschool/modules/services/explore/subject_topic_sevice.dart';
import 'package:linkschool/modules/services/explore/video/video_service.dart';
import 'package:linkschool/modules/services/staff/overview_service.dart';
import 'package:linkschool/modules/services/admin/e_learning/activity_service.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// Provides all ChangeNotifierProviders for the app
/// This keeps the main.dart file clean and organized
/// Most providers are lazy-loaded to avoid instantiation until needed
List<SingleChildWidget> getAppProviders() {
  return [
    // App Settings Provider - Loads asynchronously
    ChangeNotifierProvider<AppSettingsProvider>(
      create: (_) {
        final provider = AppSettingsProvider();
        // Initialize settings asynchronously without blocking
        Future.microtask(() => provider.initializeSettings());
        return provider;
      },
      lazy: false, // Load immediately for theme
    ),

    // Core providers (needed for auth flow)
    ChangeNotifierProvider<AuthProvider>(
        create: (_) => locator<AuthProvider>()),
    ChangeNotifierProvider(create: (_) => SchoolProvider()),

    // Explore - ALL LAZY (loaded on demand)
    ChangeNotifierProvider(create: (_) => AdmissionProvider(), lazy: true),
    ChangeNotifierProvider<NewsProvider>(
        create: (_) => NewsProvider(), lazy: true),
    ChangeNotifierProvider(create: (_) => AnnouncementProvider(), lazy: true),
    ChangeNotifierProvider(
        create: (_) => ChallengeProvider(ChallengeService()), lazy: true),
    ChangeNotifierProvider(
        create: (_) => SubjectTopicsProvider(SubjectTopicsService()),
        lazy: true),
    ChangeNotifierProvider(create: (_) => SubjectProvider(), lazy: true),
    ChangeNotifierProvider(create: (_) => CbtUserProvider(), lazy: true),
    ChangeNotifierProvider(
        create: (_) => CBTProvider(CBTService()), lazy: true),
    ChangeNotifierProvider(create: (_) => GameProvider(), lazy: true),
    ChangeNotifierProvider(create: (_) => ExamProvider(), lazy: true),
    ChangeNotifierProvider(create: (_) => ForYouProvider(), lazy: true),
    ChangeNotifierProvider<BookProvider>(
        create: (_) => locator<BookProvider>(), lazy: true),
    ChangeNotifierProvider<EbookProvider>(
        create: (_) => locator<EbookProvider>(), lazy: true),
    ChangeNotifierProvider(
        create: (_) => ChallengeQuestionProvider(), lazy: true),
    ChangeNotifierProvider(create: (_) => ExploreCourseProvider(), lazy: true),
    ChangeNotifierProvider(
        create: (_) => LessonProvider(LessonService()), lazy: true),
    ChangeNotifierProvider(
        create: (_) => LeaderboardProvider(LeaderboardService()), lazy: true),
    ChangeNotifierProvider(
        create: (_) => QuestionsProvider(QuestionsService()), lazy: true),
    ChangeNotifierProvider(
        create: (_) => CourseVideoProvider(CourseVideoService()), lazy: true),

    // Admin HomeScreen - ALL LAZY

    // student metrics
    ChangeNotifierProvider<StudentMetricsProvider>(
        create: (_) => locator<StudentMetricsProvider>(), lazy: true),
    ChangeNotifierProvider<AddStaffProvider>(
        create: (_) => locator<AddStaffProvider>(), lazy: true),
    ChangeNotifierProvider<LevelClassProvider>(
      create: (_) => locator<LevelClassProvider>(),
      lazy: true,
    ),
    ChangeNotifierProvider<AssignCourseProvider>(
      create: (_) => locator<AssignCourseProvider>(),
      lazy: true,
    ),
    ChangeNotifierProvider<ManageStudentProvider>(
        create: (_) => locator<ManageStudentProvider>(), lazy: true),
    ChangeNotifierProvider<CourseProvider>(
        create: (_) => locator<CourseProvider>(), lazy: true),
    ChangeNotifierProvider<DashboardFeedProvider>(
        create: (_) => locator<DashboardFeedProvider>(), lazy: true),
    ChangeNotifierProvider<FeedsPaginationProvider>(
        create: (_) => locator<FeedsPaginationProvider>(), lazy: true),

    // Admin E-Learning - ALL LAZY
    ChangeNotifierProvider<SyllabusProvider>(
        create: (_) => locator<SyllabusProvider>(), lazy: true),
    ChangeNotifierProvider<SyllabusContentProvider>(
        create: (_) => locator<SyllabusContentProvider>(), lazy: true),
    ChangeNotifierProvider<TopicProvider>(
        create: (_) => locator<TopicProvider>(), lazy: true),
    ChangeNotifierProvider<MaterialProvider>(
        create: (_) => locator<MaterialProvider>(), lazy: true),
    ChangeNotifierProvider<AssignmentProvider>(
        create: (_) => locator<AssignmentProvider>(), lazy: true),
    ChangeNotifierProvider<QuizProvider>(
        create: (_) => locator<QuizProvider>(), lazy: true),
    ChangeNotifierProvider<DeleteSyllabusProvider>(
        create: (_) => locator<DeleteSyllabusProvider>(), lazy: true),
    ChangeNotifierProvider<DeleteQuestionProvider>(
        create: (_) => locator<DeleteQuestionProvider>(), lazy: true),
    ChangeNotifierProvider<MarkAssignmentProvider>(
        create: (_) => locator<MarkAssignmentProvider>(), lazy: true),
    ChangeNotifierProvider<SingleContentProvider>(
        create: (_) => locator<SingleContentProvider>(), lazy: true),
    ChangeNotifierProvider(
        create: (_) => OverviewProvider(locator<OverviewService>()),
        lazy: true),
    ChangeNotifierProvider<AdminCommentProvider>(
        create: (_) => locator<AdminCommentProvider>(), lazy: true),
    ChangeNotifierProvider<StudentCommentProvider>(
        create: (_) => locator<StudentCommentProvider>(), lazy: true),
    ChangeNotifierProvider<CommentProvider>(
        create: (_) => locator<CommentProvider>(), lazy: true),

    // Admin core - ALL LAZY
    ChangeNotifierProvider<GradeProvider>(
        create: (_) => locator<GradeProvider>(), lazy: true),
    ChangeNotifierProvider<SkillsProvider>(
        create: (_) => locator<SkillsProvider>(), lazy: true),
    ChangeNotifierProvider<SkillsBehaviorTableProvider>(
        create: (_) => locator<SkillsBehaviorTableProvider>(), lazy: true),
    ChangeNotifierProvider<StudentProvider>(
        create: (_) => locator<StudentProvider>(), lazy: true),
    ChangeNotifierProvider<AttendanceProvider>(
        create: (_) => locator<AttendanceProvider>(), lazy: true),
    ChangeNotifierProvider<PerformanceProvider>(
        create: (_) => locator<PerformanceProvider>(), lazy: true),

    // Payments - ALL LAZY
    ChangeNotifierProvider<AccountProvider>(
        create: (_) => locator<AccountProvider>(), lazy: true),
    ChangeNotifierProvider<FeeProvider>(
        create: (_) => locator<FeeProvider>(), lazy: true),

    // Level, Class, Assessment, Term - ALL LAZY
    ChangeNotifierProvider(create: (_) => LevelProvider(), lazy: true),
    ChangeNotifierProvider(create: (_) => ClassProvider(), lazy: true),
    ChangeNotifierProvider(create: (_) => AssessmentProvider(), lazy: true),
    ChangeNotifierProvider(create: (_) => TermProvider(), lazy: true),
    ChangeNotifierProvider(
        create: (_) => RegisteredTermsProvider(), lazy: true),
    ChangeNotifierProvider(
        create: (_) => CourseRegistrationProvider(), lazy: true),

    // Course results - ALL LAZY
    ChangeNotifierProvider(create: (_) => CourseResultProvider(), lazy: true),
    ChangeNotifierProvider(
        create: (_) => ViewCourseResultProvider(), lazy: true),
    ChangeNotifierProvider<AdminCommentProvider>(
        create: (_) => locator<AdminCommentProvider>(), lazy: true),

    // Student - ALL LAZY
    ChangeNotifierProvider(create: (_) => DashboardProvider(), lazy: true),
    ChangeNotifierProvider(
        create: (_) => ElearningContentProvider(), lazy: true),
    ChangeNotifierProvider<StreamsProvider>(
        create: (_) => locator<StreamsProvider>(), lazy: true),
    ChangeNotifierProvider<MarkedAssignmentProvider>(
        create: (_) => locator<MarkedAssignmentProvider>(), lazy: true),
    ChangeNotifierProvider<StudentResultProvider>(
        create: (_) => locator<StudentResultProvider>(), lazy: true),
    ChangeNotifierProvider<InvoiceProvider>(
        create: (_) => locator<InvoiceProvider>(), lazy: true),
    ChangeNotifierProvider<PaymentProvider>(
        create: (_) => locator<PaymentProvider>(), lazy: true),
    ChangeNotifierProvider<StudentDashboardFeedProvider>(
        create: (_) => locator<StudentDashboardFeedProvider>(), lazy: true),
    ChangeNotifierProvider<SingleelearningcontentProvider>(
        create: (_) => locator<SingleelearningcontentProvider>(), lazy: true),
    ChangeNotifierProvider<SingleelearningcontentProvider>(
        create: (_) => locator<SingleelearningcontentProvider>(), lazy: true),

    // Staff - ALL LAZY
    ChangeNotifierProvider<StaffSyllabusProvider>(
        create: (_) => locator<StaffSyllabusProvider>(), lazy: true),
    ChangeNotifierProvider(
        create: (_) => StaffOverviewProvider(locator<StaffOverviewService>()),
        lazy: true),
    ChangeNotifierProvider<StaffStreamsProvider>(
        create: (_) => locator<StaffStreamsProvider>(), lazy: true),
    ChangeNotifierProvider<StaffDashboardProvider>(
        create: (_) => locator<StaffDashboardProvider>(), lazy: true),
  ];
}
