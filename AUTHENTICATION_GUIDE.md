# Hướng dẫn sử dụng tính năng Đăng nhập & Đăng ký

## 📁 Các file đã tạo

### 1. **Models/User.dart**
Model dữ liệu người dùng với các trường:
- `id`: ID người dùng
- `username`: Tên đăng nhập
- `email`: Email
- `fullName`: Họ và tên (tùy chọn)
- `createdAt`: Thời gian tạo tài khoản

### 2. **utils/auth.dart**
Service xử lý authentication với các chức năng:
- `login()`: Đăng nhập qua API
- `register()`: Đăng ký tài khoản mới
- `saveToken()`: Lưu token vào SharedPreferences
- `getToken()`: Lấy token
- `saveUserData()`: Lưu thông tin user
- `getUserData()`: Lấy thông tin user
- `isLoggedIn()`: Kiểm tra trạng thái đăng nhập
- `logout()`: Đăng xuất
- `isValidEmail()`: Validate email
- `isValidPassword()`: Validate password (>= 6 ký tự)

### 3. **screens/login_screen.dart**
Màn hình đăng nhập với:
- Form validation đầy đủ
- Hiển thị/ẩn mật khẩu
- Loading indicator khi xử lý
- Thông báo lỗi bằng SnackBar
- Navigation sang màn hình đăng ký
- Nút "Quên mật khẩu" (placeholder)

### 4. **screens/register_screen.dart**
Màn hình đăng ký với:
- Các trường: username, email, password, confirm password, fullName (optional)
- Validation đầy đủ cho tất cả trường
- Kiểm tra mật khẩu khớp
- Hiển thị/ẩn mật khẩu
- Loading indicator
- Tự động đăng nhập sau khi đăng ký thành công

### 5. **main.dart**
Cập nhật với:
- Widget `AuthChecker` kiểm tra trạng thái đăng nhập khi khởi động
- Splash screen trong lúc kiểm tra
- Tự động chuyển hướng: LoginScreen (chưa đăng nhập) hoặc MainScreen (đã đăng nhập)

## 🔧 Cấu hình Backend API

### Thay đổi URL API
Mở file `lib/utils/auth.dart` và thay đổi `baseUrl`:

```dart
static const String baseUrl = 'https://your-api-url.com/api';
```

### API Endpoints cần thiết

#### 1. **POST /api/login**
Request:
```json
{
  "email": "user@example.com",
  "password": "123456"
}
```

Response (Success - 200):
```json
{
  "token": "jwt_token_here",
  "user": {
    "_id": "user_id",
    "username": "username",
    "email": "user@example.com",
    "fullName": "Full Name",
    "createdAt": "2025-01-01T00:00:00.000Z"
  }
}
```

Response (Error - 401):
```json
{
  "message": "Email hoặc mật khẩu không đúng"
}
```

#### 2. **POST /api/register**
Request:
```json
{
  "username": "username",
  "email": "user@example.com",
  "password": "123456",
  "fullName": "Full Name" // optional
}
```

Response (Success - 201):
```json
{
  "token": "jwt_token_here",
  "user": {
    "_id": "user_id",
    "username": "username",
    "email": "user@example.com",
    "fullName": "Full Name",
    "createdAt": "2025-01-01T00:00:00.000Z"
  }
}
```

Response (Error - 409):
```json
{
  "message": "Email hoặc tên đăng nhập đã tồn tại"
}
```

## 🎨 Tính năng

### ✅ Validation
- Email: Kiểm tra format hợp lệ
- Password: Tối thiểu 6 ký tự
- Username: Tối thiểu 3 ký tự
- Confirm Password: Phải khớp với mật khẩu

### 🔒 Bảo mật
- Mật khẩu được ẩn (obscureText)
- Token được lưu an toàn trong SharedPreferences
- Không lưu mật khẩu thô

### 🚀 User Experience
- Loading indicator khi xử lý
- Thông báo lỗi rõ ràng
- Splash screen khi khởi động
- Auto-navigation sau đăng nhập/đăng ký thành công
- Nút show/hide password

### 🔄 Navigation
- LoginScreen ⟷ RegisterScreen
- Auto redirect: AuthChecker → LoginScreen/MainScreen

## 📱 Sử dụng

### Thêm nút Đăng xuất vào MainScreen
Thêm code này vào `main_screen.dart`:

```dart
import 'package:nfc_01/utils/auth.dart';
import 'package:nfc_01/screens/login_screen.dart';

// Trong AppBar hoặc Drawer
IconButton(
  icon: Icon(Icons.logout),
  onPressed: () async {
    // Đăng xuất
    await Auth.logout();
    
    // Chuyển về màn hình đăng nhập
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  },
)
```

### Lấy thông tin user hiện tại
```dart
final user = await Auth.getUserData();
if (user != null) {
  print('Username: ${user.username}');
  print('Email: ${user.email}');
}
```

### Kiểm tra token
```dart
final token = await Auth.getToken();
if (token != null) {
  // Có token, user đã đăng nhập
}
```

## 🧪 Test với Mock Data

Nếu chưa có backend, bạn có thể test với mock data bằng cách thay đổi hàm trong `auth.dart`:

```dart
static Future<Map<String, dynamic>> login(String email, String password) async {
  // Mock delay
  await Future.delayed(const Duration(seconds: 2));
  
  // Mock data
  if (email == 'test@example.com' && password == '123456') {
    await saveToken('mock_token_123');
    return {
      'success': true,
      'message': 'Đăng nhập thành công!',
    };
  }
  
  return {
    'success': false,
    'message': 'Email hoặc mật khẩu không đúng!',
  };
}
```

## 🎯 Các bước tiếp theo

1. **Tạo Backend API** với các endpoints /login và /register
2. **Cập nhật baseUrl** trong auth.dart
3. **Thêm nút Đăng xuất** vào MainScreen
4. **Thêm chức năng "Quên mật khẩu"** (nếu cần)
5. **Thêm profile page** để hiển thị thông tin user

## 🐛 Xử lý lỗi

### Lỗi kết nối
App sẽ tự động hiển thị thông báo nếu không kết nối được API

### Lỗi 401, 409, 500
App xử lý và hiển thị thông báo phù hợp cho từng mã lỗi

### Timeout
Request API có timeout 10 giây

## 📚 Dependencies đã sử dụng

Các package đã có trong pubspec.yaml:
- `http`: Gọi API
- `shared_preferences`: Lưu token và user data
- `flutter/material.dart`: UI components

Không cần cài thêm package nào!

---

**Chúc bạn code vui vẻ! 🎉**
