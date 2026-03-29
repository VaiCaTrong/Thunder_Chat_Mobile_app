import '../config/api_config.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class FriendRequest {
  final String id;
  final User from;
  final User to;
  final String? message;
  final String status;
  final DateTime createdAt;

  FriendRequest({
    required this.id,
    required this.from,
    required this.to,
    this.message,
    required this.status,
    required this.createdAt,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      id: json['_id'] ?? '',
      from: User.fromJson(json['from']),
      to: User.fromJson(json['to']),
      message: json['message'],
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class FriendService {
  final ApiService _apiService = ApiService();

  // Search user by username
  Future<User?> searchByUsername(String username) async {
    try {
      final response = await _apiService.get(
        '${ApiConfig.usersEndpoint}/search?username=$username',
      );

      if (response.statusCode == 200) {
        return User.fromJson(response.data['user']);
      }

      return null;
    } catch (e) {
      print('Search user error: $e');
      return null;
    }
  }

  // Suggest users (auto-complete)
  Future<List<User>> suggestUsers(String query, {int limit = 10}) async {
    try {
      if (query.trim().length < 2) {
        return [];
      }

      final response = await _apiService.get(
        '${ApiConfig.usersEndpoint}/suggest?query=$query&limit=$limit',
      );

      if (response.statusCode == 200) {
        final users = (response.data['users'] as List?)
                ?.map((item) => User.fromJson(item))
                .toList() ??
            [];
        return users;
      }

      return [];
    } catch (e) {
      print('Suggest users error: $e');
      return [];
    }
  }

  // Send friend request
  Future<String?> sendFriendRequest(String toUserId, {String? message}) async {
    try {
      final response = await _apiService.post(
        '${ApiConfig.friendsEndpoint}/requests',
        data: {
          'to': toUserId,
          if (message != null) 'message': message,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['message'];
      }

      return null;
    } catch (e) {
      print('Send friend request error: $e');
      return null;
    }
  }

  // Get all friend requests (sent and received)
  Future<Map<String, List<FriendRequest>>?> getAllFriendRequests() async {
    try {
      final response = await _apiService.get(
        '${ApiConfig.friendsEndpoint}/requests',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final sent = (data['sent'] as List?)
                ?.map((item) => FriendRequest.fromJson(item))
                .toList() ??
            [];
        final receive = (data['receive'] as List?)
                ?.map((item) => FriendRequest.fromJson(item))
                .toList() ??
            [];

        return {
          'sent': sent,
          'receive': receive,
        };
      }

      return null;
    } catch (e) {
      print('Get friend requests error: $e');
      return null;
    }
  }

  // Accept friend request
  Future<User?> acceptRequest(String requestId) async {
    try {
      final response = await _apiService.post(
        '${ApiConfig.friendsEndpoint}/requests/$requestId/accept',
      );

      if (response.statusCode == 200) {
        return User.fromJson(response.data['requestAcceptedBy']);
      }

      return null;
    } catch (e) {
      print('Accept request error: $e');
      return null;
    }
  }

  // Decline friend request
  Future<bool> declineRequest(String requestId) async {
    try {
      final response = await _apiService.post(
        '${ApiConfig.friendsEndpoint}/requests/$requestId/decline',
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Decline request error: $e');
      return false;
    }
  }

  // Get friends list
  Future<List<User>> getFriendList() async {
    try {
      print('Calling GET ${ApiConfig.friendsEndpoint}');
      final response = await _apiService.get(
        ApiConfig.friendsEndpoint,
      );

      print('Friends response status: ${response.statusCode}');
      print('Friends response data: ${response.data}');

      if (response.statusCode == 200) {
        final friends = (response.data['friends'] as List?)
                ?.map((item) {
                  print('Parsing friend: $item');
                  return User.fromJson(item);
                })
                .toList() ??
            [];
        print('Parsed ${friends.length} friends');
        return friends;
      }

      return [];
    } catch (e) {
      print('Get friend list error: $e');
      return [];
    }
  }
}
