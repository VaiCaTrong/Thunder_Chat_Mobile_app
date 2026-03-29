import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/friend_service.dart';

class FriendProvider with ChangeNotifier {
  final FriendService _friendService = FriendService();

  List<User> _friends = [];
  List<FriendRequest> _sentRequests = [];
  List<FriendRequest> _receivedRequests = [];
  User? _searchedUser;
  List<User> _suggestedUsers = [];
  bool _isLoading = false;
  String? _error;

  List<User> get friends => _friends;
  List<FriendRequest> get sentRequests => _sentRequests;
  List<FriendRequest> get receivedRequests => _receivedRequests;
  User? get searchedUser => _searchedUser;
  List<User> get suggestedUsers => _suggestedUsers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load friends list
  Future<void> loadFriends() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('Loading friends...');
      _friends = await _friendService.getFriendList();
      print('Loaded ${_friends.length} friends');
      _error = null;
    } catch (e) {
      _error = 'Failed to load friends: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load friend requests
  Future<void> loadFriendRequests() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final requests = await _friendService.getAllFriendRequests();
      if (requests != null) {
        _sentRequests = requests['sent'] ?? [];
        _receivedRequests = requests['receive'] ?? [];
        _error = null;
      }
    } catch (e) {
      _error = 'Failed to load friend requests: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search user by username
  Future<bool> searchUser(String username) async {
    _isLoading = true;
    _error = null;
    _searchedUser = null;
    notifyListeners();

    try {
      _searchedUser = await _friendService.searchByUsername(username);
      _error = _searchedUser == null ? 'User not found' : null;
      return _searchedUser != null;
    } catch (e) {
      _error = 'Search failed: $e';
      print(_error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Suggest users (auto-complete)
  Future<void> suggestUsers(String query) async {
    if (query.trim().length < 2) {
      _suggestedUsers = [];
      notifyListeners();
      return;
    }

    try {
      _suggestedUsers = await _friendService.suggestUsers(query);
      notifyListeners();
    } catch (e) {
      print('Suggest users error: $e');
      _suggestedUsers = [];
      notifyListeners();
    }
  }

  // Clear suggestions
  void clearSuggestions() {
    _suggestedUsers = [];
    notifyListeners();
  }

  // Clear searched user
  void clearSearchedUser() {
    _searchedUser = null;
    notifyListeners();
  }

  // Send friend request
  Future<bool> sendFriendRequest(String toUserId, {String? message}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _friendService.sendFriendRequest(toUserId, message: message);
      if (result != null) {
        _error = null;
        // Reload requests to update UI
        await loadFriendRequests();
        return true;
      } else {
        _error = 'Failed to send friend request';
        return false;
      }
    } catch (e) {
      _error = 'Failed to send friend request: $e';
      print(_error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Accept friend request
  Future<bool> acceptRequest(String requestId) async {
    _error = null;

    try {
      final user = await _friendService.acceptRequest(requestId);
      if (user != null) {
        _error = null;
        // Immediately remove from received requests
        _receivedRequests.removeWhere((r) => r.id == requestId);
        // Add to friends list
        _friends.add(user);
        notifyListeners();
        
        // Reload in background
        loadFriends();
        loadFriendRequests();
        return true;
      } else {
        _error = 'Failed to accept friend request';
        return false;
      }
    } catch (e) {
      _error = 'Failed to accept friend request: $e';
      print(_error);
      return false;
    }
  }

  // Decline friend request
  Future<bool> declineRequest(String requestId) async {
    _error = null;

    try {
      final success = await _friendService.declineRequest(requestId);
      if (success) {
        _error = null;
        // Immediately remove from received requests
        _receivedRequests.removeWhere((r) => r.id == requestId);
        notifyListeners();
        
        // Reload in background
        loadFriendRequests();
        return true;
      } else {
        _error = 'Failed to decline friend request';
        return false;
      }
    } catch (e) {
      _error = 'Failed to decline friend request: $e';
      print(_error);
      return false;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
