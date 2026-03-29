# Playwright E2E Testing

## Setup

Playwright đã được cài đặt và cấu hình sẵn.

## Chạy Tests

### 1. Đảm bảo backend đang chạy
```bash
cd backend
npm start
```

### 2. Chạy tất cả tests
```bash
cd mobile_app
npm test
```

### 3. Chạy tests với UI mode (recommended)
```bash
npm run test:ui
```

### 4. Chạy tests với browser hiển thị
```bash
npm run test:headed
```

### 5. Debug tests
```bash
npm run test:debug
```

### 6. Xem test report
```bash
npm run test:report
```

## Test Files

- `e2e/auth.spec.js` - Test đăng nhập/đăng ký
- `e2e/friends.spec.js` - Test quản lý bạn bè
- `e2e/chat.spec.js` - Test chức năng chat

## Lưu ý

- Tests sẽ tự động khởi động Flutter web app trên port 5173
- Backend phải chạy trên port 5002
- Đảm bảo có user `minhtrong2k4` với password `minhtrong2k4` trong database

## Cấu trúc Test

```
mobile_app/
├── e2e/
│   ├── auth.spec.js      # Authentication tests
│   ├── friends.spec.js   # Friends management tests
│   └── chat.spec.js      # Chat functionality tests
├── playwright.config.js  # Playwright configuration
└── package.json          # NPM scripts
```

## Chạy test cụ thể

```bash
# Chỉ chạy auth tests
npx playwright test auth

# Chỉ chạy friends tests
npx playwright test friends

# Chỉ chạy chat tests
npx playwright test chat
```

## Screenshots và Videos

- Screenshots được lưu khi test fail
- Videos được lưu khi test fail
- Tất cả được lưu trong thư mục `test-results/`
