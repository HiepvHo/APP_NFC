# 📱 SCREENS - TÀI LIỆU CHI TIẾT

## Tổng quan
Thư mục `screens` chứa tất cả các màn hình (UI) của ứng dụng NFC. Mỗi file là một StatefulWidget quản lý một màn hình cụ thể.

---

## 📋 Danh sách các màn hình

### 1. 🔐 **login_screen.dart**
**Chức năng**: Màn hình đăng nhập

**Các tính năng**:
- Đăng nhập bằng email/password
- Đăng nhập bằng Google Sign-In
- Validation form (email hợp lệ, password >= 6 ký tự)
- Show/hide password
- Link đến màn hình quên mật khẩu
- Link đến màn hình đăng ký

**State variables**:
- `_formKey`: Key để validate form
- `_emailController`, `_passwordController`: Controllers cho TextField
- `_isLoading`: Trạng thái loading khi đăng nhập
- `_isGoogleLoading`: Trạng thái loading cho Google Sign-In
- `_obscurePassword`: Ẩn/hiện mật khẩu

**Methods chính**:
- `_handleLogin()`: Xử lý đăng nhập thường
- `_handleGoogleLogin()`: Xử lý đăng nhập Google
- `_showMessage()`: Hiển thị thông báo
- `_navigateToRegister()`: Chuyển sang màn hình đăng ký

**Flow**:
1. User nhập email/password
2. Validate form
3. Gọi Auth.login() -> MongoDB
4. Lưu token vào SharedPreferences
5. Navigator.pushReplacement() -> MainScreen

---

### 2. 📝 **register_screen.dart**
**Chức năng**: Màn hình đăng ký tài khoản mới

**Các tính năng**:
- Đăng ký với username, email, password, fullname
- Xác nhận password (confirm password)
- Validation đầy đủ
- Show/hide password
- Link quay lại đăng nhập

**State variables**:
- `_usernameController`: Tên đăng nhập (unique)
- `_emailController`: Email (unique)
- `_passwordController`: Mật khẩu
- `_confirmPasswordController`: Xác nhận mật khẩu
- `_fullNameController`: Tên đầy đủ (optional)
- `_isLoading`: Trạng thái loading

**Validation rules**:
- Username: Không trống, >= 3 ký tự
- Email: Format hợp lệ
- Password: >= 6 ký tự
- Confirm Password: Phải khớp với password
- Full Name: Optional

**Methods chính**:
- `_handleRegister()`: Xử lý đăng ký
- `_showMessage()`: Hiển thị thông báo

**Flow**:
1. User điền form
2. Validate tất cả fields
3. Gọi Auth.register() -> MongoDB
4. Tạo user mới với password đã hash
5. Chuyển về LoginScreen

---

### 3. 🏠 **main_screen.dart**
**Chức năng**: Màn hình chính với Bottom Navigation Bar

**Các tính năng**:
- Bottom Navigation với 4 tabs:
  - Home (Trang chủ)
  - Scan (Quét NFC/Camera)
  - List (Danh sách từ)
  - Profile (Hồ sơ)
- Quản lý state của tab hiện tại
- Hiển thị AppBar tùy chỉnh

**State variables**:
- `_selectedIndex`: Index của tab hiện tại (0-3)
- `_screens`: List các widget màn hình

**Methods chính**:
- `_onItemTapped()`: Xử lý khi tap vào tab
- `build()`: Xây dựng UI với Scaffold + BottomNavigationBar

**Structure**:
```
MainScreen
├── HomeScreen (index 0)
├── ScanScreen (index 1)
├── ListScreen (index 2)
└── ProfileScreen (index 3)
```

---

### 4. 🎯 **home_screen.dart**
**Chức năng**: Trang chủ - Dashboard

**Các tính năng**:
- Hiển thị "Word of the Moment" (từ vựng xoay vòng)
- Biểu đồ tròn (PieChart) thống kê:
  - Words Learned
  - Practice Score
  - Quiz Score
- Learning Stats
- Top Users Leaderboard (Bảng xếp hạng)
- Tự động đổi từ vựng mỗi 15 giây

**State variables**:
- `_currentWordIndex`: Index từ vựng hiện tại
- `_timer`: Timer để xoay vòng từ vựng
- `_vocabularyList`: Danh sách từ vựng mẫu

**Widgets**:
- `_buildVocabularyCard()`: Card hiển thị từ vựng
- `_buildStatItem()`: Item thống kê
- PieChart từ fl_chart package
- ListView cho leaderboard

