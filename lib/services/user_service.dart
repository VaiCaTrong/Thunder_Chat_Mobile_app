import '../config/api_config.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class UserService {
  final ApiService _apiService = ApiService();

  // Get user profile
  Future<User?> getUserProfile(String userId) async {
    try {
      final response = await _apiService.get(
        '${ApiConfig.usersEndpoint}/$userId',
      );
      
      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      }
      
      return null;
    } catch (e) {
      print('Get user profile error: $e');
      return null;
    }
  }

  // Update user profile
  Future<User?> updateProfile({
    String? fullName,
    String? bio,
    String? avatar,
  }) async {
    try {
      final response = await _apiService.put(
        '${ApiConfig.usersEndpoint}/me',
        data: {
          if (fullName != null) 'fullName': fullName,
          if (bio != null) 'bio': bio,
          if (avatar != null) 'avatar': avatar,
        },
      );
      
      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      }
      
      return null;
    } catch (e) {
      print('Update profile error: $e');
      return null;
    }
  }

  // Search users
  Future<List<User>> searchUsers(String query) async {
    try {
      final response = await _apiService.get(
        '${ApiConfig.usersEndpoint}/search',
        queryParameters: {'q': query},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => User.fromJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      print('Search users error: $e');
      return [];
    }
  }

  // Upload avatar
  Future<String?> uploadAvatar(String filePath) async {
    try {
      // This would use multipart/form-data
      // Implementation depends on your backend endpoint
      final response = await _apiService.post(
        '${ApiConfig.usersEndpoint}/avatar',
        data: {
          'avatar': filePath,
        },
      );
      
      if (response.statusCode == 200) {
        return response.data['avatarUrl'];
      }
      
      return null;
    } catch (e) {
      print('Upload avatar error: $e');
      return null;
    }
  }
}
