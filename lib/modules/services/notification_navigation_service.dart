import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:linkschool/config/notification_service.dart';
import 'package:linkschool/modules/explore/courses/forum/topic_detail_screen.dart';
import 'package:linkschool/modules/explore/courses/course_detail_screen.dart';
import 'package:linkschool/modules/explore/courses/course_content_screen.dart';
import 'package:linkschool/modules/explore/home/news/news_details.dart';
import 'package:linkschool/modules/model/explore/home/news/news_model.dart';
import 'package:linkschool/modules/providers/explore/home/news_provider.dart';
import 'package:linkschool/modules/providers/explore/courses/discussion_provider.dart';
import 'package:linkschool/modules/services/explore/courses/discussion_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message received: ${message.data}');
  print('Message type: ${message.data['type']}');
  print('Notification title: ${message.notification?.title}');
  print('Notification body: ${message.notification?.body}');
}

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
  
    default:
      print('Unknown notification type: $type');
  }
}

  Map<String, String> _stringPayload(Map<String, dynamic> data) {
    return data.map((key, value) => MapEntry(key, value?.toString() ?? ''));
  }

  bool _looksLikeCoursePayload(Map<String, dynamic> data) {
    return _intFrom(data, ['course_id', 'courseId']) != null &&
        _stringFrom(data, ['cohort_id', 'cohortId']).isNotEmpty;
  }

  void _navigateToCourseDetail(Map<String, dynamic> data) {
    final courseId = _intFrom(data, ['course_id', 'courseId']);
    final cohortId = _stringFrom(data, ['cohort_id', 'cohortId']);
    if (courseId == null || cohortId.isEmpty) {
      print('Notification missing courseId/cohortId, cannot navigate');
      return;
    }

    final courseTitle =
        _stringFrom(data, ['course_title', 'courseTitle', 'title']);
    final courseName =
        _stringFrom(data, ['course_name', 'courseName', 'name']);
    final courseDescription =
        _stringFrom(data, ['course_description', 'courseDescription']);
    final provider =
        _stringFrom(data, ['provider', 'course_provider', 'courseProvider']);
    final lessonId = _intFrom(data, ['lesson_id', 'lessonId']);
    final profileId = _intFrom(data, ['profile_id', 'profileId']);

    final navigator = _navigatorKey?.currentState;
    if (navigator == null) {
      print('Navigator not ready, cannot open CourseDetailScreen');
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
      print('Notification missing discussionId/cohortId, cannot navigate');
      return;
    }

    final navigator = _navigatorKey?.currentState;
    if (navigator == null) {
      print('Navigator not ready, cannot open TopicDetailScreen');
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
    print('Notification missing news_id, cannot navigate');
    return;
  }

  final navigator = _navigatorKey?.currentState;
  final context = _navigatorKey?.currentContext;
  if (navigator == null || context == null) {
    print('Navigator not ready, cannot open NewsDetails');
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
    print('News with id $newsId not found after fetch');
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
    print('Missing required fields, cannot navigate');
    return;
  }

  final navigator = _navigatorKey?.currentState;
  if (navigator == null) return;

  navigator.push(
    MaterialPageRoute(
      builder: (context) => CourseDetailScreen(
        courseTitle: '',        // loaded by LessonDetailProvider
        courseName: '',         // loaded by LessonDetailProvider
        courseId: _intFrom(data, ['course_id', 'courseId']) ?? 0,
        courseDescription: '', // loaded by LessonDetailProvider
        provider: '',          // loaded by LessonDetailProvider
        cohortId: cohortId,    // ✅ key field
        profileId: profileId,  // ✅ key field
        lessonId: lessonId,    // ✅ key field
      ),
    ),
  );
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

  bool? _boolFrom(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value == null) continue;
      if (value is bool) return value;
      final text = value.toString().trim().toLowerCase();
      if (text == 'true' || text == '1' || text == 'yes') return true;
      if (text == 'false' || text == '0' || text == 'no') return false;
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
