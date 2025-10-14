# Tính Năng Quên Mật Khẩu - Hướng Dẫn Đầy Đủ

## 📋 Tổng Quan

Tính năng quên mật khẩu cho phép người dùng đặt lại mật khẩu thông qua xác thực email với mã OTP 6 chữ số.

## 🎯 Luồng Hoạt Động

```
LoginScreen 
    ↓ (Click "Quên mật khẩu?")
ForgotPasswordScreen (Nhập email)
    ↓ (Gửi mã OTP)
VerifyCodeScreen (Nhập 6 chữ số OTP)
    ↓ (Xác thực thành công)
ResetPasswordScreen (Nhập mật khẩu mới)
    ↓ (Đổi mật khẩu thành công)
LoginScreen (Đăng nhập với mật khẩu mới)
```

## 📁 Cấu Trúc File

### 1. EmailService (`lib/utils/email_service.dart`)
**Chức năng**: Service gửi email xác thực qua Gmail SMTP

**Cấu hình cần thiết**:
```dart
static const String _username = 'your-email@gmail.com'; 
static const String _password = 'your-app-password'; 
```

**⚠️ LƯU Ý QUAN TRỌNG**:
- Cần tạo **App Password** từ Google Account: https://myaccount.google.com/apppasswords
- **KHÔNG** sử dụng mật khẩu Gmail thông thường
- Bật **2-Step Verification** trước khi tạo App Password

**Methods**:
- `sendResetCode(String recipientEmail)` - Gửi mã OTP đến email
- `_generateOTP()` - Tạo mã OTP 6 chữ số ngẫu nhiên
- `isValidEmail(String email)` - Validate email format

### 2. AuthAPI (`lib/Models/AuthAPI.dart`)
**Các method mới đã thêm**:

#### `sendResetCode(String email)`
- Kiểm tra email có tồn tại trong database
- Tạo mã OTP 6 chữ số ngẫu nhiên
- Lưu OTP vào bộ nhớ tạm với thời gian hết hạn 10 phút
- **Hiện tại**: In OTP ra console để test (CHỈ ĐỂ DEV)
- **Production**: Gọi EmailService để gửi email thực tế

#### `verifyResetCode(String email, String otp)`
- Kiểm tra OTP có tồn tại cho email này không
- Kiểm tra thời gian hết hạn (10 phút)
- Xác thực mã OTP có đúng không

#### `resetPassword(String email, String otp, String newPassword)`
- Xác thực OTP trước khi đổi mật khẩu
- Hash mật khẩu mới bằng SHA256
- Cập nhật mật khẩu vào MongoDB
- Xóa OTP khỏi bộ nhớ tạm sau khi thành công

**Lưu trữ OTP**:
```dart
static final Map<String, Map<String, dynamic>> _otpStorage = {};
// Structure: { 
//   "email@example.com": { 
//     "otp": "123456", 
//     "expiry": DateTime 
//   } 
// }
```

### 3. Auth Wrapper (`lib/utils/auth.dart`)
**Các static method mới**:
- `sendResetCode(String email)`
- `verifyResetCode(String email, String otp)`
- `resetPassword(String email, String otp, String newPassword)`

### 4. Màn Hình UI

#### ForgotPasswordScreen (`lib/screens/forgot_password_screen.dart`)
**Chức năng**: Nhập email để nhận mã OTP

**UI Elements**:
- Icon lock_reset
- Email input field với validation
- Button "Gửi mã xác thực"
- TextButton "Quay lại đăng nhập"

**Validation**:
- Email không được rỗng
- Email phải đúng định dạng (regex)

**Flow**:
1. User nhập email
2. Validate email
3. Gọi API `sendResetCode(email)`
4. Nếu thành công → Navigate to VerifyCodeScreen

#### VerifyCodeScreen (`lib/screens/verify_code_screen.dart`)
**Chức năng**: Nhập mã OTP 6 chữ số

**UI Elements**:
- Icon mail_lock
- 6 ô input cho mỗi chữ số OTP
- Button "Xác thực"
- Countdown timer (60 giây)
- Button "Gửi lại" (hiện sau khi hết countdown)

**Features**:
- Tự động focus sang ô tiếp theo khi nhập số
- Tự động xác thực khi nhập đủ 6 số
- Countdown 60 giây trước khi cho phép gửi lại OTP
- Có thể gửi lại mã khi hết thời gian chờ

**Flow**:
1. User nhập 6 chữ số
2. Gọi API `verifyResetCode(email, otp)`
3. Nếu thành công → Navigate to ResetPasswordScreen

#### ResetPasswordScreen (`lib/screens/reset_password_screen.dart`)
**Chức năng**: Nhập mật khẩu mới

**UI Elements**:
- Icon lock_open
- New password input với show/hide
- Confirm password input với show/hide
- Button "Đổi mật khẩu"

**Validation**:
- Mật khẩu không được rỗng
- Mật khẩu ít nhất 6 ký tự
- Mật khẩu xác nhận phải khớp

**Flow**:
1. User nhập mật khẩu mới và xác nhận
2. Gọi API `resetPassword(email, otp, newPassword)`
3. Nếu thành công → Navigate to LoginScreen

#### LoginScreen (Updated)
**Thay đổi**:
- Đã thêm import `ForgotPasswordScreen`
- Button "Quên mật khẩu?" giờ navigate đến ForgotPasswordScreen
- Xóa placeholder "Chức năng đang phát triển"

## 🔧 Cài Đặt & Cấu Hình

### 1. Packages Đã Thêm
```yaml
dependencies:
  mailer: ^6.0.1  # Để gửi email
```

