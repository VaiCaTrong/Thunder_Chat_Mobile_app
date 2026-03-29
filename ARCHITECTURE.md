# Solaris Chat - Architecture & Flow

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Flutter Web App                          │
│                   (Port 5173)                                │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   Screens    │  │  Providers   │  │   Services   │     │
│  │              │  │              │  │              │     │
│  │ - Login      │  │ - Auth       │  │ - API        │     │
│  │ - Home       │  │ - Chat       │  │ - Socket     │     │
│  │ - Chat       │  │ - Friend     │  │ - Auth       │     │
│  │ - Contacts   │  │ - Socket     │  │ - Chat       │     │
│  │ - Profile    │  │              │  │ - Friend     │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│         │                  │                  │             │
│         └──────────────────┴──────────────────┘             │
│                            │                                │
└────────────────────────────┼────────────────────────────────┘
                             │
                             │ HTTP/WebSocket
                             │
┌────────────────────────────┼────────────────────────────────┐
│                            ▼                                 │
│                   Backend Server                             │
│                   (Port 3000)                                │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ Controllers  │  │  Middleware  │  │    Models    │     │
│  │              │  │              │  │              │     │
│  │ - Auth       │  │ - Auth       │  │ - User       │     │
│  │ - User       │  │ - Friend     │  │ - Friend     │     │
│  │ - Friend     │  │ - Socket     │  │ - Convo      │     │
│  │ - Convo      │  │              │  │ - Message    │     │
│  │ - Message    │  │              │  │              │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│         │                                    │               │
│         └────────────────────────────────────┘               │
│                            │                                 │
└────────────────────────────┼─────────────────────────────────┘
                             │
                             │ MongoDB Driver
                             │
┌────────────────────────────┼─────────────────────────────────┐
│                            ▼                                  │
│                   MongoDB Atlas                               │
│                   (Cloud Database)                            │
│                                                               │
│  Collections:                                                 │
│  - users                                                      │
│  - friends                                                    │
│  - friendrequests                                             │
│  - conversations                                              │
│  - messages                                                   │
│  - sessions                                                   │
└───────────────────────────────────────────────────────────────┘
```

## Authentication Flow

```
┌─────────┐                                    ┌─────────┐
│ Flutter │                                    │ Backend │
│   App   │                                    │ Server  │
└────┬────┘                                    └────┬────┘
     │                                              │
     │  POST /auth/signin                           │
     │  { username, password }                      │
     ├─────────────────────────────────────────────>│
     │                                              │
     │                                              │ Verify credentials
     │                                              │ Generate JWT token
     │                                              │
     │  { accessToken }                             │
     │<─────────────────────────────────────────────┤
     │                                              │
     │  Store token                                 │
     │                                              │
     │  GET /users/me                               │
     │  Authorization: Bearer <token>               │
     ├─────────────────────────────────────────────>│
     │                                              │
     │                                              │ Verify token
     │                                              │ Get user data
     │                                              │
     │  { user: {...} }                             │
     │<─────────────────────────────────────────────┤
     │                                              │
     │  Connect WebSocket                           │
     │  with token                                  │
     ├─────────────────────────────────────────────>│
     │                                              │
     │  Socket connected                            │
     │<─────────────────────────────────────────────┤
     │                                              │
```

## Chat Creation Flow

```
┌─────────┐                                    ┌─────────┐
│ Flutter │                                    │ Backend │
│   App   │                                    │ Server  │
└────┬────┘                                    └────┬────┘
     │                                              │
     │  User clicks chat icon                       │
     │  next to friend                              │
     │                                              │
     │  POST /conversations                         │
     │  {                                           │
     │    type: 'direct',                           │
     │    name: 'Friend Name',                      │
     │    memberIds: ['friendId']                   │
     │  }                                           │
     ├─────────────────────────────────────────────>│
     │                                              │
     │                                              │ Check friendship
     │                                              │ (middleware)
     │                                              │
     │                                              │ Check if conversation
     │                                              │ already exists
     │                                              │
     │                                              │ Create or return
     │                                              │ existing conversation
     │                                              │
     │  {                                           │
     │    conversation: {                           │
     │      _id: '...',                             │
     │      type: 'direct',                         │
     │      participants: [                         │
     │        {                                     │
     │          _id: '...',                         │
     │          displayName: '...',                 │
     │          avatarUrl: '...'                    │
     │        }                                     │
     │      ],                                      │
     │      lastMessage: null,                      │
     │      unreadCounts: {}                        │
     │    }                                         │
     │  }                                           │
     │<─────────────────────────────────────────────┤
     │                                              │
     │  Parse conversation                          │
     │  Add to local state                          │
     │  Navigate to chat screen                     │
     │                                              │
     │  Socket: join-conversation                   │
     ├─────────────────────────────────────────────>│
     │                                              │
     │  Ready to send/receive messages              │
     │                                              │
