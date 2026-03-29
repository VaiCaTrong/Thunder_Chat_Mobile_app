import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/friend_provider.dart';
import '../../providers/chat_provider.dart';
import '../../utils/string_utils.dart';
import '../friends/add_friend_screen.dart';
import '../chat/chat_screen.dart';

class ContactsTab extends StatefulWidget {
  const ContactsTab({super.key});

  @override
  State<ContactsTab> createState() => _ContactsTabState();
}

class _ContactsTabState extends State<ContactsTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load friends when tab is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FriendProvider>(context, listen: false).loadFriends();
    });
  }

  // Remove didChangeDependencies to avoid calling during build

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;

    return Consumer<FriendProvider>(
      builder: (context, friendProvider, child) {
        // Auto-load friends if empty and not loading
        if (friendProvider.friends.isEmpty && !friendProvider.isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            friendProvider.loadFriends();
          });
        }
        
        final friends = friendProvider.friends;
        final isLoading = friendProvider.isLoading;

        // Filter friends based on search
        final searchQuery = _searchController.text.toLowerCase();
        final filteredFriends = searchQuery.isEmpty
            ? friends
            : friends.where((friend) {
                final name = (friend.fullName ?? friend.username).toLowerCase();
                final username = friend.username.toLowerCase();
                return name.contains(searchQuery) || username.contains(searchQuery);
              }).toList();

        // Group friends by first letter
        final groupedFriends = <String, List<dynamic>>{};
        for (var friend in filteredFriends) {
          final name = getDisplayName(friend.fullName, friend.username);
          if (name.isEmpty) continue; // Skip if no name
          
          final firstLetter = getInitial(name);
          if (!groupedFriends.containsKey(firstLetter)) {
            groupedFriends[firstLetter] = [];
          }
          groupedFriends[firstLetter]!.add(friend);
        }

        final sortedLetters = groupedFriends.keys.toList()..sort();

        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          body: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: currentUser?.avatar != null
                            ? ClipOval(
                                child: Image.network(
                                  currentUser!.avatar!,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.person,
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.person,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Solaris',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      // Debug info
                      if (friendProvider.error != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Tooltip(
                            message: friendProvider.error!,
                            child: Icon(
                              Icons.error_outline,
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ),
                      Text(
                        '${friends.length}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () {
                          friendProvider.loadFriends();
                        },
                      ),
                    ],
                  ),
                ),

                // Title Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contacts',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Connect with your radiant circle',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
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

                const SizedBox(height: 24),

                // Contacts List
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : friends.isEmpty
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
                                    'No contacts yet',
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
                                  itemCount: sortedLetters.length,
                                  itemBuilder: (context, index) {
                                    final letter = sortedLetters[index];
                                    final friendsInSection = groupedFriends[letter]!;
                                    
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Section Header
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          child: Row(
                                            children: [
                                              Text(
                                                letter,
                                                style: theme.textTheme.titleLarge?.copyWith(
                                                  color: theme.colorScheme.primary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: Container(
                                                  height: 1,
                                                  color: theme.colorScheme.outlineVariant.withOpacity(0.3),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Friends in section
                                        ...friendsInSection.map((friend) {
                                          return Container(
                                            margin: const EdgeInsets.only(bottom: 8),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.surfaceContainerLow,
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            child: ListTile(
                                              contentPadding: const EdgeInsets.all(16),
                                              leading: Stack(
                                                children: [
                                                  CircleAvatar(
                                                    radius: 28,
                                                    backgroundColor: theme.colorScheme.primaryContainer,
                                                    child: friend.avatar != null
                                                        ? ClipOval(
                                                            child: Image.network(
                                                              friend.avatar!,
                                                              width: 56,
                                                              height: 56,
                                                              fit: BoxFit.cover,
                                                              errorBuilder: (_, __, ___) {
                                                                return Text(
                                                                  getInitial(friend.fullName ?? friend.username),
                                                                  style: theme.textTheme.titleLarge,
                                                                );
                                                              },
                                                            ),
                                                          )
                                                        : Text(
                                                            getInitial(friend.fullName ?? friend.username),
                                                            style: theme.textTheme.titleLarge,
                                                          ),
                                                  ),
                                                  if (friend.isOnline ?? false)
                                                    Positioned(
                                                      bottom: 0,
                                                      right: 0,
                                                      child: Container(
                                                        width: 16,
                                                        height: 16,
                                                        decoration: BoxDecoration(
                                                          color: theme.colorScheme.primary,
                                                          shape: BoxShape.circle,
                                                          border: Border.all(
                                                            color: theme.colorScheme.surfaceContainerLow,
                                                            width: 3,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                ],
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
                                              trailing: IconButton(
                                                icon: const Icon(Icons.chat),
                                                color: theme.colorScheme.onSurfaceVariant,
                                                onPressed: () async {
                                                  // Create or open direct conversation
                                                  final chatProvider = Provider.of<ChatProvider>(context, listen: false);
                                                  
                                                  print('Creating conversation with friend: ${friend.id}');
                                                  
                                                  final conversation = await chatProvider.createConversation(
                                                    type: 'direct',
                                                    name: getDisplayName(friend.fullName, friend.username),
                                                    memberIds: [friend.id],
                                                  );
                                                  
                                                  if (conversation != null && mounted) {
                                                    print('Navigating to chat screen');
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (_) => ChatScreen(conversation: conversation),
                                                      ),
                                                    );
                                                  } else if (mounted) {
                                                    final errorMsg = chatProvider.error ?? 'Không thể tạo cuộc trò chuyện';
                                                    print('Error: $errorMsg');
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text(errorMsg),
                                                        backgroundColor: theme.colorScheme.error,
                                                        action: SnackBarAction(
                                                          label: 'Đóng',
                                                          textColor: Colors.white,
                                                          onPressed: () {},
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                },
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ],
                                    );
                                  },
                                ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddFriendScreen()),
              );
            },
            child: const Icon(Icons.person_add),
          ),
        );
      },
    );
  }
}