### 2. Setup Gmail SMTP
1. Truy cập: https://myaccount.google.com/security
2. Bật **2-Step Verification**
3. Truy cập: https://myaccount.google.com/apppasswords
4. Tạo App Password cho "Mail"
5. Copy password 16 ký tự được tạo ra
6. Cập nhật vào `lib/utils/email_service.dart`:
```dart
static const String _username = 'your-email@gmail.com';
static const String _password = 'xxxx xxxx xxxx xxxx'; // App Password
```

## 🧪 Testing

### Mode Development (Hiện tại)
OTP được in ra console để test:
```dart
debugPrint('OTP for $email: $otp');
return {
  'success': true,
  'message': 'Mã xác thực đã được gửi đến email của bạn!',
  'otp': otp, // CHỈ ĐỂ TEST
};
```

### Test Flow:
1. Click "Quên mật khẩu?" trên LoginScreen
2. Nhập email của user đã tồn tại (vd: admin@test.com)
3. Xem console để lấy OTP (vd: "OTP for admin@test.com: 123456")
4. Nhập 6 chữ số OTP vào VerifyCodeScreen
5. Nhập mật khẩu mới
6. Quay về LoginScreen và đăng nhập với mật khẩu mới

## 🚀 Production Deployment

### Bỏ Dev Mode và Bật Email Thực:
1. Mở `lib/Models/AuthAPI.dart`
2. Tìm method `sendResetCode`
3. Bỏ comment dòng này:
```dart
// await EmailService.sendResetCode(email, otp);
```
4. Xóa dòng debug này:
```dart
debugPrint('OTP for $email: $otp'); // XÓA
return {
  'success': true,
  'message': 'Mã xác thực đã được gửi đến email của bạn!',
  // 'otp': otp, // XÓA DÒNG NÀY
};
```

### Bảo Mật:
- ✅ Password được hash bằng SHA256
- ✅ OTP có thời gian hết hạn 10 phút
- ✅ OTP tự động xóa sau khi sử dụng thành công
- ✅ Email validation ở cả client và server
- ⚠️ Cần thêm rate limiting để tránh spam gửi email
- ⚠️ Cần lưu App Password vào environment variable

## 📊 Database Updates
**Không cần thay đổi cấu trúc database**. Tính năng hoạt động với collection `users` hiện tại, chỉ cập nhật field `password`.

## 🎨 UI Design
- Material Design 3
- Primary Color: Blue
- Icons: Material Icons
- Font: System default
- Border Radius: 12px
- Responsive layout với SingleChildScrollView

## ⚙️ Configuration Notes

### Email Template
Email HTML template đẹp với:
- Header với logo app
- OTP hiển thị nổi bật (font size lớn, spacing rộng)
- Thông báo thời gian hết hạn
- Footer với disclaimer

### Countdown Timer
- 60 giây chờ trước khi cho phép gửi lại
- Hiển thị đếm ngược real-time
- Disable button "Gửi lại" khi đang countdown

### OTP Storage
- Lưu trong memory (RAM) - tự động xóa khi restart app
- **Lưu ý**: Production nên dùng Redis hoặc database với TTL

## 🐛 Known Issues & Solutions

### Issue 1: Email không gửi được
**Giải pháp**:
- Kiểm tra đã bật 2-Step Verification chưa
- Dùng App Password, không phải password thường
- Kiểm tra internet connection
- Xem Gmail "Less secure app access" settings

### Issue 2: OTP hết hạn quá nhanh
**Giải pháp**: Tăng thời gian trong `sendResetCode`:
```dart
'expiry': DateTime.now().add(const Duration(minutes: 15)), // Từ 10 → 15 phút
```

### Issue 3: App restart mất OTP
**Lý do**: OTP lưu trong memory
**Giải pháp**:
- Cho phép gửi lại OTP
- Hoặc lưu OTP vào database với timestamp

## 📱 Screenshots Flow
```
[LoginScreen] 
    │
    ├─ "Quên mật khẩu?" button
    │
    ↓
[ForgotPasswordScreen]
    │
    ├─ Email input
    ├─ "Gửi mã xác thực" button
    │
    ↓
[VerifyCodeScreen]
    │
    ├─ 6 OTP boxes
    ├─ Countdown timer
    ├─ "Gửi lại" button
    │
    ↓
[ResetPasswordScreen]
    │
    ├─ New password input
    ├─ Confirm password input
    ├─ "Đổi mật khẩu" button
    │
    ↓
[LoginScreen] (Success)
```

## ✅ Checklist Deploy

- [ ] Cấu hình Gmail App Password
- [ ] Cập nhật email/password trong `email_service.dart`
- [ ] Remove debug code (OTP in console)
- [ ] Enable real email sending
- [ ] Test với email thật
- [ ] Add rate limiting cho API
- [ ] Move credentials to environment variables
- [ ] Test toàn bộ flow từ đầu đến cuối
- [ ] Update documentation với production settings

## 🔗 Related Files
- `lib/Models/AuthAPI.dart` - Core authentication logic
- `lib/Models/User.dart` - User model
- `lib/utils/auth.dart` - Auth wrapper
- `lib/utils/email_service.dart` - Email service
- `lib/screens/login_screen.dart` - Entry point
- `lib/screens/forgot_password_screen.dart` - Step 1
- `lib/screens/verify_code_screen.dart` - Step 2
- `lib/screens/reset_password_screen.dart` - Step 3

---
**Ngày tạo**: 6 tháng 10, 2025  
**Tác giả**: GitHub Copilot  
**Version**: 1.0.0
