import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../config/api_config.dart';
import 'api_service.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  
  IO.Socket? _socket;
  final ApiService _apiService = ApiService();
  
  SocketService._internal();
  
  IO.Socket? get socket => _socket;
  bool get isConnected => _socket?.connected ?? false;
  
  Future<void> connect() async {
    if (_socket?.connected ?? false) {
      print('Socket already connected');
      return;
    }
    
    final token = await _apiService.getToken();
    if (token == null) {
      print('No token found, cannot connect socket');
      return;
    }
    
    _socket = IO.io(
      ApiConfig.socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );
    
    _socket?.onConnect((_) {
      print('Socket connected');
    });
    
    _socket?.onDisconnect((_) {
      print('Socket disconnected');
    });
    
    _socket?.onConnectError((error) {
      print('Socket connection error: $error');
    });
    
    _socket?.onError((error) {
      print('Socket error: $error');
    });
  }
  
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    print('Socket disconnected and disposed');
  }
  
  // Emit events
  void emit(String event, dynamic data) {
    if (_socket?.connected ?? false) {
      _socket?.emit(event, data);
    } else {
      print('Socket not connected, cannot emit event: $event');
    }
  }
  
  // Listen to events
  void on(String event, Function(dynamic) handler) {
    _socket?.on(event, handler);
  }
  
  // Remove listener
  void off(String event) {
    _socket?.off(event);
  }
  
  // Join conversation room
  void joinConversation(String conversationId) {
    emit('join_conversation', {'conversationId': conversationId});
  }
  
  // Leave conversation room
  void leaveConversation(String conversationId) {
    emit('leave_conversation', {'conversationId': conversationId});
  }
  
  // Send message
  void sendMessage(Map<String, dynamic> messageData) {
    emit('send_message', messageData);
  }
  
  // Mark message as read
  void markAsRead(String messageId) {
    emit('mark_as_read', {'messageId': messageId});
  }
  
  // Typing indicator
  void startTyping(String conversationId) {
    emit('typing_start', {'conversationId': conversationId});
  }
  
  void stopTyping(String conversationId) {
    emit('typing_stop', {'conversationId': conversationId});
  }
  
  // Emit incoming call to other participants
  void emitIncomingCall({
    required String callId,
    required String callerName,
    required String callerId,
    String? callerAvatar,
  }) {
    emit('incoming-call', {
      'callId': callId,
      'callerName': callerName,
      'callerId': callerId,
      'callerAvatar': callerAvatar,
    });
  }
}
