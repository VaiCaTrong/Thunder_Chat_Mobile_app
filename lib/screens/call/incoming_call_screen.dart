import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/socket_provider.dart';
import 'video_call_wrapper.dart';

class IncomingCallScreen extends StatelessWidget {
  final String callId;
  final String callerName;
  final String callerId;
  final String? callerAvatar;

  const IncomingCallScreen({
    super.key,
    required this.callId,
    required this.callerName,
    required this.callerId,
    this.callerAvatar,
  });

  void _acceptCall(BuildContext context) {
    final socketProvider = Provider.of<SocketProvider>(context, listen: false);
    
    // Emit call accepted event
    socketProvider.socketService.emit('call-accepted', {
      'callId': callId,
      'callerId': callerId,
    });

    // Navigate to video call screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => VideoCallWrapper(
          callID: callId,
          userName: callerName,
          userID: callerId,
        ),
      ),
    );
  }

  void _declineCall(BuildContext context) {
    final socketProvider = Provider.of<SocketProvider>(context, listen: false);
    
    // Emit call declined event
    socketProvider.socketService.emit('call-declined', {
      'callId': callId,
      'callerId': callerId,
    });

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 60),
            
            // Caller info
            Column(
              children: [
                // Avatar
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                  ),
                  child: callerAvatar != null
                      ? ClipOval(
                          child: Image.network(
                            callerAvatar!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.white,
                        ),
                ),
                const SizedBox(height: 24),
                
                // Caller name
                Text(
                  callerName,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Call status
                Text(
                  'Incoming video call...',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Ringing animation
                _buildRingingAnimation(),
              ],
            ),
            
            // Action buttons
            Padding(
              padding: const EdgeInsets.all(40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Decline button
                  _buildActionButton(
                    icon: Icons.call_end,
                    label: 'Decline',
                    color: Colors.red,
                    onPressed: () => _declineCall(context),
                  ),
                  
                  // Accept button
                  _buildActionButton(
                    icon: Icons.videocam,
                    label: 'Accept',
                    color: Colors.green,
                    onPressed: () => _acceptCall(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRingingAnimation() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(seconds: 1),
      builder: (context, value, child) {
        return Container(
          width: 80 + (value * 20),
          height: 80 + (value * 20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(1 - value),
              width: 2,
            ),
          ),
        );
      },
      onEnd: () {
        // Repeat animation
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white),
            iconSize: 35,
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
