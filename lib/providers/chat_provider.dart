import 'package:flutter/material.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import '../services/chat_service.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();
  
  List<Conversation> _conversations = [];
  Map<String, _MessageState> _messages = {};
  String? _activeConversationId;
  bool _convoLoading = false;
  bool _messageLoading = false;
  bool _loading = false;
  String? _error;
  User? _currentUser;

  List<Conversation> get conversations => _conversations;
  Map<String, _MessageState> get messages => _messages;
  String? get activeConversationId => _activeConversationId;
  bool get isLoading => _convoLoading || _messageLoading || _loading;
  bool get convoLoading => _convoLoading;
  bool get messageLoading => _messageLoading;
  String? get error => _error;
  User? get currentUser => _currentUser;

  void setCurrentUser(User? user) {
    _currentUser = user;
  }

  void setActiveConversation(String? id) {
    _activeConversationId = id;
    notifyListeners();
  }

  void reset() {
    _conversations = [];
    _messages = {};
    _activeConversationId = null;
    _convoLoading = false;
    _messageLoading = false;
    _loading = false;
    _error = null;
    notifyListeners();
  }

  // Fetch conversations
  Future<void> fetchConversations() async {
    try {
      _convoLoading = true;
      notifyListeners();

      _conversations = await _chatService.fetchConversations();
      _error = null;
    } catch (e) {
      _error = 'Failed to fetch conversations: $e';
      print(_error);
    } finally {
      _convoLoading = false;
      notifyListeners();
    }
  }

  // Fetch messages for a conversation
  Future<void> fetchMessages(String? conversationId) async {
    final convoId = conversationId ?? _activeConversationId;
    if (convoId == null) return;

    final current = _messages[convoId];
    final nextCursor = current?.nextCursor;
    
    // If nextCursor is null, we've loaded all messages
    if (nextCursor == null && current != null) return;

    _messageLoading = true;
    notifyListeners();

    try {
      final result = await _chatService.fetchMessages(convoId, cursor: nextCursor);
      final List<Message> fetched = result['messages'];
      final String? cursor = result['nextCursor'];

      // Mark messages as own if sent by current user
      final processed = fetched.map((m) {
        return m.copyWith(isOwn: m.senderId == _currentUser?.id);
      }).toList();

      final prev = _messages[convoId]?.items ?? [];
      final merged = prev.isNotEmpty ? [...processed, ...prev] : processed;

      _messages[convoId] = _MessageState(
        items: merged,
        hasMore: cursor != null,
        nextCursor: cursor,
      );

      _error = null;
    } catch (e) {
      _error = 'Failed to fetch messages: $e';
      print(_error);
    } finally {
      _messageLoading = false;
      notifyListeners();
    }
  }

  // Send direct message
  Future<void> sendDirectMessage({
    required String recipientId,
    String content = '',
    String? imgUrl,
  }) async {
    try {
      await _chatService.sendDirectMessage(
        recipientId: recipientId,
        content: content,
        imgUrl: imgUrl,
        conversationId: _activeConversationId,
      );

      // Update conversation seenBy
      if (_activeConversationId != null) {
        _updateConversationSeenBy(_activeConversationId!, []);
      }

      _error = null;
    } catch (e) {
      _error = 'Failed to send message: $e';
      print(_error);
      notifyListeners();
    }
  }

  // Send group message
  Future<void> sendGroupMessage({
    required String conversationId,
    String content = '',
    String? imgUrl,
  }) async {
    try {
      await _chatService.sendGroupMessage(
        conversationId: conversationId,
        content: content,
        imgUrl: imgUrl,
      );

      // Update conversation seenBy
      _updateConversationSeenBy(conversationId, []);

      _error = null;
    } catch (e) {
      _error = 'Failed to send message: $e';
      print(_error);
      notifyListeners();
    }
  }

  // Add message (from socket)
  Future<void> addMessage(Message message) async {
    try {
      message = message.copyWith(isOwn: message.senderId == _currentUser?.id);
      final convoId = message.conversationId;

      var prevItems = _messages[convoId]?.items ?? [];
      
      // If no messages loaded yet, fetch them
      if (prevItems.isEmpty) {
        await fetchMessages(convoId);
        prevItems = _messages[convoId]?.items ?? [];
      }

      // Check if message already exists by ID
      if (prevItems.any((m) => m.id == message.id)) {
        print('Message ${message.id} already exists, skipping duplicate');
        return;
      }

      // Additional check: same sender, content, and within 1 second (in case ID is different)
      final isDuplicate = prevItems.any((m) => 
        m.senderId == message.senderId &&
        m.content == message.content &&
        m.createdAt.difference(message.createdAt).abs().inSeconds < 2
      );

      if (isDuplicate) {
        print('Duplicate message detected by content/time, skipping');
        return;
      }

      final currentState = _messages[convoId];
      _messages[convoId] = _MessageState(
        items: [...prevItems, message],
        hasMore: currentState?.hasMore ?? false,
        nextCursor: currentState?.nextCursor,
      );

      print('Added message ${message.id} to conversation $convoId. Total messages: ${_messages[convoId]?.items.length}');
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add message: $e';
      print(_error);
    }
  }

  // Update conversation
  void updateConversation(Map<String, dynamic> updates) {
    final id = updates['_id'];
    if (id == null) return;

    final index = _conversations.indexWhere((c) => c.id == id);
    if (index == -1) return;

    final current = _conversations[index];
    
    // Parse unreadCount for current user
    int? newUnreadCount;
    if (updates['unreadCounts'] != null && _currentUser != null) {
      final unreadCounts = updates['unreadCounts'] as Map;
      newUnreadCount = unreadCounts[_currentUser!.id] ?? 0;
    }
    
    _conversations[index] = current.copyWith(
      lastMessage: updates['lastMessage'] != null 
          ? Message.fromJson(updates['lastMessage']) 
          : current.lastMessage,
      unreadCount: newUnreadCount ?? current.unreadCount,
    );

    print('Updated conversation ${id}: unreadCount=${_conversations[index].unreadCount}');
    notifyListeners();
  }

  // Mark as seen
  Future<void> markAsSeen() async {
    try {
      if (_activeConversationId == null || _currentUser == null) return;

      final convo = _conversations.firstWhere(
        (c) => c.id == _activeConversationId,
        orElse: () => _conversations.first,
      );

      if (convo.unreadCount == 0) return;

      await _chatService.markAsSeen(_activeConversationId!);

      // Update local state
      final index = _conversations.indexWhere((c) => c.id == _activeConversationId);
      if (index != -1) {
        _conversations[index] = _conversations[index].copyWith(unreadCount: 0);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to mark as seen: $e';
      print(_error);
    }
  }

  // Add conversation
  void addConvo(Conversation convo) {
    final exists = _conversations.any((c) => c.id == convo.id);
    if (!exists) {
      _conversations = [convo, ..._conversations];
      _activeConversationId = convo.id;
      print('Added new conversation: ${convo.id}');
      notifyListeners();
    } else {
      print('Conversation ${convo.id} already exists');
    }
  }

  // Create conversation
  Future<Conversation?> createConversation({
    required String type,
    required String name,
    required List<String> memberIds,
  }) async {
    try {
      print('Creating conversation: type=$type, name=$name, memberIds=$memberIds');
      _loading = true;
      _error = null;
      notifyListeners();

      // Check if direct conversation already exists
      if (type == 'direct' && memberIds.length == 1) {
        final existingConvo = _conversations.firstWhere(
          (c) => !c.isGroup && 
                 c.participants.contains(memberIds[0]),
          orElse: () => Conversation(
            id: '',
            name: '',
            isGroup: false,
            participants: [],
            createdAt: DateTime.now(),
          ),
        );
        
        if (existingConvo.id.isNotEmpty) {
          print('Found existing conversation: ${existingConvo.id}');
          _loading = false;
          notifyListeners();
          return existingConvo;
        }
      }

      print('Calling API to create conversation...');
      final conversation = await _chatService.createConversation(
        type: type,
        name: name,
        memberIds: memberIds,
      );

      if (conversation != null) {
        print('Conversation created: ${conversation.id}');
        addConvo(conversation);
        _error = null;
      } else {
        print('Failed to create conversation - API returned null');
        _error = 'Không thể tạo cuộc trò chuyện. Vui lòng kiểm tra kết nối hoặc quyền truy cập.';
      }

      return conversation;
    } catch (e) {
      _error = 'Lỗi khi tạo cuộc trò chuyện: $e';
      print(_error);
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void _updateConversationSeenBy(String conversationId, List<String> seenBy) {
    final index = _conversations.indexWhere((c) => c.id == conversationId);
    if (index != -1) {
      // Update seenBy logic here if needed
      notifyListeners();
    }
  }

  List<Message> getConversationMessages(String conversationId) {
    return _messages[conversationId]?.items ?? [];
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

class _MessageState {
  final List<Message> items;
  final bool hasMore;
  final String? nextCursor;

  _MessageState({
    required this.items,
    required this.hasMore,
    this.nextCursor,
  });
}