```

## Message Flow

```
┌─────────┐                                    ┌─────────┐
│ Flutter │                                    │ Backend │
│   App   │                                    │ Server  │
└────┬────┘                                    └────┬────┘
     │                                              │
     │  User types message                          │
     │  and clicks send                             │
     │                                              │
     │  POST /messages/direct                       │
     │  {                                           │
     │    recipientId: '...',                       │
     │    content: 'Hello!',                        │
     │    conversationId: '...'                     │
     │  }                                           │
     ├─────────────────────────────────────────────>│
     │                                              │
     │                                              │ Save message
     │                                              │ Update conversation
     │                                              │
     │                                              │ Emit via Socket.IO
     │                                              │ to all participants
     │                                              │
     │  { message: {...} }                          │
     │<─────────────────────────────────────────────┤
     │                                              │
     │  Socket: new-message                         │
     │  { message: {...} }                          │
     │<─────────────────────────────────────────────┤
     │                                              │
     │  Add message to UI                           │
     │  Update conversation                         │
     │                                              │
```

## Data Models

### User
```dart
{
  id: String,
  username: String,
  email: String,
  displayName: String?,
  avatar: String?,
  isOnline: bool?,
  lastSeen: DateTime?,
  createdAt: DateTime
}
```

### Conversation
```dart
{
  id: String,
  name: String,
  isGroup: bool,
  participants: List<String>,  // User IDs
  participantDetails: List<User>?,
  lastMessage: Message?,
  unreadCount: int,
  createdAt: DateTime,
  updatedAt: DateTime?
}
```

### Message
```dart
{
  id: String,
  conversationId: String,
  senderId: String,
  content: String,
  imgUrl: String?,
  isOwn: bool,
  createdAt: DateTime
}
```

### Friend
```dart
{
  id: String,
  username: String,
  email: String,
  fullName: String?,
  avatar: String?,
  isOnline: bool?
}
```

## State Management

### Providers (using Provider package)

1. **AuthProvider**
   - Current user
   - Login/logout
   - Token management

2. **ChatProvider**
   - Conversations list
   - Messages by conversation
   - Active conversation
   - Send message
   - Mark as seen

3. **FriendProvider**
   - Friends list
   - Friend requests (sent/received)
   - Add/remove friends
   - Accept/decline requests

4. **SocketProvider**
   - Socket connection
   - Event listeners
   - Emit events
   - Connection status

## API Endpoints

### Authentication
- `POST /auth/signin` - Login
- `POST /auth/signup` - Register
- `POST /auth/signout` - Logout
- `GET /users/me` - Get current user

### Friends
- `GET /friends` - Get all friends
- `GET /friends/requests` - Get friend requests
- `POST /friends/requests` - Send friend request
- `PATCH /friends/requests/:id/accept` - Accept request
- `PATCH /friends/requests/:id/decline` - Decline request

### Conversations
- `GET /conversations` - Get all conversations
- `POST /conversations` - Create conversation
- `GET /conversations/:id/messages` - Get messages
- `PATCH /conversations/:id/seen` - Mark as seen

### Messages
- `POST /messages/direct` - Send direct message
- `POST /messages/group` - Send group message

## Socket.IO Events

### Client → Server
- `join-conversation` - Join conversation room
- `leave-conversation` - Leave conversation room
- `typing` - User is typing
- `stop-typing` - User stopped typing

### Server → Client
- `new-message` - New message received
- `new-group` - Added to new group
- `message-deleted` - Message was deleted
- `read-message` - Message was read
- `user-online` - User came online
- `user-offline` - User went offline

## Testing Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Playwright Tests                         │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   E2E Tests  │  │   Helpers    │  │    Config    │     │
│  │              │  │              │  │              │     │
│  │ - Login      │  │ - Auth       │  │ - Browsers   │     │
│  │ - Chat Flow  │  │ - Navigation │  │ - Timeouts   │     │
│  │ - Friends    │  │ - Assertions │  │ - Screenshots│     │
│  │ - Messages   │  │              │  │ - Videos     │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│         │                                                    │
│         └────────────────┬───────────────────────────────   │
└──────────────────────────┼───────────────────────────────────┘
                           │
                           │ Automated Browser Control
                           │
┌──────────────────────────┼───────────────────────────────────┐
│                          ▼                                    │
│                   Chromium Browser                            │
│                   (Headless Mode)                             │
│                                                               │
│  Interacts with Flutter Web App                              │
│  - Fill forms                                                 │
│  - Click buttons                                              │
│  - Navigate pages                                             │
│  - Verify elements                                            │
│  - Take screenshots                                           │
└───────────────────────────────────────────────────────────────┘
```

