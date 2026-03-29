import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/socket_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final SocketService _socketService = SocketService();
  
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;

  // Initialize - check if user is already logged in
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _isAuthenticated = await _authService.isAuthenticated();
      print('Auth initialized: $_isAuthenticated');
      
      if (_isAuthenticated) {
        _currentUser = await _authService.getCurrentUser();
        print('Current user loaded: ${_currentUser?.username}');
        
        if (_currentUser != null) {
          await _socketService.connect();
        } else {
          // If we have token but can't get user, token might be invalid
          print('Token exists but user fetch failed - clearing auth');
          _isAuthenticated = false;
          await _authService.signOut();
        }
      }
    } catch (e) {
      print('Initialize error: $e');
      _errorMessage = e.toString();
      _isAuthenticated = false;
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign In
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.signIn(email, password);
      
      if (result['success']) {
        _currentUser = result['user'];
        _isAuthenticated = true;
        await _socketService.connect();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign Up
  Future<bool> signUp({
    required String username,
    required String email,
    required String password,
    String? fullName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.signUp(
        username: username,
        email: email,
        password: password,
        fullName: fullName,
      );
      
      if (result['success']) {
        _currentUser = result['user'];
        _isAuthenticated = true;
        await _socketService.connect();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      _socketService.disconnect();
      _currentUser = null;
      _isAuthenticated = false;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user
  void updateUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
