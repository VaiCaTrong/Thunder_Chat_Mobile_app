# Video Call Feature Guide

## Tổng quan
Ứng dụng đã tích hợp chức năng video call sử dụng Zegocloud SDK.

## Cấu hình

### Zegocloud Credentials
- **AppID**: 1816273976
- **AppSign**: b92a349b2eb7754dab0ec418da84933ca470c98e63c1dca6c900f8901cc47447

Thông tin này được lưu trong `lib/config/zego_config.dart`

## Cách sử dụng

### 1. Bắt đầu video call
- Mở một cuộc trò chuyện (chat screen)
- Nhấn vào icon camera (📹) trên thanh header
- Video call sẽ bắt đầu với conversation ID làm call ID

### 2. Trong cuộc gọi
- **Toggle Camera**: Bật/tắt camera
- **Toggle Microphone**: Bật/tắt microphone
- **Switch Camera**: Chuyển đổi giữa camera trước/sau
- **Hang Up**: Kết thúc cuộc gọi

### 3. Khi người khác tham gia
- Người nhận cần vào cùng conversation và nhấn nút video call
- Cả hai sẽ tự động kết nối với nhau thông qua cùng một call ID

## Permissions

### Android
Đã thêm các permissions sau vào `AndroidManifest.xml`:
- INTERNET
- ACCESS_WIFI_STATE
- ACCESS_NETWORK_STATE
- CAMERA
- RECORD_AUDIO
- MODIFY_AUDIO_SETTINGS
- BLUETOOTH
- BLUETOOTH_CONNECT

### iOS
Đã thêm các permissions sau vào `Info.plist`:
- NSCameraUsageDescription
- NSMicrophoneUsageDescription

## Lưu ý kỹ thuật

### Call ID
- Sử dụng conversation ID làm call ID
- Điều này đảm bảo cả hai người trong cùng một conversation sẽ join vào cùng một cuộc gọi

### User Info
- User ID: Lấy từ current user ID
- User Name: Lấy từ fullName hoặc username của current user

### Tính năng
- One-on-one video call
- Audio/Video toggle
- Camera switch
- Auto leave khi chỉ còn một người trong room

## Troubleshooting

### Lỗi permissions
- Đảm bảo đã cấp quyền camera và microphone cho app
- Trên Android: Settings > Apps > Mobile App > Permissions
- Trên iOS: Settings > Mobile App > Camera/Microphone

### Không kết nối được
- Kiểm tra kết nối internet
- Đảm bảo cả hai người dùng cùng call ID (conversation ID)
- Kiểm tra Zegocloud credentials

### Build errors
- Chạy `flutter clean` và `flutter pub get`
- Đảm bảo minSdkVersion >= 21 (Android)
