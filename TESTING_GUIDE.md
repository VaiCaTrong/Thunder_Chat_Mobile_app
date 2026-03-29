# Complete Testing Guide - Solaris Chat App

## Overview
This guide covers automated testing setup and execution for the Solaris Chat mobile app using Playwright.

## What Was Fixed

### 1. ✅ Playwright Login Selectors
- **Issue**: Tests couldn't find login form inputs in Flutter web
- **Fix**: Simplified selector strategy to work with Flutter's input elements
- **Result**: Login tests now work reliably in headless mode

### 2. ✅ Conversation Model Parsing
- **Issue**: Backend returns `type: 'direct'/'group'` but model expected `isGroup`
- **Fix**: Updated model to handle both formats and extract conversation names
- **Result**: Conversations now parse correctly from API responses

### 3. ✅ CHATS Tab Loading
- **Issue**: Conversations didn't appear in CHATS tab
- **Fix**: Added `fetchConversations()` call when tab initializes
- **Result**: Conversations now load and display properly

### 4. ✅ Headless Testing
- **Issue**: Tests opened browser window
- **Fix**: Added `headless: true` to Playwright config
- **Result**: Tests run in background without UI

## Quick Start

### Step 1: Start Backend
```bash
cd backend
npm start
```
Expected output:
```
Server đang chạy trên cổng 3000
✓ Kết nối MongoDB thành công!
```

### Step 2: Start Flutter Web (New Terminal)
```bash
cd mobile_app
flutter run -d chrome --web-port=5173
```
Expected output:
```
Launching lib/main.dart on Chrome in debug mode...
...
Application finished.
```

### Step 3: Run Tests (New Terminal)
```bash
cd mobile_app

# Run simple login test first
npx playwright test e2e/simple-login.spec.js

# If that works, run full test suite
npm test
```

## Test Files Explained

### 1. `e2e/simple-login.spec.js` ⭐ START HERE
**Purpose**: Verify basic login functionality
**What it does**:
- Opens app at http://localhost:5173
- Fills username and password
- Clicks login button
- Verifies home screen loads with 3 tabs
- Takes screenshot

**Expected output**:
```
🔐 Logging in as: phamminhtrong324
Looking for login form...
Found 2 input elements
✓ Using first input as username field
✓ Filled username: phamminhtrong324
✓ Using second input as password field
✓ Filled password
✓ Found login button
✓ Clicked login button
✓ Logged in successfully
✓ Login test passed!
```

### 2. `e2e/chat-flow.spec.js`
**Purpose**: Test complete chat workflow
**What it does**:
- Login
- Navigate to CONTACTS tab
- Click chat icon next to friend
- Verify chat screen opens
- Send test message
- Verify message appears
- Check CHATS tab for conversation

**Prerequisites**: Must have at least one friend in contacts

### 3. `e2e/auth.spec.js`
**Purpose**: Test authentication flows
**What it does**:
- Test successful login
- Test failed login
- Test logout

### 4. `e2e/friends.spec.js`
**Purpose**: Test friend management
**What it does**:
- Search for users
- Send friend requests
- Accept/decline requests
- View friends list

### 5. `e2e/chat.spec.js`
**Purpose**: Test chat features
**What it does**:
- Create conversations
- Send messages
- View message history
- Mark as read

## Understanding Test Results

### Success ✅
```
Running 1 test using 1 worker
  ✓  1 simple-login.spec.js:5:3 › Simple Login Test › should successfully login (15s)

  1 passed (18s)
```

### Failure ❌
```
Running 1 test using 1 worker
  ✗  1 simple-login.spec.js:5:3 › Simple Login Test › should successfully login (30s)

  1 failed
    1) simple-login.spec.js:5:3 › Simple Login Test › should successfully login
```

Check:
1. Screenshot in `test-results/login-failed.png`
2. Error message in console
3. HTML report: `npx playwright show-report`

## Common Issues & Solutions

### Issue: "Login form not found"
**Cause**: Flutter app not running or not loaded
**Solution**:
1. Check Terminal 2 - is Flutter running?
2. Open http://localhost:5173 in browser manually
3. Wait 30 seconds for Flutter to compile
4. Try test again

