import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:linkschool/config/notification_service.dart';
import 'package:linkschool/modules/explore/cbt/cbt_dashboard.dart';
import 'package:linkschool/modules/explore/cbt/cbt_discussion_screen.dart';
import 'package:linkschool/modules/explore/cbt/cbt_plans_screen.dart';
import 'package:linkschool/modules/explore/courses/forum/topic_detail_screen.dart';
import 'package:linkschool/modules/explore/courses/course_description_screen.dart';
import 'package:linkschool/modules/explore/courses/course_detail_screen.dart';
import 'package:linkschool/modules/explore/courses/course_selection_screen.dart';
import 'package:linkschool/modules/explore/courses/explore_courses_see_all_screen.dart';
import 'package:linkschool/modules/explore/home/news/news_details.dart';
import 'package:linkschool/modules/model/explore/courses/course_model.dart';
import 'package:linkschool/modules/model/explore/home/news/news_model.dart';
import 'package:linkschool/modules/providers/explore/home/news_provider.dart';
import 'package:linkschool/modules/providers/explore/courses/discussion_provider.dart';
import 'package:linkschool/modules/services/explore/courses/discussion_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

class NotificationNavigationService {
  static final NotificationNavigationService _instance =
      NotificationNavigationService._internal();

  factory NotificationNavigationService() => _instance;

  NotificationNavigationService._internal();

  GlobalKey<NavigatorState>? _navigatorKey;
  bool _isListening = false;

