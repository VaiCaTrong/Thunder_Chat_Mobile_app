import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // Backend API URL - Load from .env
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:5002/api';
  static String get socketUrl => dotenv.env['SOCKET_URL'] ?? 'http://localhost:5002';
  
  // API Endpoints
  static const String authEndpoint = '/auth';
  static const String usersEndpoint = '/users';
  static const String usersMeEndpoint = '/users/me';
  static const String messagesEndpoint = '/messages';
  static const String conversationsEndpoint = '/conversations';
  static const String friendsEndpoint = '/friends';
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
