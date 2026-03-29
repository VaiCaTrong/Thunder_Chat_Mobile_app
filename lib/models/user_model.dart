class User {
  final String id;
  final String username;
  final String email;
  final String? fullName;
  final String? avatar;
  final String? bio;
  final bool isOnline;
  final DateTime? lastSeen;
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.fullName,
    this.avatar,
    this.bio,
    this.isOnline = false,
    this.lastSeen,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '', // Default to empty string if not provided
      fullName: json['fullName'] ?? json['displayName'],
      avatar: json['avatar'] ?? json['avatarUrl'],
      bio: json['bio'],
      isOnline: json['isOnline'] ?? false,
      lastSeen: json['lastSeen'] != null 
          ? DateTime.parse(json['lastSeen']) 
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'email': email,
      'fullName': fullName,
      'avatar': avatar,
      'bio': bio,
      'isOnline': isOnline,
      'lastSeen': lastSeen?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? fullName,
    String? avatar,
    String? bio,
    bool? isOnline,
    DateTime? lastSeen,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