  Future<void> initialize(GlobalKey<NavigatorState> navigatorKey) async {
    _navigatorKey = navigatorKey;
    if (_isListening) return;
    _isListening = true;

    await NotificationService().initialize();
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    FirebaseMessaging.onMessage.listen((message) {
      NotificationService().showFirebaseNotification(
        title: message.notification?.title ?? '',
        body: message.notification?.body ?? '',
        payload: _stringPayload(message.data),
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      await _handleMessage(initialMessage);
    }
  }

  Future<void> handleDeepLink(Uri uri) async {
    debugPrint('NotificationNavigationService.handleDeepLink: $uri');
    if (!_isSupportedDeepLink(uri)) {
      debugPrint('Deep link ignored: unsupported host/scheme -> $uri');
      return;
    }

    final data = _payloadFromUri(uri);
    if (data.isEmpty) {
      debugPrint('Deep link ignored: empty payload -> $uri');
      return;
    }

    debugPrint('Deep link payload: $data');
    await _waitForNavigatorReady();

    final type = _stringFrom(data, ['type']);
    debugPrint('Deep link type: ${type.isEmpty ? '(missing)' : type}');
    switch (type) {
      case 'news_posted':
        debugPrint('Routing deep link -> NewsDetails');
        await _navigateToNewsDetails(data);
        break;
      case 'discussion_started':
      case 'discussion_comment_added':
      case 'discussion_post_replied':
      case 'discussion_reply_replied':
        debugPrint('Routing deep link -> TopicDetailScreen');
        await _navigateToDiscussionDetail(data);
        break;
      case 'lesson_published':
      case 'submission_graded':
      case 'class_reminder':
      case 'live_class_reminder':
      case 'assignment_due_reminder':
      case 'course_content':
        debugPrint('Routing deep link -> CourseDetailScreen (content)');
        await _navigateToCourseContent(data);
        break;
      case 'course_detail':
        debugPrint('Routing deep link -> CourseDetailScreen');
        _navigateToCourseDetail(data);
        break;
      case 'course_description_by_ref':
        debugPrint('Routing deep link -> CourseDescriptionScreen');
        await _navigateToCourseDescriptionByRef(data);
        break;
      case 'program_enroll':
        debugPrint('Routing deep link -> CourseSelectionScreen');
        await _navigateToProgramEnroll(data);
        break;
      case 'program_courses_by_slug':
        debugPrint('Routing deep link -> ExploreCoursesSeeAllScreen');
        await _navigateToProgramCoursesBySlug(data);
        break;
      case 'cbt_payment':
        debugPrint('Routing deep link -> CbtPlansScreen');
        await _navigateToCbtPlans();
        break;
      case 'cbt_dashboard':
        debugPrint('Routing deep link -> CBTDashboard');
        _navigateToCbtDashboard();
        break;
      case 'cbt_update':
        debugPrint('Routing deep link -> CbtDiscussionDetailScreen');
        await _navigateToCbtDiscussionUpdate(data);
        break;
      case 'app_home':
        debugPrint('Deep link opened app home: $uri');
        break;
      default:
        debugPrint('Deep link default routing check for payload: $data');
        if (_looksLikeCourseContentPayload(data)) {
          debugPrint(
              'Routing deep link -> CourseDetailScreen (fallback content)');
          await _navigateToCourseContent(data);
        } else if (_looksLikeCoursePayload(data)) {
          debugPrint(
              'Routing deep link -> CourseDetailScreen (fallback course)');
          _navigateToCourseDetail(data);
        } else if (_intFrom(data, ['news_id', 'newsId', 'id']) != null) {
          debugPrint('Routing deep link -> NewsDetails (fallback)');
          await _navigateToNewsDetails(data);
        } else {
          debugPrint('Deep link ignored: no matching route -> $uri');
        }
    }
  }

  Future<void> _handleMessage(RemoteMessage message) async {
    final data = message.data;
    if (data.isEmpty) return;

    final type = _stringFrom(data, ['type']);

    switch (type) {
      case 'discussion_started':
      case 'discussion_comment_added':
      case 'discussion_post_replied':
      case 'discussion_reply_replied':
        await _navigateToDiscussionDetail(data);
        break;
      case 'lesson_published':
      case 'submission_graded':
      case 'class_reminder':
      case 'live_class_reminder':
      case 'assignment_due_reminder':
        await _navigateToCourseContent(data);
        break;
      case "news_posted":
        await _navigateToNewsDetails(data);
        break;
      case 'program_enroll':
        await _navigateToProgramEnroll(data);
        break;
      case 'program_courses_by_slug':
        await _navigateToProgramCoursesBySlug(data);
        break;
      case 'cbt_update':
        await _navigateToCbtDiscussionUpdate(data);
        break;
      case 'cbt_update_notification':
        await _navigateToCbtDiscussionUpdate(data);
        break;
      case 'cbt_update_posted':
        await _navigateToCbtDiscussionUpdate(data);
        break;

      default:
        if (_stringFrom(data, ['type']).toLowerCase() == 'cbt_update') {
          await _navigateToCbtDiscussionUpdate(data);
        }
    }
  }

  Future<void> _navigateToCbtDiscussionUpdate(Map<String, dynamic> data) async {
    final updateId = _intFrom(data, ['cbt_update_id', 'cbtUpdateId', 'id']);
    if (updateId == null) {
      return;
    }

    final navigator = _navigatorKey?.currentState;
    if (navigator == null) {
      return;
    }

    navigator.push(
      MaterialPageRoute(
        builder: (context) => CbtDiscussionDetailScreen(
          updateId: updateId,
        ),
      ),
    );
  }

  Map<String, String> _stringPayload(Map<String, dynamic> data) {
    return data.map((key, value) => MapEntry(key, value?.toString() ?? ''));
  }

  bool _looksLikeCoursePayload(Map<String, dynamic> data) {
    return _intFrom(data, ['course_id', 'courseId']) != null &&
        _stringFrom(data, ['cohort_id', 'cohortId']).isNotEmpty;
  }

  bool _looksLikeCourseContentPayload(Map<String, dynamic> data) {
    return _looksLikeCoursePayload(data) &&
        _intFrom(data, ['lesson_id', 'lessonId']) != null;
  }

  void _navigateToCourseDetail(Map<String, dynamic> data) {
    final courseId = _intFrom(data, ['course_id', 'courseId']);
    final cohortId = _stringFrom(data, ['cohort_id', 'cohortId']);
    if (courseId == null || cohortId.isEmpty) {
      return;
    }

    final courseTitle =
        _stringFrom(data, ['course_title', 'courseTitle', 'title']);
    final courseName = _stringFrom(data, ['course_name', 'courseName', 'name']);
    final courseDescription =
        _stringFrom(data, ['course_description', 'courseDescription']);
    final provider =
        _stringFrom(data, ['provider', 'course_provider', 'courseProvider']);
    final lessonId = _intFrom(data, ['lesson_id', 'lessonId']);
    final profileId = _intFrom(data, ['profile_id', 'profileId']);

    final navigator = _navigatorKey?.currentState;
    if (navigator == null) {
      return;
    }

    navigator.push(
      MaterialPageRoute(
        builder: (context) => CourseDetailScreen(
          courseTitle: courseTitle,
          courseName: courseName,
          courseId: courseId,
          courseDescription: courseDescription,
          provider: provider,
          cohortId: cohortId,
          profileId: profileId,
          lessonId: lessonId,
        ),
      ),
    );
  }

  Future<void> _navigateToDiscussionDetail(Map<String, dynamic> data) async {
    final discussionId = _stringFrom(data, ['discussion_id', 'discussionId']);
    final cohortId = _stringFrom(data, ['cohort_id', 'cohortId', 'cohortid']);
    final courseId = _intFrom(data, ['course_id', 'courseId', 'courseid']);
    final programId = _intFrom(data, ['program_id', 'programId', 'programid']);
    final authorId = _intFrom(data, ['author_id', 'authorId']);

    if (discussionId.isEmpty || cohortId.isEmpty) {
      return;
    }

    final navigator = _navigatorKey?.currentState;
    if (navigator == null) {
      return;
    }

    navigator.push(
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (_) => DiscussionProvider(DiscussionService()),
          child: TopicDetailScreen(
            topicId: discussionId,
            cohortId: cohortId,
            authorId: authorId,
            programId: programId,
            courseId: courseId,
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToNewsDetails(Map<String, dynamic> data) async {
    final newsId = _intFrom(data, ['news_id', 'newsId', 'id']);
    if (newsId == null) {
      return;
    }

    final navigator = _navigatorKey?.currentState;
    final context = _navigatorKey?.currentContext;
    if (navigator == null || context == null) {
      return;
    }

    final provider = Provider.of<NewsProvider>(context, listen: false);
    if (provider.newsmodel.isEmpty) {
      await provider.fetchAllNews(refresh: true);
    }

    NewsModel? target = _findNewsById(provider.newsmodel, newsId);

    if (target == null) {
      // Try loading more pages (up to 5) to find the news
      int attempts = 0;
      while (provider.hasNextPage && attempts < 5 && target == null) {
        attempts++;
        await provider.loadMoreAll();
        target = _findNewsById(provider.newsmodel, newsId);
      }
    }

    if (target == null) {
      return;
    }

    final timeAgo = _formatDuration(DateTime.now().difference(
      DateTime.tryParse(target.date_posted) ?? DateTime.now(),
    ));

    final targetNews = target;

    navigator.push(
      MaterialPageRoute(
        builder: (context) => NewsDetails(
          news: targetNews,
          time: timeAgo,
        ),
      ),
    );
  }

  Future<void> _navigateToCourseContent(Map<String, dynamic> data) async {
    final cohortId = _stringFrom(data, ['cohort_id', 'cohortId']);
    final lessonId = _intFrom(data, ['lesson_id', 'lessonId']);
    int? profileId = _intFrom(data, ['profile_id', 'profileId']);

    // ✅ fallback to saved profile
    if (profileId == null || profileId <= 0) {
      final prefs = await SharedPreferences.getInstance();
      profileId = prefs.getInt('active_profile_id');
    }

    if (cohortId.isEmpty || lessonId == null || profileId == null) {
      return;
    }

    final navigator = _navigatorKey?.currentState;
    if (navigator == null) return;

    navigator.push(
      MaterialPageRoute(
        builder: (context) => CourseDetailScreen(
          courseTitle: '', // loaded by LessonDetailProvider
          courseName: '', // loaded by LessonDetailProvider
          courseId: _intFrom(data, ['course_id', 'courseId']) ?? 0,
          courseDescription: '', // loaded by LessonDetailProvider
          provider: '', // loaded by LessonDetailProvider
          cohortId: cohortId, // ✅ key field
          profileId: profileId, // ✅ key field
          lessonId: lessonId, // ✅ key field
        ),
      ),
    );
  }

  Future<void> _navigateToCbtPlans() async {
    final navigator = _navigatorKey?.currentState;
    if (navigator == null) {
      return;
    }

    navigator.push(
      MaterialPageRoute(
        builder: (context) => const CbtPlansScreen(),
      ),
    );
  }

  void _navigateToCbtDashboard() {
    final navigator = _navigatorKey?.currentState;
    if (navigator == null) {
      return;
    }

    navigator.push(
      MaterialPageRoute(
        builder: (context) => const CBTDashboard(),
      ),
    );
  }

  bool _isSupportedDeepLink(Uri uri) {
    final scheme = uri.scheme.toLowerCase();
    final host = uri.host.toLowerCase();
    return (scheme == 'https' || scheme == 'http') &&
        (host == 'linkskool.com' || host == 'www.linkskool.com');
  }

  Map<String, dynamic> _payloadFromUri(Uri uri) {
    final data = <String, dynamic>{...uri.queryParameters};
    final segments =
        uri.pathSegments.where((segment) => segment.isNotEmpty).toList();

    if (segments.isEmpty) {
      return data;
    }

    final first = segments.first.toLowerCase();

    if ((first == 'news' || first == 'article') && segments.length >= 2) {
      data.putIfAbsent('type', () => 'news_posted');
      data.putIfAbsent('news_id', () => segments[1]);
      return data;
    }

    if ((first == 'discussion' || first == 'forum' || first == 'topic') &&
        segments.length >= 2) {
      data.putIfAbsent('type', () => 'discussion_started');
      data.putIfAbsent('discussion_id', () => segments[1]);
      return data;
    }

    if ((first == 'course' || first == 'courses' || first == 'lesson') &&
        segments.length >= 2) {
      data.putIfAbsent('course_id', () => segments[1]);
      if (_stringFrom(data, ['ref']).isNotEmpty) {
        data.putIfAbsent('type', () => 'course_description_by_ref');
      } else if (data.containsKey('lesson_id')) {
        data.putIfAbsent('type', () => 'course_content');
      } else {
        data.putIfAbsent('type', () => 'course_detail');
      }
      return data;
    }

    if (first == 'programs' && segments.length >= 2) {
      data.putIfAbsent('program_slug', () => segments[1]);
      if (segments.length >= 3 && segments[2].toLowerCase() == 'enroll') {
        data.putIfAbsent('type', () => 'program_enroll');
        return data;
      }
      if (segments.length == 2) {
        data.putIfAbsent('type', () => 'program_courses_by_slug');
        return data;
      }
    }

    if (first == 'cbt') {
      if (segments.length >= 2 && segments[1].toLowerCase() == 'updates') {
        if (segments.length >= 3) {
          data.putIfAbsent('type', () => 'cbt_update');
          data.putIfAbsent('cbt_update_id', () => segments[2]);
          return data;
        }

        data.putIfAbsent('type', () => 'cbt_dashboard');
        return data;
      }

      if (segments.length >= 3 &&
          segments[1].toLowerCase() == 'payment' &&
          segments[2].trim().isNotEmpty) {
        data.putIfAbsent('type', () => 'cbt_payment');
        data.putIfAbsent('reference', () => segments[2]);
        return data;
      }

      data.putIfAbsent('type', () => 'cbt_dashboard');
      return data;
    }

    if (first == 'cbt-updates' && segments.length >= 2) {
      final idSegment = segments[1];
      data.putIfAbsent('type', () => 'cbt_update');
      data.putIfAbsent('cbt_update_id', () => idSegment);
      return data;
    }

    if (first == 'learn' && segments.length >= 2) {
      final second = segments[1].toLowerCase();
      if (second == 'class-reminder' || second == 'class_reminder') {
        data.putIfAbsent('type', () => 'class_reminder');
        return data;
      }
      if (second == 'submission-result' || second == 'submission_result') {
        data.putIfAbsent('type', () => 'submission_graded');
        return data;
      }
      if (second == 'live-class' || second == 'live_class') {
        data.putIfAbsent('type', () => 'live_class_reminder');
        return data;
      }
    }

    if (first == 'dashboard' || first == 'home' || first == 'app') {
      data.putIfAbsent('type', () => 'app_home');
      return data;
    }

    return data;
  }

  Future<void> _navigateToCourseDescriptionByRef(
    Map<String, dynamic> data,
  ) async {
    final ref = _stringFrom(data, ['ref']);
    if (ref.isEmpty) {
      return;
    }

    final courseId = _intFrom(data, ['course_id', 'courseId']) ?? 0;
    final cohortIdValue = _stringFrom(data, ['cohort_id', 'cohortId']);
    final cohortId =
        cohortIdValue.isNotEmpty ? cohortIdValue : courseId.toString();
    final categoryId = _intFrom(data, ['program_id', 'programId']) ?? 0;
    final categoryName = _stringFrom(
      data,
      ['program_name', 'provider', 'course_provider', 'courseName'],
    );

    final navigator = _navigatorKey?.currentState;
    if (navigator == null) {
      return;
    }

    navigator.push(
      MaterialPageRoute(
        builder: (context) => CourseDescriptionScreen(
          course: CourseModel(
            id: courseId,
            programId: categoryId,
            courseName: categoryName,
            description: '',
            imageUrl: '',
            hasActiveCohort: true,
            cohortId: int.tryParse(cohortId),
            isFree: false,
            trialType: null,
            trialValue: 0,
            cost: 0.0,
            isEnrolled: false,
            isCompleted: false,
            enrollmentStatus: null,
            paymentStatus: null,
            lessonsTaken: null,
            trialExpiryDate: null,
          ),
          provider: categoryName.isNotEmpty ? categoryName : 'Linkskool',
          categoryName: categoryName.isNotEmpty ? categoryName : 'Linkskool',
          categoryId: categoryId,
          cohortId: cohortId,
          providerSubtitle: 'Powered By Digital Dreams',
          categoryColor: const Color(0xFF6366F1),
          profileId: _intFrom(data, ['profile_id', 'profileId']),
          hasEnrolled: false,
          cohortRef: ref,
        ),
      ),
    );
  }

  Future<void> _navigateToProgramCoursesBySlug(
    Map<String, dynamic> data,
  ) async {
    final slug = _stringFrom(data, ['program_slug', 'slug']);
    if (slug.isEmpty) {
      return;
    }

    int? profileId = _intFrom(data, ['profile_id', 'profileId']);
    if (profileId == null || profileId <= 0) {
      final prefs = await SharedPreferences.getInstance();
      profileId = prefs.getInt('active_profile_id');
    }

    final navigator = _navigatorKey?.currentState;
    if (navigator == null) {
      return;
    }

    navigator.push(
      MaterialPageRoute(
        builder: (context) => ExploreCoursesSeeAllScreen(
          categoryName: _displayNameFromSlug(slug),
          categoryColor: const Color(0xFF6366F1),
          categoryId: _intFrom(data, ['program_id', 'programId']) ?? 0,
          categorySlug: slug,
          profileId: profileId,
        ),
      ),
    );
  }

  Future<void> _navigateToProgramEnroll(Map<String, dynamic> data) async {
    final slug = _stringFrom(data, ['program_slug', 'slug']);
    if (slug.isEmpty) return;

    final navigator = _navigatorKey?.currentState;
    if (navigator == null) return;

    debugPrint('Routing program_enroll push start: slug=$slug');
    navigator.push(
      MaterialPageRoute(
        builder: (context) => CourseSelectionScreen(
          slug: slug,
          returnToExploreCourses: true,
          onReturnToExploreCourses: () async {
            navigator.popUntil((route) => route.isFirst);
          },
        ),
      ),
    );
    debugPrint('Routing program_enroll push submitted: slug=$slug');
  }

  String _displayNameFromSlug(String slug) {
    final cleaned = slug.replaceAll(RegExp(r'[-_]+'), ' ').trim();
    if (cleaned.isEmpty) return 'Program';

    return cleaned.split(RegExp(r'\s+')).map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  Future<void> _waitForNavigatorReady() async {
    for (var attempt = 0; attempt < 20; attempt++) {
      if (_navigatorKey?.currentState != null &&
          _navigatorKey?.currentContext != null) {
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }
  }

  String _stringFrom(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  int? _intFrom(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value == null) continue;
      if (value is int) return value;
      final parsed = int.tryParse(value.toString().trim());
      if (parsed != null) return parsed;
    }
    return null;
  }
}

NewsModel? _findNewsById(List<NewsModel> list, int id) {
  for (final item in list) {
    if (item.id == id) return item;
  }
  return null;
}

String _formatDuration(Duration duration) {
  if (duration.isNegative) return 'just now';

  final seconds = duration.inSeconds;
  if (seconds < 60) return '$seconds seconds ago';

  final minutes = duration.inMinutes;
  if (minutes < 60) return '$minutes minutes ago';

  final hours = duration.inHours;
  if (hours < 24) return '$hours hours ago';

  final days = duration.inDays;
  if (days < 7) return '$days days ago';

  return '${days ~/ 7} weeks ago';
}

/**
 * five types of notifications:
 * submission_graded 
 * class_reminder
 * live_class_reminder
 * assignment_due_reminder
 * lesson_published
 */
