import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../models/conversation_model.dart';
import '../services/socket_service.dart';
import 'chat_provider.dart';
import 'notification_provider.dart';

class SocketProvider with ChangeNotifier {
  final SocketService _socketService = SocketService();
  List<String> _onlineUsers = [];
  ChatProvider? _chatProvider;
  NotificationProvider? _notificationProvider;
  Map<String, dynamic>? _pendingCallData;

  List<String> get onlineUsers => _onlineUsers;
  bool get isConnected => _socketService.isConnected;
  SocketService get socketService => _socketService;
  Map<String, dynamic>? get pendingCallData => _pendingCallData;

  void setChatProvider(ChatProvider chatProvider) {
    _chatProvider = chatProvider;
  }

  void setNotificationProvider(NotificationProvider notificationProvider) {
    _notificationProvider = notificationProvider;
  }

  Future<void> connectSocket() async {
    if (_socketService.isConnected) {
      print('Socket already connected');
      return;
    }

    await _socketService.connect();
    _setupListeners();
    notifyListeners();
  }

  void disconnectSocket() {
    _socketService.disconnect();
    _onlineUsers = [];
    notifyListeners();
  }

  void _setupListeners() {
    // Listen for online users
    _socketService.on('online-users', (data) {
      if (data is List) {
        _onlineUsers = data.cast<String>();
        notifyListeners();
      }
    });

    // Listen for incoming call
    _socketService.on('incoming-call', (data) {
      print('=== Socket: Received incoming-call event ===');
      print('Data: $data');
      
      if (_notificationProvider == null) {
        print('ERROR: NotificationProvider is null');
        return;
      }

      try {
        final callerName = data['callerName'] ?? 'Someone';
        final callId = data['callId'] ?? '';
        final callerId = data['callerId'] ?? '';
        final callerAvatar = data['callerAvatar'];
        
        print('Caller name: $callerName');
        print('Call ID: $callId');
        print('Caller ID: $callerId');
        print('Caller avatar: $callerAvatar');
        
        if (callId.isNotEmpty) {
          print('Showing call notification...');
          _notificationProvider!.showCallNotification(
            callerName: callerName,
            callId: callId,
            callerAvatar: callerAvatar,
          );
          
          // Store call data for later use
          _pendingCallData = {
            'callId': callId,
            'callerName': callerName,
            'callerId': callerId,
            'callerAvatar': callerAvatar,
          };
          notifyListeners();
        } else {
          print('ERROR: Call ID is empty');
        }
      } catch (e, stackTrace) {
        print('Error handling incoming-call: $e');
        print('Stack trace: $stackTrace');
      }
    });

    // Listen for call cancelled
    _socketService.on('call-cancelled', (data) {
      print('=== Socket: Received call-cancelled event ===');
      print('Data: $data');
      _pendingCallData = null;
      notifyListeners();
    });

    // Listen for new messages
    _socketService.on('new-message', (data) {
      print('=== Socket: Received new-message event ===');
      print('Data: $data');
      
      if (_chatProvider == null) {
        print('ERROR: ChatProvider is null');
        return;
      }

      try {
        final message = data['message'];
        final conversation = data['conversation'];
        final unreadCounts = data['unreadCounts'];

        // Add message to chat provider
        if (message != null) {
          print('Adding message to chat provider: ${message['_id']}');
          final newMessage = Message.fromJson(message);
          _chatProvider!.addMessage(newMessage);
          
          // Show notification if message is not from current user
          final currentUserId = _chatProvider!.currentUser?.id;
          final isActiveConversation = _chatProvider!.activeConversationId == newMessage.conversationId;
          
          print('Current user ID: $currentUserId');
          print('Message sender ID: ${newMessage.senderId}');
          print('Is active conversation: $isActiveConversation');
          
          if (newMessage.senderId != currentUserId && _notificationProvider != null) {
            // Only show notification if not viewing this conversation
            if (!isActiveConversation) {
              print('Showing notification for new message');
              final senderName = newMessage.senderName ?? 'Someone';
              final conversationId = newMessage.conversationId;
              
              _notificationProvider!.showMessageNotification(
                senderName: senderName,
                message: newMessage.content,
                conversationId: conversationId,
              );
            } else {
              print('Skipping notification - conversation is active');
            }
          } else {
            print('Skipping notification - message from current user or notification provider is null');
          }
        } else {
          print('WARNING: No message in event data');
        }

        // Update conversation
        if (conversation != null) {
          final lastMessage = conversation['lastMessage'];
          _chatProvider!.updateConversation({
            '_id': conversation['_id'],
            'lastMessage': lastMessage,
            'lastMessageAt': conversation['lastMessageAt'],
            'unreadCounts': unreadCounts,
          });
        }

        // Mark as seen if conversation is active
        if (_chatProvider!.activeConversationId == message?['conversationId']) {
          print('Marking conversation as seen');
          _chatProvider!.markAsSeen();
        }
      } catch (e, stackTrace) {
        print('Error handling new-message: $e');
        print('Stack trace: $stackTrace');
      }
    });

    // Listen for read messages
    _socketService.on('read-message', (data) {
      print('=== Socket: Received read-message event ===');
      print('Data: $data');
      
      if (_chatProvider == null) {
        print('ERROR: ChatProvider is null');
        return;
      }

      try {
        final conversation = data['conversation'];
        final lastMessage = data['lastMessage'];

        if (conversation != null) {
          print('Updating conversation after read: ${conversation['_id']}');
          print('UnreadCounts: ${conversation['unreadCounts']}');
          
          _chatProvider!.updateConversation({
            '_id': conversation['_id'],
            'lastMessage': lastMessage,
            'lastMessageAt': conversation['lastMessageAt'],
            'unreadCounts': conversation['unreadCounts'],
          });
        } else {
          print('WARNING: No conversation in read-message event');
        }
      } catch (e, stackTrace) {
        print('Error handling read-message: $e');
        print('Stack trace: $stackTrace');
      }
    });

    // Listen for new group invitations
    _socketService.on('new-group', (data) {
      print('=== Socket: Received new-group event ===');
      print('Data: $data');
      
      if (_chatProvider == null) {
        print('ERROR: ChatProvider is null');
        return;
      }

      try {
        // Get current user ID from chat provider
        final currentUserId = _chatProvider!.currentUser?.id;
        
        final conversation = Conversation.fromJson(data, currentUserId: currentUserId);
        _chatProvider!.addConvo(conversation);
        
        // Join the conversation room
        _socketService.joinConversation(conversation.id);
        print('Joined new group conversation: ${conversation.id}');
      } catch (e, stackTrace) {
        print('Error handling new-group: $e');
        print('Stack trace: $stackTrace');
      }
    });

    // Listen for typing indicators
    _socketService.on('typing-start', (data) {
      // Handle typing indicator
      notifyListeners();
    });

    _socketService.on('typing-stop', (data) {
      // Handle typing indicator
      notifyListeners();
    });
  }

  // Join conversation
  void joinConversation(String conversationId) {
    _socketService.joinConversation(conversationId);
  }

  // Leave conversation
  void leaveConversation(String conversationId) {
    _socketService.leaveConversation(conversationId);
  }
}