## File Structure

```
mobile_app/
├── lib/
│   ├── config/
│   │   ├── api_config.dart          # API endpoints
│   │   └── app_theme.dart           # Theme configuration
│   ├── models/
│   │   ├── user_model.dart          # User data model
│   │   ├── conversation_model.dart  # Conversation model
│   │   └── message_model.dart       # Message model
│   ├── providers/
│   │   ├── auth_provider.dart       # Auth state
│   │   ├── chat_provider.dart       # Chat state
│   │   ├── friend_provider.dart     # Friends state
│   │   └── socket_provider.dart     # Socket state
│   ├── services/
│   │   ├── api_service.dart         # HTTP client
│   │   ├── auth_service.dart        # Auth API calls
│   │   ├── chat_service.dart        # Chat API calls
│   │   ├── friend_service.dart      # Friend API calls
│   │   └── socket_service.dart      # Socket.IO client
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── signup_screen.dart
│   │   ├── home/
│   │   │   ├── home_screen.dart
│   │   │   ├── chat_list_tab.dart
│   │   │   ├── contacts_tab.dart
│   │   │   └── profile_tab.dart
│   │   ├── chat/
│   │   │   ├── chat_screen.dart
│   │   │   └── new_chat_screen.dart
│   │   └── friends/
│   │       ├── add_friend_screen.dart
│   │       └── friend_requests_screen.dart
│   └── utils/
│       └── string_utils.dart        # Helper functions
├── e2e/
│   ├── helpers/
│   │   └── auth-helper.js           # Test helpers
│   ├── simple-login.spec.js         # Basic login test
│   ├── chat-flow.spec.js            # Chat workflow test
│   ├── auth.spec.js                 # Auth tests
│   ├── friends.spec.js              # Friend tests
│   └── chat.spec.js                 # Chat tests
├── playwright.config.js             # Playwright config
├── test-config.json                 # Test credentials
├── TESTING_GUIDE.md                 # This guide
├── FIXES_SUMMARY.md                 # What was fixed
└── TEST_COMMANDS.md                 # Command reference
```

## Key Concepts

### 1. Provider Pattern
Flutter uses Provider for state management. Providers notify listeners when state changes, triggering UI updates.

### 2. Async/Await
All API calls are asynchronous. Use `async/await` to handle them properly.

### 3. Socket.IO
Real-time communication uses Socket.IO. Client connects on login, joins conversation rooms, and listens for events.

### 4. JWT Authentication
Backend uses JWT tokens. Token is stored in Flutter and sent with each API request in Authorization header.

### 5. Friendship Requirement
Backend middleware checks friendship before allowing conversation creation. Users must be friends to chat.

### 6. Conversation Types
- **Direct**: 1-on-1 chat between two users
- **Group**: Chat with multiple participants

### 7. Message Ownership
Messages have `isOwn` flag to determine if current user sent them, used for UI alignment (left/right).

## Performance Considerations

1. **Pagination**: Messages are loaded in batches (50 at a time) with cursor-based pagination
2. **Lazy Loading**: Conversations load on demand, not all at once
3. **Socket Rooms**: Users only receive events for conversations they're in
4. **Debouncing**: Search and typing indicators use debouncing to reduce API calls
5. **Caching**: Provider state acts as cache, reducing redundant API calls

## Security

1. **JWT Tokens**: 7-day expiration, stored securely
2. **Password Hashing**: bcrypt with salt rounds
3. **Friendship Check**: Middleware prevents unauthorized conversation creation
4. **Input Validation**: All inputs validated on backend
5. **CORS**: Configured to allow only specific origins
6. **Rate Limiting**: Should be added for production

## Next Steps for Production

1. Add error boundaries
2. Implement retry logic
3. Add offline support
4. Implement message encryption
5. Add file upload
6. Add voice/video calls
7. Add push notifications
8. Add analytics
9. Add crash reporting
10. Add performance monitoring
