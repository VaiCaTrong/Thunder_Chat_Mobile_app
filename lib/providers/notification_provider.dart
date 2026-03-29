import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  bool _isInitialized = false;
  bool _permissionGranted = false;

  bool get isInitialized => _isInitialized;
  bool get permissionGranted => _permissionGranted;

  Future<void> initialize() async {
    if (_isInitialized) return;

    await _notificationService.initialize();
    _permissionGranted = await _notificationService.isNotificationAllowed();
    
    if (!_permissionGranted) {
      _permissionGranted = await _notificationService.requestPermissions();
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> requestPermissions() async {
    _permissionGranted = await _notificationService.requestPermissions();
    notifyListeners();
  }

  Future<void> showMessageNotification({
    required String senderName,
    required String message,
    required String conversationId,
    String? senderAvatar,
  }) async {
    if (!_permissionGranted) return;

    await _notificationService.showMessageNotification(
      title: senderName,
      body: message,
      conversationId: conversationId,
    );
  }

  Future<void> showCallNotification({
    required String callerName,
    required String callId,
    String? callerAvatar,
  }) async {
    if (!_permissionGranted) return;

    await _notificationService.showCallNotification(
      callerName: callerName,
      callId: callId,
    );
  }

  Future<void> cancelAllNotifications() async {
    await _notificationService.cancelAllNotifications();
  }
}
