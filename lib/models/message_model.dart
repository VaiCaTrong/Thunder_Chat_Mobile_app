class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final MessageType type;
  final List<String>? attachments;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isOwn; // Whether message is sent by current user
  final String? senderName; // Sender's display name

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    this.type = MessageType.text,
    this.attachments,
    this.isRead = false,
    required this.createdAt,
    this.updatedAt,
    this.isOwn = false,
    this.senderName,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    // Handle senderId - can be String or Object
    String senderId = '';
    String? senderName;
    
    if (json['senderId'] != null) {
      if (json['senderId'] is String) {
        senderId = json['senderId'];
      } else if (json['senderId'] is Map) {
        final senderMap = json['senderId'] as Map<String, dynamic>;
        senderId = senderMap['_id']?.toString() ?? '';
        senderName = senderMap['displayName'];
      }
    }
    
    return Message(
      id: json['_id'] ?? json['id'] ?? '',
      conversationId: json['conversationId'] ?? '',
      senderId: senderId,
      content: json['content'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.toString().split('.').last == (json['type'] ?? 'text'),
        orElse: () => MessageType.text,
      ),
      attachments: json['attachments'] != null
          ? List<String>.from(json['attachments'])
          : null,
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      isOwn: json['isOwn'] ?? false,
      senderName: senderName ?? json['senderName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'content': content,
      'type': type.toString().split('.').last,
      'attachments': attachments,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Message copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? content,
    MessageType? type,
    List<String>? attachments,
    bool? isRead,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isOwn,
    String? senderName,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      type: type ?? this.type,
      attachments: attachments ?? this.attachments,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isOwn: isOwn ?? this.isOwn,
      senderName: senderName ?? this.senderName,
    );
  }
}

enum MessageType {
  text,
  image,
  audio,
  video,
  file,
}
