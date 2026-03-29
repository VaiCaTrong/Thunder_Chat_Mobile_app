import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/socket_provider.dart';
import 'video_call_wrapper.dart';

class OutgoingCallScreen extends StatefulWidget {
  final String callId;
  final String recipientName;
  final String recipientId;
  final String? recipientAvatar;
  final String currentUserId;
  final String currentUserName;

  const OutgoingCallScreen({
    super.key,
    required this.callId,
    required this.recipientName,
    required this.recipientId,
    this.recipientAvatar,
    required this.currentUserId,
    required this.currentUserName,
  });

  @override
  State<OutgoingCallScreen> createState() => _OutgoingCallScreenState();
}

class _OutgoingCallScreenState extends State<OutgoingCallScreen> {
  bool _isWaiting = true;

  @override
  void initState() {
    super.initState();
    _setupCallListeners();
  }

  void _setupCallListeners() {
    final socketProvider = Provider.of<SocketProvider>(context, listen: false);
    
    // Listen for call accepted
    socketProvider.socketService.on('call-accepted', (data) {
      print('Call accepted: $data');
      if (data['callId'] == widget.callId && mounted) {
        setState(() => _isWaiting = false);
        
        // Navigate to video call
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => VideoCallWrapper(
              callID: widget.callId,
              userName: widget.currentUserName,
              userID: widget.currentUserId,
            ),
          ),
        );
      }
    });
    
    // Listen for call declined
    socketProvider.socketService.on('call-declined', (data) {
      print('Call declined: $data');
      if (data['callId'] == widget.callId && mounted) {
        _showCallDeclined();
      }
    });
    
    // Listen for call timeout (optional)
    Future.delayed(const Duration(seconds: 60), () {
      if (mounted && _isWaiting) {
        _showCallTimeout();
      }
    });
  }

  void _showCallDeclined() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Call declined')),
    );
    Navigator.of(context).pop();
  }

  void _showCallTimeout() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No answer')),
    );
    Navigator.of(context).pop();
  }

  void _cancelCall() {
    final socketProvider = Provider.of<SocketProvider>(context, listen: false);
    
    // Emit call cancelled event
    socketProvider.socketService.emit('call-cancelled', {
      'callId': widget.callId,
      'recipientId': widget.recipientId,
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
            
            // Recipient info
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
                  child: widget.recipientAvatar != null
                      ? ClipOval(
                          child: Image.network(
                            widget.recipientAvatar!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.white,
                        ),
                ),
                const SizedBox(height: 24),
                
                // Recipient name
                Text(
                  widget.recipientName,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Call status
                Text(
                  _isWaiting ? 'Calling...' : 'Connecting...',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Waiting animation
                if (_isWaiting) _buildWaitingAnimation(),
              ],
            ),
            
            // Cancel button
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.call_end, color: Colors.white),
                      iconSize: 35,
                      onPressed: _cancelCall,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaitingAnimation() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1500),
      builder: (context, value, child) {
        return Opacity(
          opacity: 1 - value,
          child: Container(
            width: 80 + (value * 40),
            height: 80 + (value * 40),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
          ),
        );
      },
      onEnd: () {
        if (mounted && _isWaiting) {
          setState(() {}); // Trigger rebuild to restart animation
        }
      },
    );
  }

  @override
  void dispose() {
    // Clean up listeners
    final socketProvider = Provider.of<SocketProvider>(context, listen: false);
    socketProvider.socketService.off('call-accepted');
    socketProvider.socketService.off('call-declined');
    super.dispose();
  }
}
