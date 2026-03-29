import '../config/api_config.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import 'api_service.dart';

class ChatService {
  final ApiService _apiService = ApiService();
  static const int pageLimit = 50;

  // Fetch all conversations
  Future<List<Conversation>> fetchConversations() async {
    try {
      final response = await _apiService.get(ApiConfig.conversationsEndpoint);
      
      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> conversations = data['conversations'] ?? data;
        
        // Get current user ID from auth service
        final authResponse = await _apiService.get(ApiConfig.usersMeEndpoint);
        final currentUserId = authResponse.data['_id']?.toString();
        
        print('=== Fetching conversations ===');
        print('Current user ID: $currentUserId');
        print('Number of conversations: ${conversations.length}');
        
        final parsedConversations = conversations.map((json) {
          final conv = Conversation.fromJson(json, currentUserId: currentUserId);
          print('Conversation ${conv.id}: unreadCount=${conv.unreadCount}, unreadCounts=${json['unreadCounts']}');
          return conv;
        }).toList();
        
        return parsedConversations;
      }
      
      return [];
    } catch (e) {
      print('Fetch conversations error: $e');
      return [];
    }
  }

  // Fetch messages for a conversation with pagination
  Future<Map<String, dynamic>> fetchMessages(String conversationId, {String? cursor}) async {
    try {
      final cursorParam = cursor ?? '';
      final response = await _apiService.get(
        '${ApiConfig.conversationsEndpoint}/$conversationId/messages?limit=$pageLimit&cursor=$cursorParam',
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> messagesData = data['messages'] ?? [];
        final messages = messagesData.map((json) => Message.fromJson(json)).toList();
        
        return {
          'messages': messages,
          'nextCursor': data['nextCursor'],
        };
      }
      
      return {'messages': [], 'nextCursor': null};
    } catch (e) {
      print('Fetch messages error: $e');
      return {'messages': [], 'nextCursor': null};
    }
  }

  // Send direct message (1-1 chat)
  Future<Message?> sendDirectMessage({
    required String recipientId,
    String content = '',
    String? imgUrl,
    String? conversationId,
  }) async {
    try {
      final response = await _apiService.post(
        '${ApiConfig.messagesEndpoint}/direct',
        data: {
          'recipientId': recipientId,
          'content': content,
          if (imgUrl != null) 'imgUrl': imgUrl,
          if (conversationId != null) 'conversationId': conversationId,
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Message.fromJson(response.data['message']);
      }
      
      return null;
    } catch (e) {
      print('Send direct message error: $e');
      return null;
    }
  }

  // Send group message
  Future<Message?> sendGroupMessage({
    required String conversationId,
    String content = '',
    String? imgUrl,
  }) async {
    try {
      final response = await _apiService.post(
        '${ApiConfig.messagesEndpoint}/group',
        data: {
          'conversationId': conversationId,
          'content': content,
          if (imgUrl != null) 'imgUrl': imgUrl,
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Message.fromJson(response.data['message']);
      }
      
      return null;
    } catch (e) {
      print('Send group message error: $e');
      return null;
    }
  }

  // Mark conversation as seen
  Future<bool> markAsSeen(String conversationId) async {
    try {
      final response = await _apiService.patch(
        '${ApiConfig.conversationsEndpoint}/$conversationId/seen',
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Mark as seen error: $e');
      return false;
    }
  }

  // Create conversation
  Future<Conversation?> createConversation({
    required String type, // 'direct' or 'group'
    required String name,
    required List<String> memberIds,
  }) async {
    try {
      print('=== ChatService: Creating conversation ===');
      print('Type: $type');
      print('Name: $name');
      print('MemberIds: $memberIds');
      
      final requestData = {
        'type': type,
        'name': name,
        'memberIds': memberIds,
      };
      print('Request data: $requestData');
      
      final response = await _apiService.post(
        ApiConfig.conversationsEndpoint,
        data: requestData,
      );
      
      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data == null || response.data is! Map) {
          print('ERROR: Invalid response data');
          return null;
        }
        
        final dataMap = response.data as Map<String, dynamic>;
        
        if (!dataMap.containsKey('conversation') || dataMap['conversation'] == null) {
          print('ERROR: No conversation in response');
          return null;
        }
        
        // Get current user ID
        final authResponse = await _apiService.get(ApiConfig.usersMeEndpoint);
        final currentUserId = authResponse.data['_id']?.toString();
        
        print('Parsing conversation with currentUserId: $currentUserId');
        final conversation = Conversation.fromJson(dataMap['conversation'], currentUserId: currentUserId);
        print('SUCCESS: Parsed conversation ID: ${conversation.id}');
        return conversation;
      }
      
      print('ERROR: Unexpected status code ${response.statusCode}');
      return null;
    } catch (e, stackTrace) {
      print('=== ChatService ERROR ===');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }
}
