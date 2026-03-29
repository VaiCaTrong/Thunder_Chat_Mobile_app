import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/conversation_model.dart';
import '../../models/message_model.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/socket_provider.dart';
import '../call/outgoing_call_screen.dart';

class ChatScreen extends StatefulWidget {
  final Conversation conversation;

  const ChatScreen({super.key, required this.conversation});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();
  bool _isLoadingMore = false;
  bool _isSending = false;
  int _previousMessageCount = 0;

  @override
  void initState() {
    super.initState();
    
    // Load messages when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      chatProvider.setActiveConversation(widget.conversation.id);
      await chatProvider.fetchMessages(widget.conversation.id);
      chatProvider.markAsSeen();
      
      // Scroll to bottom after messages are loaded
      _scrollToBottom();
    });

    // Listen for scroll to load more messages
    _scrollController.addListener(_onScroll);
  }

  void _scrollToBottom({bool animate = false}) {
    if (!_scrollController.hasClients) return;
    
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        if (animate) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        } else {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      }
    });
  }

  void _startVideoCall() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final socketProvider = Provider.of<SocketProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;
    
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not found')),
      );
      return;
    }

    // For direct chat, use conversation ID as call ID
    // For group chat, also use conversation ID
    final callID = widget.conversation.id;
    
    // Get recipient info
    final otherUser = widget.conversation.getOtherParticipant(currentUser.id);
    final recipientName = widget.conversation.isGroup 
        ? widget.conversation.name ?? 'Group'
        : otherUser?.fullName ?? otherUser?.username ?? 'Unknown';
    final recipientId = widget.conversation.isGroup
        ? widget.conversation.id
        : otherUser?.id ?? '';
    
    // Emit incoming call event to other participants via socket service
    final socketService = socketProvider.socketService;
    socketService.emitIncomingCall(
      callId: callID,
      callerName: currentUser.fullName ?? currentUser.username,
      callerId: currentUser.id,
      callerAvatar: currentUser.avatar,
    );
    
    // Navigate to outgoing call screen (waiting for answer)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OutgoingCallScreen(
          callId: callID,
          recipientName: recipientName,
          recipientId: recipientId,
          recipientAvatar: otherUser?.avatar,
          currentUserId: currentUser.id,
          currentUserName: currentUser.fullName ?? currentUser.username,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    
    // Clear active conversation
    Provider.of<ChatProvider>(context, listen: false).setActiveConversation(null);
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels <= 100 && !_isLoadingMore) {
      _loadMoreMessages();
    }
  }

  Future<void> _loadMoreMessages() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final messageState = chatProvider.messages[widget.conversation.id];
    
    if (messageState?.hasMore == true && !chatProvider.messageLoading) {
      setState(() => _isLoadingMore = true);
      await chatProvider.fetchMessages(widget.conversation.id);
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || _isSending) return;

    print('=== ChatScreen: Sending message ===');
    print('Content: $content');
    print('Conversation ID: ${widget.conversation.id}');
    print('Is group: ${widget.conversation.isGroup}');

    setState(() => _isSending = true);

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.currentUser?.id;
    
    // Clear input immediately
    _messageController.clear();

    // Send message based on conversation type (DON'T add optimistic message, let socket handle it)
    if (widget.conversation.isGroup) {
      print('Sending group message...');
      await chatProvider.sendGroupMessage(
        conversationId: widget.conversation.id,
        content: content,
      );
    } else {
      // For direct messages, get recipient ID from participants
      final recipientId = widget.conversation.participants
          .firstWhere((id) => id != currentUserId, orElse: () => '');
      
      print('Sending direct message to: $recipientId');
      
      if (recipientId.isNotEmpty) {
        await chatProvider.sendDirectMessage(
          recipientId: recipientId,
          content: content,
        );
      } else {
        print('ERROR: No recipient ID found');
      }
    }

    print('Message sent, waiting for socket event...');
    setState(() => _isSending = false);

    // Scroll to bottom while keeping keyboard open
    _scrollToBottom(animate: true);
  }

  String _formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (difference.inDays == 1) {
      return 'Yesterday ${DateFormat('HH:mm').format(dateTime)}';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;
    
    // Get display name for the conversation
    final displayName = widget.conversation.getDisplayName(currentUser?.id ?? '');
    final otherUser = widget.conversation.getOtherParticipant(currentUser?.id ?? '');

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: widget.conversation.isGroup
                  ? Icon(
                      Icons.group,
                      color: theme.colorScheme.onPrimaryContainer,
                    )
                  : otherUser?.avatar != null
                      ? ClipOval(
                          child: Image.network(
                            otherUser!.avatar!,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Text(
                              displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                        )
                      : Text(
                          displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                          style: theme.textTheme.titleMedium,
                        ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.conversation.isGroup)
                    Text(
                      '${widget.conversation.participants.length} members',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    )
                  else if (otherUser?.isOnline == true)
                    Text(
                      'Online',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: _startVideoCall,
            tooltip: 'Video Call',
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: Show conversation options
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, _) {
                final messages = chatProvider.getConversationMessages(widget.conversation.id);

                // Auto scroll when new message arrives
                if (messages.length > _previousMessageCount) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToBottom(animate: true);
                  });
                }
                _previousMessageCount = messages.length;

                if (chatProvider.messageLoading && messages.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (messages.isEmpty) {
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
                          'No messages yet',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start the conversation!',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length + (_isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isLoadingMore && index == 0) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final messageIndex = _isLoadingMore ? index - 1 : index;
                    final message = messages[messageIndex];
                    final isOwn = message.senderId == currentUser?.id;

                    return _buildMessageBubble(message, isOwn, theme);
                  },
                );
              },
            ),
          ),

          // Message Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      focusNode: _messageFocusNode,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      enabled: !_isSending,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _isSending ? null : _sendMessage,
                    icon: _isSending
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.primary,
                            ),
                          )
                        : Icon(
                            Icons.send,
                            color: theme.colorScheme.primary,
                          ),
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message, bool isOwn, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isOwn ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isOwn && widget.conversation.isGroup) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                (message.senderName ?? 'U')[0].toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(fontSize: 10),
              ),
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isOwn
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isOwn ? 18 : 4),
                  bottomRight: Radius.circular(isOwn ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isOwn && widget.conversation.isGroup) ...[
                    Text(
                      message.senderName ?? 'Unknown',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    message.content,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isOwn
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatMessageTime(message.createdAt),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isOwn
                              ? theme.colorScheme.onPrimary.withOpacity(0.7)
                              : theme.colorScheme.onSurfaceVariant,
                          fontSize: 10,
                        ),
                      ),
                      if (isOwn) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.isRead ? Icons.done_all : Icons.done,
                          size: 14,
                          color: theme.colorScheme.onPrimary.withOpacity(0.7),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isOwn) const SizedBox(width: 4),
        ],
      ),
    );
  }
}
