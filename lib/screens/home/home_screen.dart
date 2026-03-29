import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/socket_provider.dart';
import '../../providers/notification_provider.dart';
import '../../services/notification_service.dart';
import '../call/incoming_call_screen.dart';
import 'chat_list_tab.dart';
import 'contacts_tab.dart';
import 'profile_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _tabs = [
    const ChatListTab(),
    const ContactsTab(),
    const ProfileTab(),
  ];

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      final socketProvider = Provider.of<SocketProvider>(context, listen: false);
      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);

      print('Initializing app...');
      print('Current user: ${authProvider.currentUser?.username}');

      // Initialize notifications
      await notificationProvider.initialize();
      if (!notificationProvider.permissionGranted) {
        await notificationProvider.requestPermissions();
      }

      // Set up notification tap handler
      NotificationService().onNotificationTap = (payload) {
        print('Notification tapped with payload: $payload');
        _handleNotificationTap(payload, socketProvider);
      };

      // Set current user for chat provider
      chatProvider.setCurrentUser(authProvider.currentUser);

      // Connect socket
      await socketProvider.connectSocket();
      socketProvider.setChatProvider(chatProvider);
      socketProvider.setNotificationProvider(notificationProvider);

      // Load initial data
      await chatProvider.fetchConversations();
      
      print('App initialized successfully');
    } catch (e) {
      print('Error initializing app: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load data: ${e.toString()}'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _initializeApp,
            ),
          ),
        );
      }
    }
  }

  void _handleNotificationTap(String payload, SocketProvider socketProvider) {
    print('Handling notification tap: $payload');
    
    if (payload.startsWith('call:')) {
      // Handle call notification tap
      final callData = socketProvider.pendingCallData;
      if (callData != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => IncomingCallScreen(
              callId: callData['callId'] ?? '',
              callerName: callData['callerName'] ?? 'Unknown',
              callerId: callData['callerId'] ?? '',
              callerAvatar: callData['callerAvatar'],
            ),
          ),
        );
      }
    } else if (payload.startsWith('message:')) {
      // Handle message notification tap
      final conversationId = payload.replaceFirst('message:', '');
      // TODO: Navigate to chat screen with conversationId
      print('Navigate to conversation: $conversationId');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(48)),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(48)),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline),
                activeIcon: Icon(Icons.chat_bubble),
                label: 'CHATS',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.group_outlined),
                activeIcon: Icon(Icons.group),
                label: 'CONTACTS',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'PROFILE',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
