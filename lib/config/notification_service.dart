import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'download_channel',
          channelName: 'Downloads',
          channelDescription: 'Notifications for completed downloads',
          defaultColor: Color(0xFF4CAF50),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          playSound: true,
          enableVibration: true,
        )
      ],
    );

    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    // Set up the notification listeners
    await _setupNotificationListeners();

    _initialized = true;
  }


  Future<void> _setupNotificationListeners() async {
    AwesomeNotifications().setListeners(
  onActionReceivedMethod: onActionReceived,
);
  }

  Future<void> showDownloadCompleteNotification({
    required String title,
    required String fileName,
    required String filePath,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'download_channel',
        title: title,
        body: 'Tap to open $fileName',
        payload: {'filePath': filePath, 'fileName': fileName},
        notificationLayout: NotificationLayout.Default,
        
      ),
    );
  }

  Future<void> showDownloadErrorNotification({
    required String title,
    required String error,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'download_channel',
        title: title,
        body: error,
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }
}


  @pragma("vm:entry-point")
Future<void> onActionReceived(ReceivedAction action) async {
  final filePath = action.payload?['filePath'];
  
  if (filePath != null) {
    await OpenFilex.open(filePath, type: "application/pdf");
  }
}