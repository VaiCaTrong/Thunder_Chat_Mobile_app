# Test Commands Quick Reference

## Prerequisites
1. Backend server must be running on port 3000
2. MongoDB Atlas must be accessible
3. Flutter web app must be running on port 5173

## Start Services

### Terminal 1 - Backend
```bash
cd backend
npm start
```

### Terminal 2 - Flutter Web
```bash
cd mobile_app
flutter run -d chrome --web-port=5173
```

## Run Tests

### Terminal 3 - Playwright Tests
```bash
cd mobile_app

# Run all tests (headless mode)
npm test

# Run specific test file
npx playwright test e2e/simple-login.spec.js
npx playwright test e2e/chat-flow.spec.js
npx playwright test e2e/auth.spec.js

# Run with browser visible (headed mode)
npx playwright test --headed

# Run with debug mode
npx playwright test --debug

# Run and open HTML report
npm test
npx playwright show-report
```

## Test Files

- `e2e/simple-login.spec.js` - Basic login test
- `e2e/chat-flow.spec.js` - Complete chat flow (login → contacts → chat → message)
- `e2e/auth.spec.js` - Authentication tests
- `e2e/friends.spec.js` - Friend management tests
- `e2e/chat.spec.js` - Chat functionality tests

## Test Results

- Screenshots: `mobile_app/test-results/*.png`
- HTML Report: `mobile_app/playwright-report/index.html`
- Videos: `mobile_app/test-results/*.webm` (on failure)

## Troubleshooting

### Test fails with "Login form not found"
- Ensure Flutter app is running on http://localhost:5173
- Check if app loaded properly in browser
- Try running with `--headed` to see what's happening

### Test fails with "No friends found"
- Login to app manually and add friends first
- Or create test data in database

### Test times out
- Increase timeout in test file
- Check if backend is responding
- Check network tab in browser for failed requests

## Manual Testing

To test manually:
1. Open http://localhost:5173 in Chrome
2. Login with: `phamminhtrong324` / `123456`
3. Navigate to CONTACTS tab
4. Click chat icon next to a friend
5. Send a message
6. Check CHATS tab to see conversation

## Clean Up

```bash
# Stop Flutter app
# Press 'q' in Terminal 2

# Stop backend
# Press Ctrl+C in Terminal 1

# Clean test results
cd mobile_app
rm -rf test-results playwright-report
```