### Issue: "No friends found"
**Cause**: Test user has no friends in database
**Solution**:
1. Login manually to app
2. Add friends using the app
3. Or use another test account that has friends

### Issue: "Chat screen did not open"
**Cause**: Conversation creation failed
**Solution**:
1. Check backend logs for errors
2. Verify users are friends (backend requires friendship)
3. Check backend middleware `checkFriendship`

### Issue: "Conversations not appearing in CHATS tab"
**Cause**: API call failed or no conversations exist
**Solution**:
1. Check backend logs
2. Create a conversation manually first
3. Check Flutter console for errors
4. Verify socket connection

### Issue: Tests timeout
**Cause**: App loading slowly or network issues
**Solution**:
1. Increase timeout in test file
2. Check backend is responding
3. Check MongoDB connection
4. Run with `--headed` to see what's happening

## Advanced Testing

### Run Specific Test
```bash
npx playwright test e2e/simple-login.spec.js
```

### Run with Browser Visible
```bash
npx playwright test --headed
```

### Debug Mode (Step Through)
```bash
npx playwright test --debug
```

### Run Only Failed Tests
```bash
npx playwright test --last-failed
```

### Generate Code (Record Actions)
```bash
npx playwright codegen http://localhost:5173
```

## Test Data

### Test User Credentials
- Username: `phamminhtrong324`
- Password: `123456`

### Creating Test Data
To create more test users:
1. Use signup form in app
2. Or insert directly into MongoDB:
```javascript
db.users.insertOne({
  username: "testuser2",
  email: "test2@example.com",
  password: "$2a$10$...", // hashed password
  firstName: "Test",
  lastName: "User",
  displayName: "Test User",
  createdAt: new Date()
})
```

## Continuous Integration (CI)

To run tests in CI/CD pipeline:

```yaml
# .github/workflows/test.yml
name: E2E Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
      - name: Install dependencies
        run: cd mobile_app && npm ci
      - name: Install Playwright
        run: cd mobile_app && npx playwright install --with-deps
      - name: Run tests
        run: cd mobile_app && npm test
      - uses: actions/upload-artifact@v3
        if: always()
        with:
          name: playwright-report
          path: mobile_app/playwright-report/
```

## Best Practices

### 1. Run Tests Locally First
Always test locally before pushing to CI

### 2. Keep Tests Independent
Each test should work standalone, not depend on others

### 3. Use Descriptive Names
Test names should clearly describe what they test

### 4. Clean Up After Tests
Tests should not leave data that affects other tests

### 5. Handle Async Properly
Always await async operations

### 6. Use Proper Selectors
Prefer role-based selectors over CSS selectors

### 7. Add Waits When Needed
Flutter web needs time to render, use `waitForTimeout` judiciously

## Monitoring & Debugging

### View Test Report
```bash
npx playwright show-report
```

### View Screenshots
```bash
ls test-results/*.png
```

### View Videos (on failure)
```bash
ls test-results/*.webm
```

### Enable Verbose Logging
```bash
DEBUG=pw:api npx playwright test
```

## Next Steps

1. ✅ Run `simple-login.spec.js` to verify setup
2. ✅ Run `chat-flow.spec.js` to test full workflow
3. ✅ Add more test cases as needed
4. ✅ Integrate into CI/CD pipeline
5. ✅ Set up test data fixtures
6. ✅ Add performance testing
7. ✅ Add accessibility testing

## Support

If tests fail:
1. Check this guide's troubleshooting section
2. Review `FIXES_SUMMARY.md` for technical details
3. Check `TEST_COMMANDS.md` for command reference
4. Review test output and screenshots
5. Check backend and Flutter console logs

## Summary

You now have:
- ✅ Working Playwright test setup
- ✅ Fixed login selectors for Flutter web
- ✅ Fixed conversation model parsing
- ✅ Fixed CHATS tab loading
- ✅ Headless testing enabled
- ✅ Comprehensive test suite
- ✅ Complete documentation

Run the simple login test to verify everything works!
