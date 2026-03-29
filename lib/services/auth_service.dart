import '../config/api_config.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  // Sign In
  Future<Map<String, dynamic>> signIn(String username, String password) async {
    try {
      final response = await _apiService.post(
        '${ApiConfig.authEndpoint}/signin',
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Check if data is valid
        if (data == null) {
          return {
            'success': false,
            'message': 'Invalid response from server',
          };
        }
        
        // Backend returns {accessToken: "..."}
        final token = data['accessToken'];
        if (token == null) {
          return {
            'success': false,
            'message': 'No access token received',
          };
        }
        
        await _apiService.saveToken(token);
        
        // Fetch user info after login
        final user = await getCurrentUser();
        
        if (user == null) {
          return {
            'success': false,
            'message': 'Failed to fetch user info',
          };
        }
        
        return {
          'success': true,
          'user': user,
          'token': token,
        };
      }
      
      return {
        'success': false,
        'message': response.data?['message'] ?? 'Login failed',
      };
    } catch (e) {
      print('Sign in error: $e');
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()}',
      };
    }
  }

  // Sign Up
  Future<Map<String, dynamic>> signUp({
    required String username,
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      // Split fullName into firstName and lastName
      // Vietnamese format: Họ Tên Đệm Tên
      // Example: "Nguyễn Văn An" -> lastName="Nguyễn", firstName="Văn An"
      String firstName = '';
      String lastName = '';
      
      if (fullName != null && fullName.isNotEmpty) {
        final parts = fullName.trim().split(RegExp(r'\s+'));
        if (parts.length >= 2) {
          // First part is last name (họ)
          lastName = parts.first;
          // Rest is first name (tên đệm + tên)
          firstName = parts.sublist(1).join(' ');
        } else if (parts.length == 1) {
          // Only one word - use it as both
          lastName = parts.first;
          firstName = parts.first;
        }
      }
      
      // Ensure both are not empty
      if (firstName.isEmpty) firstName = username;
      if (lastName.isEmpty) lastName = username;
      
      print('Signup data: username=$username, email=$email, firstName=$firstName, lastName=$lastName');
      
      final response = await _apiService.post(
        '${ApiConfig.authEndpoint}/signup',
        data: {
          'username': username,
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
        },
      );

      print('Signup response status: ${response.statusCode}');
      print('Signup response data: ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200 || response.statusCode == 204) {
        // Signup successful, now login to get token
        print('Signup successful, logging in...');
        return await signIn(username, password);
      }
      
      return {
        'success': false,
        'message': response.data?['message'] ?? 'Registration failed',
      };
    } catch (e) {
      print('Sign up error: $e');
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()}',
      };
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _apiService.post('${ApiConfig.authEndpoint}/signout');
    } catch (e) {
      print('Sign out error: $e');
    } finally {
      await _apiService.clearToken();
    }
  }

  // Refresh Token
  Future<bool> refreshToken() async {
    try {
      final response = await _apiService.post('${ApiConfig.authEndpoint}/refresh');
      
      if (response.statusCode == 200) {
        final token = response.data['accessToken'];
        await _apiService.saveToken(token);
        return true;
      }
      
      return false;
    } catch (e) {
      print('Refresh token error: $e');
      return false;
    }
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _apiService.getToken();
    return token != null && token.isNotEmpty;
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    try {
      final response = await _apiService.get('${ApiConfig.usersEndpoint}/me');
      
      print('=== getCurrentUser DEBUG ===');
      print('Status: ${response.statusCode}');
      print('Raw response data: ${response.data}');
      print('Response type: ${response.data.runtimeType}');
      
      if (response.statusCode == 200) {
        // Backend returns {user: {...}}
        final userData = response.data['user'] ?? response.data;
        print('User data to parse: $userData');
        
        final user = User.fromJson(userData);
        print('Parsed user: username=${user.username}, email=${user.email}');
        return user;
      }
      
      return null;
    } catch (e, stackTrace) {
      print('Get current user error: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }
}
