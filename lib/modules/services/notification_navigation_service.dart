import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:linkschool/config/notification_service.dart';
import 'package:linkschool/modules/explore/courses/course_detail_screen.dart';

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
      _handleMessage(initialMessage);
    }
  }

  void _handleMessage(RemoteMessage message) {
    final data = message.data;
    if (data.isEmpty) return;

    final type = _stringFrom(data, ['type', 'screen']);
    final looksLikeCourse = _looksLikeCoursePayload(data);
    if (type == 'submission_graded' || type == 'class_reminder' || type == 'live_class_reminder' || type == 'assignment_due_reminder' || looksLikeCourse) {
      _navigateToCourseDetail(data);
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

/**
 * five types of notifications:
 * submission_graded 
 * class_reminder
 * live_class_reminder
 * assignment_due_reminder
 * lesson_published
 */
