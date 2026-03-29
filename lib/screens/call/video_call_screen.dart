import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import '../../config/zego_config.dart';

class VideoCallScreen extends StatelessWidget {
  final String callID;
  final String userName;
  final String userID;

  const VideoCallScreen({
    super.key,
    required this.callID,
    required this.userName,
    required this.userID,
  });

  @override
  Widget build(BuildContext context) {
    return ZegoUIKitPrebuiltCall(
      appID: ZegoConfig.appID,
      appSign: ZegoConfig.appSign,
      userID: userID,
      userName: userName,
      callID: callID,
      config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
        ..audioVideoViewConfig = ZegoPrebuiltAudioVideoViewConfig(
          showSoundWavesInAudioMode: true,
          useVideoViewAspectFill: true,
        )
        ..topMenuBarConfig = ZegoTopMenuBarConfig(
          isVisible: true,
          buttons: [
            ZegoMenuBarButtonName.minimizingButton,
            ZegoMenuBarButtonName.showMemberListButton,
          ],
        )
        ..bottomMenuBarConfig = ZegoBottomMenuBarConfig(
          buttons: [
            ZegoMenuBarButtonName.toggleCameraButton,
            ZegoMenuBarButtonName.toggleMicrophoneButton,
            ZegoMenuBarButtonName.hangUpButton,
            ZegoMenuBarButtonName.switchCameraButton,
          ],
        ),
    );
  }
}
