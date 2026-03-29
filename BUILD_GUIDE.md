# Build & Deploy Guide

## Cấu hình môi trường

### 1. Tạo file .env
Copy file `.env.example` thành `.env` và cập nhật các giá trị:

```bash
cp .env.example .env
```

Nội dung file `.env`:
```env
# Backend API Configuration
API_BASE_URL=http://YOUR_SERVER_IP:5002/api
SOCKET_URL=http://YOUR_SERVER_IP:5002

# Zegocloud Video Call Configuration
ZEGO_APP_ID=1816273976
ZEGO_APP_SIGN=b92a349b2eb7754dab0ec418da84933ca470c98e63c1dca6c900f8901cc47447
```

**Lưu ý quan trọng:**
- Thay `YOUR_SERVER_IP` bằng IP thực của máy chạy backend
- Không dùng `localhost` hoặc `127.0.0.1` khi chạy trên điện thoại thật
- Để tìm IP máy tính: `ipconfig` (Windows) hoặc `ifconfig` (Mac/Linux)
- Ví dụ: `http://192.168.1.100:5002/api`

### 2. Cài đặt dependencies
```bash
flutter pub get
```

## Build APK cho Android

### Debug APK (Để test)
```bash
flutter build apk --debug
```
File APK sẽ được tạo tại: `build/app/outputs/flutter-apk/app-debug.apk`

### Release APK (Để phát hành)
```bash
flutter build apk --release
```
File APK sẽ được tạo tại: `build/app/outputs/flutter-apk/app-release.apk`

### Split APK theo architecture (Giảm kích thước)
```bash
flutter build apk --split-per-abi --release
```
Sẽ tạo 3 file APK:
- `app-armeabi-v7a-release.apk` (cho điện thoại 32-bit cũ)
- `app-arm64-v8a-release.apk` (cho điện thoại 64-bit mới)
- `app-x86_64-release.apk` (cho emulator)

## Cài đặt lên điện thoại

### Cách 1: Qua USB
1. Bật Developer Options và USB Debugging trên điện thoại
2. Kết nối điện thoại với máy tính qua USB
3. Chạy lệnh:
```bash
flutter install
```

Hoặc cài APK trực tiếp:
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Cách 2: Chuyển file APK
1. Build APK như hướng dẫn trên
2. Chuyển file APK vào điện thoại (qua USB, email, cloud...)
3. Mở file APK trên điện thoại và cài đặt
4. Cho phép cài đặt từ nguồn không xác định nếu được hỏi

## Chạy trực tiếp trên điện thoại (Development)

### Kết nối qua USB
```bash
flutter devices
flutter run
```

### Kết nối qua WiFi (Wireless debugging - Android 11+)
1. Bật Wireless debugging trong Developer Options
2. Pair device:
```bash
adb pair IP:PORT
# Nhập pairing code hiển thị trên điện thoại
```
3. Connect:
```bash
adb connect IP:PORT
```
4. Run app:
```bash
flutter run
```

## Build cho iOS (Cần Mac)

### Debug
```bash
flutter build ios --debug
```

### Release
```bash
flutter build ios --release
```

Sau đó mở Xcode và archive để tạo IPA file.

## Troubleshooting

### Lỗi: "Unable to connect to backend"
- Kiểm tra IP trong file `.env`
- Đảm bảo backend đang chạy
- Đảm bảo điện thoại và máy tính cùng mạng WiFi
- Tắt firewall hoặc cho phép port 5002

### Lỗi: "Notification permissions denied"
- Vào Settings > Apps > Solaris Chat > Permissions
- Bật Notifications

### Lỗi: "Camera/Microphone permissions denied"
- Vào Settings > Apps > Solaris Chat > Permissions
- Bật Camera và Microphone

### Lỗi build: "minSdkVersion"
- Đảm bảo `minSdkVersion = 21` trong `android/app/build.gradle.kts`

### Lỗi: "Zegocloud not working"
- Kiểm tra ZEGO_APP_ID và ZEGO_APP_SIGN trong `.env`
- Đảm bảo có kết nối internet

## Tối ưu kích thước APK

### 1. Enable ProGuard (Minify code)
Trong `android/app/build.gradle.kts`:
```kotlin
buildTypes {
    release {
        minifyEnabled = true
        shrinkResources = true
        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )
    }
}
```

### 2. Split APK theo ABI
```bash
flutter build apk --split-per-abi --release
```

### 3. Build App Bundle (Cho Google Play)
```bash
flutter build appbundle --release
```

## Kiểm tra trước khi release

- [ ] Test đăng nhập/đăng ký
- [ ] Test gửi/nhận tin nhắn
- [ ] Test video call
- [ ] Test notifications
- [ ] Test trên nhiều thiết bị khác nhau
- [ ] Kiểm tra permissions (camera, mic, notifications)
- [ ] Test với backend production
- [ ] Kiểm tra kích thước APK

## Phát hành lên Google Play Store

1. Tạo keystore để ký APK
2. Cấu hình signing trong `android/app/build.gradle.kts`
3. Build App Bundle:
```bash
flutter build appbundle --release
```
4. Upload lên Google Play Console
5. Điền thông tin app và submit review

## Lưu ý bảo mật

- **KHÔNG** commit file `.env` lên Git
- **KHÔNG** share ZEGO credentials công khai
- Sử dụng ProGuard để obfuscate code
- Enable code signing cho production builds
