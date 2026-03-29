import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'video_call_screen.dart';
import 'web_video_call_screen.dart';

/// Wrapper to handle video calls on both mobile and web platforms
class VideoCallWrapper extends StatelessWidget {
  final String callID;
  final String userName;
  final String userID;

  const VideoCallWrapper({
    super.key,
    required this.callID,
    required this.userName,
    required this.userID,
  });

  @override
  Widget build(BuildContext context) {
    // Use different implementations for web and mobile
    if (kIsWeb) {
      return WebVideoCallScreen(
        callID: callID,
        userName: userName,
        userID: userID,
      );
    } else {
      return VideoCallScreen(
        callID: callID,
        userName: userName,
        userID: userID,
      );
    }
  }
}
