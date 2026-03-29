import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/friend_provider.dart';
import '../../providers/chat_provider.dart';
import '../../models/conversation_model.dart';
import 'chat_screen.dart';

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({super.key});

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedFriends = {};

  @override
  void initState() {
    super.initState();
    // Load friends
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FriendProvider>(context, listen: false).loadFriends();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _startChat() async {
    if (_selectedFriends.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one friend')),
      );
      return;
    }

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final friendProvider = Provider.of<FriendProvider>(context, listen: false);

    Conversation? conversation;

    if (_selectedFriends.length == 1) {
      // Direct message
      final friendId = _selectedFriends.first;
      final friend = friendProvider.friends.firstWhere((f) => f.id == friendId);
      
      conversation = await chatProvider.createConversation(
        type: 'direct',
        name: friend.fullName ?? friend.username,
        memberIds: [friendId],
      );
    } else {
      // Group chat
      final friendNames = _selectedFriends.map((id) {
        final friend = friendProvider.friends.firstWhere((f) => f.id == id);
        return friend.fullName ?? friend.username;
      }).take(3).join(', ');
      
      conversation = await chatProvider.createConversation(
        type: 'group',
        name: friendNames,
        memberIds: _selectedFriends.toList(),
      );
    }

    if (conversation != null && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ChatScreen(conversation: conversation!),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create conversation')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'New Chat',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          if (_selectedFriends.isNotEmpty)
            TextButton(
              onPressed: _startChat,
              child: const Text('Start'),
            ),
        ],
      ),
      body: Consumer<FriendProvider>(
        builder: (context, friendProvider, _) {
          if (friendProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final friends = friendProvider.friends;
          
          // Filter friends based on search
          final searchQuery = _searchController.text.toLowerCase();
          final filteredFriends = searchQuery.isEmpty
              ? friends
              : friends.where((friend) {
                  final name = (friend.fullName ?? friend.username).toLowerCase();
                  final username = friend.username.toLowerCase();
                  return name.contains(searchQuery) || username.contains(searchQuery);
                }).toList();

          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(24),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search friends...',
                    prefixIcon: Icon(
                      Icons.search,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),

              // Selected Friends Count
              if (_selectedFriends.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  color: theme.colorScheme.primaryContainer,
                  child: Row(
                    children: [
                      Icon(
                        Icons.people,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${_selectedFriends.length} selected',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

              // Friends List
              Expanded(
                child: friends.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64,
                              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No friends yet',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add friends to start chatting',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      )
                    : filteredFriends.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No results found',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: filteredFriends.length,
                            itemBuilder: (context, index) {
                              final friend = filteredFriends[index];
                              final isSelected = _selectedFriends.contains(friend.id);

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? theme.colorScheme.primaryContainer
                                      : theme.colorScheme.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  leading: CircleAvatar(
                                    radius: 28,
                                    backgroundColor: theme.colorScheme.primaryContainer,
                                    child: friend.avatar != null
                                        ? ClipOval(
                                            child: Image.network(
                                              friend.avatar!,
                                              width: 56,
                                              height: 56,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => Text(
                                                (friend.fullName ?? friend.username)[0].toUpperCase(),
                                                style: theme.textTheme.titleLarge,
                                              ),
                                            ),
                                          )
                                        : Text(
                                            (friend.fullName ?? friend.username)[0].toUpperCase(),
                                            style: theme.textTheme.titleLarge,
                                          ),
                                  ),
                                  title: Text(
                                    friend.fullName ?? friend.username,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '@${friend.username}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  trailing: Checkbox(
                                    value: isSelected,
                                    onChanged: (value) {
                                      setState(() {
                                        if (value == true) {
                                          _selectedFriends.add(friend.id);
                                        } else {
                                          _selectedFriends.remove(friend.id);
                                        }
                                      });
                                    },
                                  ),
                                  onTap: () {
                                    setState(() {
                                      if (isSelected) {
                                        _selectedFriends.remove(friend.id);
                                      } else {
                                        _selectedFriends.add(friend.id);
                                      }
                                    });
                                  },
                                ),
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}
