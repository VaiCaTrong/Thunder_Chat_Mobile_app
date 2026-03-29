import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  Function(String)? onNotificationTap;

  Future<void> initialize() async {
    if (_isInitialized) {
      print('[NotificationService] Already initialized');
      return;
    }

    print('[NotificationService] Initializing...');

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleNotificationTap,
    );

    _isInitialized = true;
    print('[NotificationService] Initialized successfully');
  }

  void _handleNotificationTap(NotificationResponse details) {
    print('[NotificationService] Notification tapped: ${details.payload}');
    if (details.payload != null && onNotificationTap != null) {
      onNotificationTap!(details.payload!);
    }
  }

  Future<bool> requestPermissions() async {
    print('[NotificationService] Requesting permissions...');
    
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission() ?? false;
      print('[NotificationService] Android permission granted: $granted');
      return granted;
    }

    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    
    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      ) ?? false;
      print('[NotificationService] iOS permission granted: $granted');
      return granted;
    }

    return false;
  }

  Future<void> showMessageNotification({
    required String title,
    required String body,
    required String conversationId,
  }) async {
    print('[NotificationService] Showing message notification');
    print('  Title: $title');
    print('  Body: $body');
    print('  ConversationId: $conversationId');

    const androidDetails = AndroidNotificationDetails(
      'message_channel',
      'Message Notifications',
      channelDescription: 'Notification channel for messages',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notifications.show(
        conversationId.hashCode, // Use conversation ID hash as notification ID
        title,
        body,
        details,
        payload: 'message:$conversationId',
      );
      print('[NotificationService] Message notification shown successfully');
    } catch (e) {
      print('[NotificationService] Error showing message notification: $e');
    }
  }

  Future<void> showCallNotification({
    required String callerName,
    required String callId,
  }) async {
    print('[NotificationService] Showing call notification');
    print('  Caller: $callerName');
    print('  CallId: $callId');

    const androidDetails = AndroidNotificationDetails(
      'call_channel',
      'Call Notifications',
      channelDescription: 'Notification channel for video calls',
      importance: Importance.max,
      priority: Priority.max,
      showWhen: true,
      fullScreenIntent: true,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
      ongoing: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.critical,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notifications.show(
        callId.hashCode, // Use call ID hash as notification ID
        '📹 Incoming Video Call',
        '$callerName is calling you...',
        details,
        payload: 'call:$callId',
      );
      print('[NotificationService] Call notification shown successfully');
    } catch (e) {
      print('[NotificationService] Error showing call notification: $e');
    }
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<bool> isNotificationAllowed() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      final allowed = await androidPlugin.areNotificationsEnabled() ?? false;
      print('[NotificationService] Notifications allowed: $allowed');
      return allowed;
    }

    return true; // iOS doesn't have a direct check
  }
}

