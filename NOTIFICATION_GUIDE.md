# Notification System Guide

## Tổng quan
Ứng dụng đã tích hợp hệ thống thông báo cho tin nhắn mới và cuộc gọi video.

## Tính năng

### 1. Thông báo tin nhắn mới
- Hiển thị khi nhận tin nhắn mới từ người khác
- Chỉ hiển thị khi không đang ở trong conversation đó
- Hiển thị tên người gửi và nội dung tin nhắn
- Nhấn vào thông báo để mở conversation

### 2. Thông báo cuộc gọi video
- Hiển thị khi có người gọi video call
- Có 2 nút: Accept và Reject
- Nhấn Accept để tham gia cuộc gọi
- Nhấn Reject để từ chối

## Cấu hình

### Notification Channels
1. **Message Channel**
   - Channel Key: `message_channel`
   - Importance: High
   - Sound: Enabled
   - Vibration: Enabled

2. **Call Channel**
   - Channel Key: `call_channel`
   - Importance: Max
   - Sound: Enabled
   - Vibration: Enabled
   - Critical Alerts: Enabled

## Permissions

### Android
Không cần thêm permissions đặc biệt, notification permissions được yêu cầu tự động.

### iOS
Notification permissions được yêu cầu khi app khởi động lần đầu.

## Cách hoạt động

### Message Notification Flow
1. User A gửi tin nhắn
2. Backend emit socket event `new-message`
3. User B nhận event qua socket
4. Nếu User B không đang ở trong conversation đó:
   - Hiển thị notification với tên người gửi và nội dung
5. User B nhấn vào notification:
   - Mở conversation tương ứng

### Call Notification Flow
1. User A bắt đầu video call
2. App emit socket event `incoming-call` với:
   - callId (conversation ID)
   - callerName
   - callerId
   - callerAvatar (optional)
3. User B nhận event qua socket
4. Hiển thị notification với 2 nút Accept/Reject
5. User B nhấn Accept:
   - Mở VideoCallScreen với callId
6. User B nhấn Reject:
   - Dismiss notification

## Implementation Details

### NotificationService
- Singleton service quản lý tất cả notifications
- Sử dụng `awesome_notifications` package
- Hỗ trợ 2 loại notification: message và call

### NotificationProvider
- Provider quản lý state của notification system
- Khởi tạo service và request permissions
- Cung cấp methods để show notifications

### Socket Integration
- Socket provider lắng nghe events:
  - `new-message`: Hiển thị message notification
  - `incoming-call`: Hiển thị call notification
- Chỉ hiển thị notification khi message không phải từ current user

## Testing

### Test Message Notification
1. Đăng nhập 2 tài khoản trên 2 thiết bị
2. User A gửi tin nhắn cho User B
3. User B sẽ nhận notification (nếu không đang ở trong chat)

### Test Call Notification
1. Đăng nhập 2 tài khoản trên 2 thiết bị
2. User A bắt đầu video call
3. User B sẽ nhận notification với nút Accept/Reject
4. Nhấn Accept để join call

## Troubleshooting

### Không nhận được notification
- Kiểm tra notification permissions trong Settings
- Đảm bảo socket đã kết nối
- Kiểm tra console logs để debug

### Notification không có sound
- Kiểm tra volume của thiết bị
- Kiểm tra Do Not Disturb mode
- Kiểm tra notification channel settings

### Accept call không hoạt động
- Hiện tại chức năng navigation từ notification action chưa hoàn thiện
- Cần implement proper navigation context

## Future Improvements

1. **Navigation từ notification**
   - Implement proper navigation khi nhấn vào notification
   - Handle deep linking

2. **Group notifications**
   - Gộp nhiều tin nhắn từ cùng một người
   - Summary notification

3. **Custom notification sound**
   - Cho phép user chọn ringtone riêng

4. **Notification badges**
   - Hiển thị số lượng tin nhắn chưa đọc trên app icon

5. **Rich notifications**
   - Hiển thị avatar của người gửi
   - Quick reply từ notification