**Timer**: Tự động chuyển từ mỗi 15s

---

### 5. 📷 **scan_screen.dart**
**Chức năng**: Quét NFC và nhận diện hình ảnh

**Các tính năng chính**:
- **Quét thẻ NFC**: Đọc dữ liệu từ thẻ NFC (NDEF format)
- **Chụp ảnh**: Gọi camera để chụp
- **Chọn ảnh**: Chọn từ thư viện
- **Nhận diện AI**: Gửi ảnh đến API để nhận diện từ vựng
- Hiển thị từ vựng tìm được với audio

**State variables**:
- `scannedWord`: Từ đã quét được
- `matchedWord`: WordData tương ứng
- `isScanning`: Trạng thái quét
- `isScanningNFC`: Đang quét NFC
- `isProcessingImage`: Đang xử lý ảnh
- `wordList`: Danh sách từ vựng từ MongoDB

**NFC Flow**:
1. User tap "Quét NFC"
2. Kiểm tra NFC available
3. Đợi user đưa thẻ lại gần
4. Đọc NDEF message
5. Parse format: "EN:english|VN:vietnamese|IMG:path"
6. Hiển thị WordData

**Image Recognition Flow**:
1. User chọn chụp/chọn ảnh
2. Upload ảnh đến API (ngrok)
3. API trả về kết quả nhận diện
4. Tìm WordData trong database
5. Hiển thị kết quả

**Methods chính**:
- `_scanNFC()`: Quét thẻ NFC
- `_captureImage()`: Chụp ảnh
- `_pickImage()`: Chọn ảnh từ thư viện
- `_processAPIResponse()`: Xử lý kết quả từ API
- `loadWords()`: Tải từ vựng từ MongoDB

---

### 6. 📖 **word_screen.dart**
**Chức năng**: Hiển thị chi tiết một từ vựng

**Các tính năng**:
- Hiển thị hình ảnh từ vựng
- Hiển thị từ tiếng Anh và tiếng Việt
- Phát âm thanh (EN/VN)
- Button để phát audio

**Props nhận vào**:
- `WordData word`: Đối tượng từ vựng cần hiển thị

**Widgets**:
- Image.asset() hoặc Image.network()
- Text widgets cho EN/VN
- IconButton để phát audio
- AudioPlayer integration

**Methods**:
- `_playAudio()`: Phát file audio
- `build()`: Xây dựng UI

---

### 7. 📋 **list_screen.dart**
**Chức năng**: Danh sách tất cả từ vựng

**Các tính năng**:
- Hiển thị list tất cả từ trong database
- Search/Filter từ vựng
- Tap vào item -> Xem chi tiết
- Pull to refresh
- Loading state

**State variables**:
- `wordList`: List các WordData
- `filteredList`: List sau khi filter
- `isLoading`: Trạng thái loading
- `_searchController`: Controller cho search

**Methods**:
- `loadWords()`: Tải danh sách từ MongoDB
- `_filterWords()`: Lọc từ theo search
- `_onWordTap()`: Xử lý khi tap vào từ
- `_refresh()`: Pull to refresh

**UI Structure**:
```
AppBar (với search)
├── TextField (search)
└── ListView.builder
    └── WordCard (mỗi từ)
        ├── Image
        ├── English text
        ├── Vietnamese text
        └── Audio button
```

---

### 8. ✍️ **write_screen.dart**
**Chức năng**: Ghi dữ liệu vào thẻ NFC

**Các tính năng**:
- Chọn từ vựng từ danh sách
- Ghi thông tin vào thẻ NFC
- Format NDEF: "EN:apple|VN:táo|IMG:path"
- Hiển thị trạng thái ghi
- Xác nhận ghi thành công

**State variables**:
- `selectedWord`: Từ được chọn để ghi
- `isWriting`: Đang ghi thẻ
- `wordList`: Danh sách từ có thể chọn

**NFC Write Flow**:
1. User chọn từ vựng
2. Tap "Ghi vào thẻ"
3. Đợi user đưa thẻ lại gần
4. Tạo NDEF message với format đặc biệt
5. Ghi vào thẻ
6. Hiển thị thông báo thành công

**Methods**:
- `_selectWord()`: Chọn từ vựng
- `_writeToNFC()`: Ghi vào thẻ NFC
- `_createNDEFMessage()`: Tạo message format
- `_showSuccessDialog()`: Dialog thành công

---

### 9. 👤 **profile_screen.dart**
**Chức năng**: Hồ sơ người dùng

