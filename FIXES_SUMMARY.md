# Fixes Summary - Chat App Issues

## Date: March 28, 2026

## Issues Fixed

### 1. Playwright Login Test Selectors (E2E Testing)
**Problem:** Playwright tests couldn't find and fill login form inputs in Flutter web app.

**Root Cause:** Flutter web uses special input elements that don't match standard HTML selectors.

**Solution:**
- Updated `mobile_app/e2e/helpers/auth-helper.js`
- Simplified selector strategy to use `page.locator('input').all()` to get all inputs
- First input = username, second input = password
- Use `getByRole('button', { name: /Sign In/i })` for login button
- Added better logging and error handling

**Files Changed:**
- `mobile_app/e2e/helpers/auth-helper.js`

### 2. Conversation Model Type Mapping
**Problem:** Backend returns `type: 'direct'` or `type: 'group'`, but Flutter model expected `isGroup` boolean.

**Root Cause:** Mismatch between backend API response format and Flutter model expectations.

**Solution:**
- Updated `Conversation.fromJson()` to check both `json['type']` and `json['isGroup']`
- Map `type == 'group'` to `isGroup = true`
- Handle conversation name extraction from participant details for direct chats
- Handle group name from `json['group']['name']`
- Fixed unreadCount to handle both single value and Map format from backend

**Files Changed:**
- `mobile_app/lib/models/conversation_model.dart`

### 3. Conversations Not Loading in CHATS Tab
**Problem:** CHATS tab showed empty even when conversations existed.

**Root Cause:** Conversations were not being fetched when CHATS tab opened.

**Solution:**
- Updated `ChatListTab.initState()` to call `chatProvider.fetchConversations()`
- Ensured current user is set before fetching
- Home screen already calls `fetchConversations()` on init, but tab-specific loading ensures data is fresh

**Files Changed:**
- `mobile_app/lib/screens/home/chat_list_tab.dart`

### 4. Headless Testing Configuration
**Problem:** User wanted tests to run without showing browser window.

**Solution:**
- Added `headless: true` to Playwright config
- Tests now run in background without visible browser

**Files Changed:**
- `mobile_app/playwright.config.js`

## New Test Files Created

### 1. Simple Login Test
**File:** `mobile_app/e2e/simple-login.spec.js`
**Purpose:** Basic test to verify login works and home screen loads
**What it tests:**
- Login with test credentials
- Verify CHATS, CONTACTS, and PROFILE tabs are visible
- Take screenshot of home screen

### 2. Enhanced Chat Flow Test
**File:** `mobile_app/e2e/chat-flow.spec.js` (already existed, kept as is)
**Purpose:** Comprehensive test of chat functionality
**What it tests:**
- Login
- Navigate to CONTACTS tab
- Click chat icon to create conversation
- Send message
- Verify conversation appears in CHATS tab

## How to Run Tests

### Start Backend Server
```bash
cd backend
npm start
```

### Start Flutter Web App (in separate terminal)
```bash
cd mobile_app
flutter run -d chrome --web-port=5173
```

### Run Playwright Tests (in separate terminal)
```bash
cd mobile_app

# Run all tests
npm test

# Run specific test
npx playwright test e2e/simple-login.spec.js

# Run with UI (headed mode)
npx playwright test --headed

# Run and show report
npx playwright test
npx playwright show-report
```

## Test Credentials
- Username: `phamminhtrong324`
- Password: `123456`

## Expected Behavior After Fixes

### Login Flow
1. User enters username and password
2. Clicks "Sign In to Solaris" button
3. Redirects to home screen with 3 tabs visible

### Chat Creation Flow
1. Navigate to CONTACTS tab
2. See list of friends (if any exist)
3. Click chat icon next to friend's name
4. Conversation is created (or existing one is opened)
5. Chat screen opens with message input
6. Can send messages
7. Conversation appears in CHATS tab

### CHATS Tab
1. Shows "Recent Messages" header
2. Lists all conversations with:
   - Friend/group name
   - Last message preview
   - Timestamp
   - Unread count badge (if any)
3. Shows empty state if no conversations exist

## Backend API Notes

### Conversation Creation Response
```json
{
  "conversation": {
    "_id": "...",
    "type": "direct",  // or "group"
    "participants": [
      {
        "_id": "userId",
        "displayName": "User Name",
        "avatarUrl": "...",
        "joinedAt": "..."
      }
    ],
    "lastMessage": null,
    "lastMessageAt": "...",
    "unreadCounts": {},
    "seenBy": []
  }
}
```

### Get Conversations Response
```json
{
  "conversations": [
    {
      "_id": "...",
      "type": "direct",
      "participants": [...],
      "lastMessage": {...},
      "unreadCounts": {
        "userId": 0
      }
    }
  ]
}
```

## Known Issues / Future Improvements

1. **Socket.IO Integration**: Real-time message updates depend on socket connection
2. **Error Handling**: Could add more user-friendly error messages
3. **Loading States**: Could add skeleton loaders while fetching data
4. **Retry Logic**: Could add automatic retry for failed API calls
5. **Test Coverage**: Could add more edge case tests (no friends, network errors, etc.)

## Debug Tips

### If login test fails:
1. Check if Flutter app is running on port 5173
2. Check browser console for errors
3. Look at screenshot in `test-results/login-failed.png`
4. Verify test credentials are correct

### If conversations don't appear:
1. Check backend logs for API errors
2. Verify user has friends and conversations in database
3. Check Flutter console for error messages
4. Verify socket connection is established

### If chat creation fails:
1. Check backend middleware `checkFriendship` - users must be friends
2. Verify friend relationship exists in database
3. Check backend logs for conversation creation errors
4. Verify API response format matches model expectations
