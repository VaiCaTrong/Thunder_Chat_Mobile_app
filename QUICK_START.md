# Quick Start - Build APK

## Bước 1: Cấu hình .env

Tạo file `.env` trong thư mục `mobile_app/`:

```env
# Backend API Configuration
API_BASE_URL=http://192.168.1.100:5002/api
SOCKET_URL=http://192.168.1.100:5002

# Zegocloud Video Call Configuration
ZEGO_APP_ID=1816273976
ZEGO_APP_SIGN=b92a349b2eb7754dab0ec418da84933ca470c98e63c1dca6c900f8901cc47447
```

**Thay `192.168.1.100` bằng IP thực của máy bạn!**

Để tìm IP:
```bash
# Windows
ipconfig

# Tìm dòng "IPv4 Address" trong phần WiFi adapter
```

## Bước 2: Build APK

```bash
cd mobile_app
flutter pub get
flutter build apk --release
```

APK sẽ được tạo tại: `build/app/outputs/flutter-apk/app-release.apk`

## Bước 3: Cài đặt lên điện thoại

### Cách 1: Qua USB
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Cách 2: Chuyển file
1. Copy file `app-release.apk` vào điện thoại
2. Mở file và cài đặt
3. Cho phép cài đặt từ nguồn không xác định

## Bước 4: Chạy backend

Đảm bảo backend đang chạy:
```bash
cd backend
npm start
```

## Bước 5: Test

1. Mở app trên điện thoại
2. Đăng ký/Đăng nhập
3. Test chat, video call, notifications

## Lưu ý quan trọng

- Điện thoại và máy tính phải cùng mạng WiFi
- Backend phải đang chạy
- Tắt firewall hoặc cho phép port 5002
- Cấp quyền Camera, Microphone, Notifications cho app

## Troubleshooting

### Không kết nối được backend
```bash
# Kiểm tra IP
ipconfig

# Kiểm tra backend đang chạy
curl http://192.168.1.100:5002/api/auth/signin

# Test từ điện thoại
# Mở browser trên điện thoại và truy cập:
http://192.168.1.100:5002
```

### Build lỗi
```bash
flutter clean
flutter pub get
flutter build apk --release
```