**Các tính năng**:
- Hiển thị thông tin user (avatar, tên, email)
- Thống kê học tập cá nhân
- Cài đặt:
  - Đổi mật khẩu
  - Chỉnh sửa profile
  - Ngôn ngữ
- Đăng xuất

**State variables**:
- `user`: Đối tượng User hiện tại
- `stats`: Thống kê học tập
- `isLoading`: Loading user data

**Methods**:
- `loadUserProfile()`: Tải thông tin user
- `_handleLogout()`: Xử lý đăng xuất
- `_navigateToEditProfile()`: Sang màn hình sửa profile
- `_navigateToChangePassword()`: Sang màn hình đổi password

**Logout Flow**:
1. User tap "Đăng xuất"
2. Hiển thị dialog xác nhận
3. Xóa token khỏi SharedPreferences
4. Navigator.pushAndRemoveUntil() -> LoginScreen

---

### 10. 🔑 **forgot_password_screen.dart**
**Chức năng**: Quên mật khẩu - Gửi mã OTP

**Các tính năng**:
- Nhập email
- Gửi mã OTP đến email
- Validation email
- Chuyển sang verify_code_screen

**Flow**:
1. User nhập email
2. Validate email tồn tại trong DB
3. Tạo mã OTP 6 số ngẫu nhiên
4. Gửi email qua SMTP
5. Lưu OTP vào database (với expiry time)
6. Chuyển sang VerifyCodeScreen

**Methods**:
- `_sendOTP()`: Gửi mã OTP
- `_validateEmail()`: Kiểm tra email tồn tại

---

### 11. ✅ **verify_code_screen.dart**
**Chức năng**: Xác thực mã OTP

**Các tính năng**:
- Nhập mã OTP 6 số
- Xác thực mã
- Countdown timer (hết hạn sau 5 phút)
- Resend OTP
- Chuyển sang reset_password_screen

**Props**:
- `email`: Email của user

**State variables**:
- `otpCode`: Mã OTP nhập vào
- `remainingTime`: Thời gian còn lại
- `isVerifying`: Đang xác thực

**Flow**:
1. User nhập 6 số OTP
2. Gửi lên server verify
3. So sánh OTP và kiểm tra expiry
4. Nếu đúng: chuyển sang ResetPasswordScreen
5. Nếu sai: hiển thị lỗi

---

### 12. 🔄 **reset_password_screen.dart**
**Chức năng**: Đặt lại mật khẩu mới

**Các tính năng**:
- Nhập password mới
- Xác nhận password
- Validation
- Cập nhật password trong DB
- Chuyển về LoginScreen

**Props**:
- `email`: Email của user

**Flow**:
1. User nhập password mới (2 lần)
2. Validate khớp nhau
3. Hash password
4. Cập nhật trong MongoDB
5. Xóa OTP code
6. Chuyển về LoginScreen

---

### 13. 🔍 **find_screen.dart**
**Chức năng**: Tìm kiếm từ vựng nâng cao

**Các tính năng**:
- Search bar
- Filter theo category
- Sort theo alphabet/date
- Hiển thị kết quả
- Xem chi tiết từ

**State variables**:
- `searchQuery`: Query tìm kiếm
- `searchResults`: Kết quả
- `selectedCategory`: Category đã chọn

---

### 14. 📊 **pie_chart_screen.dart**
**Chức năng**: Màn hình biểu đồ chi tiết

**Các tính năng**:
- Biểu đồ tròn (PieChart) lớn
- Biểu đồ cột (BarChart)
- Biểu đồ đường (LineChart)
- Thống kê chi tiết theo thời gian
- Export data

**Charts**:
- Learning progress
- Quiz scores
- Practice time
- Word categories

---

## 🎨 Thiết kế chung

### Color Scheme
```dart
Primary: Color(0xFFFFDAC1)  // Cam nhạt
Accent: Color.fromARGB(255, 160, 95, 41)  // Nâu/cam đậm
Success: Colors.green
Error: Colors.red
Google: Colors.red (cho button Google)
```

### Typography
```dart
Heading: 32px, Bold
Subheading: 18-24px, SemiBold
Body: 16px, Regular
Caption: 14px, Regular
```

### Components
- **Buttons**: Rounded 12px, elevation 5
- **TextFields**: White background, shadow, rounded 12px
- **Cards**: White, shadow, rounded 15px
- **Icons**: Material Icons, size 24-80px

---

## 🔄 Navigation Flow

