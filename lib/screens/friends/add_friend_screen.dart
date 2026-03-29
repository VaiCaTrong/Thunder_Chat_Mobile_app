import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/friend_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import 'friend_requests_screen.dart';

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onFocusChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    final friendProvider = Provider.of<FriendProvider>(context, listen: false);
    
    if (query.length >= 2) {
      friendProvider.suggestUsers(query);
      setState(() {
        _showSuggestions = true;
      });
    } else {
      friendProvider.clearSuggestions();
      setState(() {
        _showSuggestions = false;
      });
    }
  }

  void _onFocusChanged() {
    if (!_searchFocusNode.hasFocus) {
      // Delay hiding suggestions to allow tap on suggestion items
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() {
            _showSuggestions = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _messageController.dispose();
    _searchFocusNode.removeListener(_onFocusChanged);
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSearch() async {
    final username = _searchController.text.trim();
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a username')),
      );
      return;
    }

    final friendProvider = Provider.of<FriendProvider>(context, listen: false);
    await friendProvider.searchUser(username);

    setState(() {
      _showSuggestions = false;
    });

    if (friendProvider.error != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(friendProvider.error!)),
        );
      }
    }
  }

  void _selectSuggestion(User user) {
    _searchController.text = user.username;
    setState(() {
      _showSuggestions = false;
    });
    _handleSearch();
  }

  Future<void> _handleSendRequest(String toUserId) async {
    final message = _messageController.text.trim();
    final friendProvider = Provider.of<FriendProvider>(context, listen: false);
    
    final success = await friendProvider.sendFriendRequest(
      toUserId,
      message: message.isNotEmpty ? message : null,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Friend request sent!')),
        );
        _messageController.clear();
        friendProvider.clearSearchedUser();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(friendProvider.error ?? 'Failed to send request'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;

    return Consumer<FriendProvider>(
      builder: (context, friendProvider, child) {
        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          appBar: AppBar(
            backgroundColor: theme.colorScheme.surface,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'Solaris',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const FriendRequestsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    'Add Friends',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Connect with people in the Solaris universe',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Search Section
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              decoration: InputDecoration(
                                hintText: 'Find by username',
                                prefixIcon: Icon(
                                  Icons.person_search,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          _searchController.clear();
                                          friendProvider.clearSearchedUser();
                                          friendProvider.clearSuggestions();
                                        },
                                      )
                                    : null,
                              ),
                              onSubmitted: (_) => _handleSearch(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: friendProvider.isLoading ? null : _handleSearch,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 20,
                              ),
                            ),
                            child: friendProvider.isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Search'),
                          ),
                        ],
                      ),
                      
                      // Suggestions dropdown
                      if (_showSuggestions && friendProvider.suggestedUsers.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.colorScheme.outlineVariant,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          constraints: const BoxConstraints(maxHeight: 300),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: friendProvider.suggestedUsers.length,
                            itemBuilder: (context, index) {
                              final user = friendProvider.suggestedUsers[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: theme.colorScheme.primaryContainer,
                                  backgroundImage: user.avatar != null
                                      ? NetworkImage(user.avatar!)
                                      : null,
                                  child: user.avatar == null
                                      ? Icon(
                                          Icons.person,
                                          color: theme.colorScheme.onPrimaryContainer,
                                        )
                                      : null,
                                ),
                                title: Text(
                                  user.fullName ?? user.username,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text('@${user.username}'),
                                onTap: () => _selectSuggestion(user),
                              );
                            },
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Search Result
                  if (friendProvider.searchedUser != null)
                    _buildSearchResult(
                      friendProvider.searchedUser!,
                      currentUser,
                      theme,
                    ),

                  const SizedBox(height: 40),

                  // Features Grid
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 600;
                      
                      if (isWide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildNearbyCard(theme)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildInviteCard(theme)),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            _buildNearbyCard(theme),
                            const SizedBox(height: 16),
                            _buildInviteCard(theme),
                          ],
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 40),

                  // Suggested Friends
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Suggested for you',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('See All'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Empty state - no suggestions
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No suggestions yet',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Search for friends to connect',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchResult(dynamic user, dynamic currentUser, ThemeData theme) {
    final isCurrentUser = user.id == currentUser?.id;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: user.avatar != null
                    ? ClipOval(
                        child: Image.network(
                          user.avatar!,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.person,
                            size: 32,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.person,
                        size: 32,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName ?? user.username,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '@${user.username}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!isCurrentUser) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Add a message (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _handleSendRequest(user.id),
                icon: const Icon(Icons.person_add),
                label: const Text('Send Friend Request'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This is you!',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, ThemeData theme) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.onPrimary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: theme.colorScheme.onPrimary,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildNearbyCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_on,
              color: theme.colorScheme.onPrimaryContainer,
              size: 28,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Nearby',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Discover users broadcasting their location in your immediate vicinity.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                // TODO: Implement nearby scan
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Start Scanning'),
                  Icon(
                    Icons.arrow_forward,
                    size: 20,
                    color: theme.colorScheme.onSurface,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInviteCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: theme.colorScheme.onPrimary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.celebration,
              color: theme.colorScheme.onPrimary,
              size: 28,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Invite Friends',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Share the Solaris experience with your inner circle across other platforms.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimary.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildSocialButton(Icons.facebook, theme),
              const SizedBox(width: 8),
              _buildSocialButton(Icons.share, theme),
              const SizedBox(width: 8),
              _buildSocialButton(Icons.chat, theme),
              const SizedBox(width: 8),
              _buildSocialButton(Icons.more_horiz, theme),
            ],
          ),
        ],
      ),
    );
  }
}
