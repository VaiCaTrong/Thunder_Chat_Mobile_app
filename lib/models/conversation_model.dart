import 'user_model.dart';
import 'message_model.dart';

class Conversation {
  final String id;
  final String name;
  final bool isGroup;
  final List<String> participants;
  final Message? lastMessage;
  final int unreadCount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  // Populated fields
  final List<User>? participantDetails;

  Conversation({
    required this.id,
    required this.name,
    this.isGroup = false,
    required this.participants,
    this.lastMessage,
    this.unreadCount = 0,
    required this.createdAt,
    this.updatedAt,
    this.participantDetails,
  });

  factory Conversation.fromJson(Map<String, dynamic> json, {String? currentUserId}) {
    // Parse participants - handle both String IDs and populated User objects
    List<String> participantIds = [];
    List<User>? participantDetailsList;
    
    try {
      if (json['participants'] != null) {
        final participants = json['participants'] as List;
        
        // Check if participants are objects or strings
        if (participants.isNotEmpty) {
          if (participants.first is Map) {
            // Participants are objects with user details
            participantDetailsList = [];
            for (var p in participants) {
              try {
                final pMap = p as Map<String, dynamic>;
                participantDetailsList.add(User.fromJson({
                  '_id': pMap['_id'],
                  'username': pMap['username'] ?? '',
                  'fullName': pMap['displayName'],
                  'avatarUrl': pMap['avatarUrl'],
                  'email': '', // Not provided in this context
                  'createdAt': DateTime.now().toIso8601String(),
                }));
                
                // Extract ID
                final id = pMap['_id']?.toString() ?? '';
                if (id.isNotEmpty) {
                  participantIds.add(id);
                }
              } catch (e) {
                print('Error parsing participant: $e');
              }
            }
          } else {
            // Participants are just IDs
            participantIds = participants
                .map((p) => p.toString())
                .where((id) => id.isNotEmpty)
                .toList();
          }
        }
      }
    } catch (e) {
      print('Error parsing participants: $e');
    }

    // Determine conversation name
    String conversationName = json['name'] ?? '';
    
    // For direct conversations without a name, use the other participant's name
    if (conversationName.isEmpty && json['type'] == 'direct' && participantDetailsList != null && participantDetailsList.isNotEmpty) {
      conversationName = participantDetailsList.first.fullName ?? participantDetailsList.first.username;
    }
    
    // For group conversations, use group name
    if (json['type'] == 'group' && json['group'] != null) {
      conversationName = json['group']['name'] ?? conversationName;
    }

    // Parse unreadCount - get count for current user only
    int unreadCount = 0;
    if (json['unreadCounts'] is Map && currentUserId != null) {
      final unreadCounts = json['unreadCounts'] as Map;
      unreadCount = unreadCounts[currentUserId] ?? 0;
    } else if (json['unreadCount'] != null) {
      unreadCount = json['unreadCount'] as int;
    }

    return Conversation(
      id: json['_id'] ?? json['id'] ?? '',
      name: conversationName,
      isGroup: json['type'] == 'group' || json['isGroup'] == true,
      participants: participantIds,
      lastMessage: json['lastMessage'] != null
          ? Message.fromJson(json['lastMessage'])
          : null,
      unreadCount: unreadCount,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      participantDetails: participantDetailsList ?? 
          (json['participantDetails'] != null
              ? (json['participantDetails'] as List)
                  .map((u) => User.fromJson(u))
                  .toList()
              : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'isGroup': isGroup,
      'participants': participants,
      'lastMessage': lastMessage?.toJson(),
      'unreadCount': unreadCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Conversation copyWith({
    String? id,
    String? name,
    bool? isGroup,
    List<String>? participants,
    Message? lastMessage,
    int? unreadCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<User>? participantDetails,
  }) {
    return Conversation(
      id: id ?? this.id,
      name: name ?? this.name,
      isGroup: isGroup ?? this.isGroup,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      participantDetails: participantDetails ?? this.participantDetails,
    );
  }

  // Get display name for direct conversation (other participant's name)
  String getDisplayName(String currentUserId) {
    // For group chats, return the group name
    if (isGroup) {
      return name;
    }
    
    // For direct chats, find the other participant
    if (participantDetails != null && participantDetails!.isNotEmpty) {
      final otherUser = participantDetails!.firstWhere(
        (user) => user.id != currentUserId,
        orElse: () => participantDetails!.first,
      );
      return otherUser.fullName ?? otherUser.username;
    }
    
    // Fallback to conversation name
    return name;
  }

  // Get other participant in direct conversation
  User? getOtherParticipant(String currentUserId) {
    if (isGroup || participantDetails == null) return null;
    
    try {
      return participantDetails!.firstWhere(
        (user) => user.id != currentUserId,
      );
    } catch (e) {
      return null;
    }
  }
}
