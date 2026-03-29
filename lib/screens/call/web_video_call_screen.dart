import 'package:flutter/material.dart';

/// Web-specific video call implementation using WebRTC
class WebVideoCallScreen extends StatefulWidget {
  final String callID;
  final String userName;
  final String userID;

  const WebVideoCallScreen({
    super.key,
    required this.callID,
    required this.userName,
    required this.userID,
  });

  @override
  State<WebVideoCallScreen> createState() => _WebVideoCallScreenState();
}

class _WebVideoCallScreenState extends State<WebVideoCallScreen> {
  bool _isMicOn = true;
  bool _isCameraOn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Call ID: ${widget.callID}'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.videocam_off,
              size: 64,
              color: Colors.white54,
            ),
            const SizedBox(height: 16),
            const Text(
              'Video call is only available on web platform',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('End Call'),
            ),
          ],
        ),
      ),
    );
  }
}
