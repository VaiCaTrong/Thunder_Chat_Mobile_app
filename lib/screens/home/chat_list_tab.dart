import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../chat/chat_screen.dart';
import '../chat/new_chat_screen.dart';

class ChatListTab extends StatefulWidget {
  const ChatListTab({super.key});

  @override
  State<ChatListTab> createState() => _ChatListTabState();
}

class _ChatListTabState extends State<ChatListTab> {
  @override
  void initState() {
    super.initState();
    // Set current user and load conversations when tab opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Set current user
      chatProvider.setCurrentUser(authProvider.currentUser);
      
      // Load conversations
      chatProvider.fetchConversations();
    });
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE').format(dateTime);
    } else {
      return DateFormat('dd/MM/yyyy').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;

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
                    'Radiant',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      // TODO: Implement search
                    },
                  ),
                ],
              ),
            ),

            // Stories/Status Section - Remove mock data
            const SizedBox(height: 16),

            // Recent Messages Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Recent Messages',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Chat List
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, chatProvider, _) {
                  if (chatProvider.convoLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (chatProvider.conversations.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 64,
                            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No conversations yet',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start a new chat to begin',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: chatProvider.conversations.length,
                    itemBuilder: (context, index) {
                      final conversation = chatProvider.conversations[index];
                      final lastMessage = conversation.lastMessage;
                      
                      // Get display name based on current user
                      final displayName = conversation.getDisplayName(currentUser?.id ?? '');

                      return InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(conversation: conversation),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              // Avatar
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                child: conversation.isGroup
                                    ? Icon(
                                        Icons.group,
                                        color: theme.colorScheme.onSurfaceVariant,
                                      )
                                    : const Icon(Icons.person),
                              ),

                              const SizedBox(width: 16),

                              // Content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            displayName,
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: conversation.unreadCount > 0
                                                  ? FontWeight.bold
                                                  : FontWeight.w600,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (lastMessage != null)
                                          Text(
                                            _formatTime(lastMessage.createdAt),
                                            style: theme.textTheme.labelSmall?.copyWith(
                                              color: conversation.unreadCount > 0
                                                  ? theme.colorScheme.primary
                                                  : theme.colorScheme.onSurfaceVariant,
                                              fontWeight: conversation.unreadCount > 0
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            lastMessage?.content ?? 'No messages yet',
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              color: conversation.unreadCount > 0
                                                  ? theme.colorScheme.onSurface
                                                  : theme.colorScheme.onSurfaceVariant,
                                              fontWeight: conversation.unreadCount > 0
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                        if (conversation.unreadCount > 0)
                                          Container(
                                            margin: const EdgeInsets.only(left: 8),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.primary,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              '${conversation.unreadCount}',
                                              style: theme.textTheme.labelSmall?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
            MaterialPageRoute(builder: (_) => const NewChatScreen()),
          );
        },
        child: const Icon(Icons.edit),
      ),
    );
  }
}