```
SplashScreen (main.dart)
    │
    ├─ isLoggedIn = true ──→ MainScreen
    │                           ├─ HomeScreen
    │                           ├─ ScanScreen
    │                           ├─ ListScreen
    │                           └─ ProfileScreen
    │
    └─ isLoggedIn = false ──→ LoginScreen
                                 ├─ RegisterScreen
                                 └─ ForgotPasswordScreen
                                       ├─ VerifyCodeScreen
                                       └─ ResetPasswordScreen
```

---

## 🔐 Authentication Flow

### Login
```
LoginScreen
    ├─ Email/Password ──→ Auth.login()
    │                        ├─ Hash password (SHA256)
    │                        ├─ Query MongoDB users collection
    │                        ├─ Generate token
    │                        ├─ Save to SharedPreferences
    │                        └─ Return success
    │
    └─ Google Sign-In ──→ Auth.signInWithGoogle()
                             ├─ Google OAuth
                             ├─ Get user info
                             ├─ Create/Update user in MongoDB
                             ├─ Generate token
                             └─ Save to SharedPreferences
```

### Register
```
RegisterScreen
    ├─ Validate all fields
    ├─ Check username/email unique
    ├─ Hash password (SHA256)
    ├─ Insert to MongoDB users collection
    └─ Navigate to LoginScreen
```

### Forgot Password
```
ForgotPasswordScreen
    ├─ Validate email exists
    ├─ Generate 6-digit OTP
    ├─ Send email via SMTP
    ├─ Save OTP to DB (5min expiry)
    └─ Navigate to VerifyCodeScreen
        ├─ Verify OTP
        └─ Navigate to ResetPasswordScreen
            ├─ Hash new password
            ├─ Update in MongoDB
            └─ Navigate to LoginScreen
```

---

## 📦 Dependencies Used

```yaml
# UI & Charts
fl_chart: ^0.69.2           # Biểu đồ

# NFC
flutter_nfc_kit: ^3.5.0     # NFC support
nfc_manager: ^3.5.0         # NFC manager
ndef: ^0.3.3                # NDEF format

# Audio
audioplayers: ^6.0.0        # Phát audio
flutter_tts: ^3.5.0         # Text to speech

# Image
image_picker: ^1.1.2        # Chọn/chụp ảnh

# Network
http: ^1.1.0                # HTTP requests

# Database
mongo_dart: ^0.10.0         # MongoDB connection

# Storage
shared_preferences: ^2.3.4  # Local storage

# Security
crypto: ^3.0.3              # Hash passwords

# Email
mailer: ^6.0.1              # Send emails

# Auth
google_sign_in: ^6.2.1      # Google OAuth

# Permissions
permission_handler: ^11.3.1 # Request permissions
```

---

## 🐛 Common Issues & Solutions

### Issue 1: NFC không hoạt động
**Solution**:
- Thêm permissions vào AndroidManifest.xml
- Kiểm tra thiết bị có hỗ trợ NFC
- Enable NFC trong settings

### Issue 2: MongoDB connection timeout
**Solution**:
- Kiểm tra internet connection
- Verify MongoDB URI
- Check IP whitelist trên MongoDB Atlas

### Issue 3: Google Sign-In fails
**Solution**:
- Cấu hình google-services.json
- Enable Google Sign-In API trên Google Cloud Console
- Check SHA-1 fingerprint

### Issue 4: Image picker không hoạt động
**Solution**:
- Thêm permissions (camera, storage)
- Request runtime permissions
- Handle iOS Info.plist

---

## 📝 Best Practices

1. **Luôn dispose controllers** để tránh memory leak
2. **Check `mounted`** trước khi gọi setState() sau async
3. **Validate form** trước khi submit
4. **Show loading indicators** khi có async operation
5. **Handle errors gracefully** với try-catch
6. **Use constants** cho colors, sizes, strings
7. **Separate business logic** từ UI code
8. **Comment code** rõ ràng, đặc biệt logic phức tạp

---

## 🚀 Future Improvements

1. Thêm nhiều từ vựng hơn (hiện tại chỉ 7 loại trái cây)
2. Gamification (điểm, level, achievements)
3. Luyện tập từ vựng (flashcards, quiz)
4. Offline mode hoàn chỉnh
5. Push notifications
6. Social features (share progress)
7. Multiple languages support
8. Dark mode
9. Voice recognition
10. AR mode với camera

---

_Document created: November 4, 2025_
_Last updated: November 4, 2025_
