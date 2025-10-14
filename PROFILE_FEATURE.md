# 👤 Tính năng Profile & Đăng xuất

## ✅ Đã hoàn thành

Đã thêm trang **Profile** (Hồ sơ người dùng) với chức năng **Đăng xuất** vào ứng dụng!

## 📱 File đã tạo/cập nhật

### 1. **lib/screens/profile_screen.dart** (MỚI)
Màn hình hiển thị thông tin người dùng với:

#### 🎨 Giao diện:
- **Avatar tròn** với chữ cái đầu của tên
- **Tên đầy đủ** (hoặc username)
- **Username** với format @username
- **Card thông tin**:
  - 📧 Email
  - 👤 Tên đăng nhập
  - 📅 Ngày tham gia

#### 🔐 Chức năng:
- **Nút Đăng xuất** với màu đỏ
- **Dialog xác nhận** trước khi đăng xuất
- **Loading indicator** khi đang xử lý
- **SnackBar thông báo** khi thành công/thất bại
- **Tự động chuyển về LoginScreen** sau khi đăng xuất

### 2. **lib/screens/main_screen.dart** (CẬP NHẬT)
Đã thêm:
- Import ProfileScreen
- Thêm ProfileScreen vào list `_screens`
- Thêm tab "Profile" vào BottomNavigationBar (icon: person)

## 🎮 Cách sử dụng

### 1. Truy cập Profile
- Đăng nhập vào app
- Nhấn vào tab **"Profile"** ở bottom navigation (icon người)
- Xem thông tin cá nhân

### 2. Đăng xuất
1. Vào trang Profile
2. Scroll xuống dưới cùng
3. Nhấn nút **"Đăng xuất"** (màu đỏ)
4. Xác nhận trong dialog
5. App sẽ tự động chuyển về màn hình đăng nhập

## 🎨 UI/UX Features

### ✨ Profile Screen
```
┌─────────────────────────────┐
│        Hồ sơ              │
├─────────────────────────────┤
│                             │
│      ┌───────────┐          │
│      │    AB     │  Avatar  │
│      └───────────┘          │
│                             │
│    Nguyễn Văn A            │
│    @user1                   │
│                             │
│  ┌────────────────────────┐ │
│  │ 📧 Email               │ │
│  │ user1@example.com      │ │
│  └────────────────────────┘ │
│                             │
│  ┌────────────────────────┐ │
│  │ 👤 Tên đăng nhập       │ │
│  │ user1                  │ │
│  └────────────────────────┘ │
│                             │
│  ┌────────────────────────┐ │
│  │ 📅 Ngày tham gia       │ │
│  │ 6 Tháng 10, 2025       │ │
│  └────────────────────────┘ │
│                             │
│  ┌────────────────────────┐ │
│  │  🚪 Đăng xuất          │ │
│  └────────────────────────┘ │
│                             │
│    NFC App v1.0.0          │
└─────────────────────────────┘
```

### 🎯 Avatar Generator
- Lấy chữ cái đầu của **fullName** (nếu có)
- Nếu không có fullName, dùng **username**
- Hiển thị 1-2 chữ cái viết hoa
- Màu nền: `Color.fromARGB(255, 156, 107, 75)`

**Ví dụ:**
- "Nguyễn Văn A" → "NA"
- "user1" → "U"
- "John Doe" → "JD"

### 📅 Format ngày tháng
Hiển thị theo định dạng tiếng Việt:
```
6 Tháng 10, 2025
```

## 🔄 Luồng hoạt động

### Vào Profile Screen
```
User nhấn tab Profile
    ↓
Đọc user data từ SharedPreferences
    ↓
Hiển thị thông tin user
    ↓
Show avatar, name, email, username, join date
```

### Đăng xuất
```
User nhấn nút "Đăng xuất"
    ↓
Hiển thị Dialog xác nhận
    ↓
User xác nhận "Đăng xuất"
    ↓
Show loading indicator
    ↓
Gọi Auth.logout() (xóa token & user data)
    ↓
Close loading
    ↓
Navigator → LoginScreen (remove all routes)
    ↓
Show SnackBar "Đã đăng xuất thành công"
```

## 📊 Bottom Navigation

Bây giờ app có **7 tabs**:

| # | Icon | Label | Screen |
|---|------|-------|--------|
| 1 | 🏠 home | Home | HomeScreen |
| 2 | 📋 list_alt | List | ListScreen |
| 3 | ℹ️ info | Read | ScanScreen |
| 4 | ❓ quiz | Choose | WordScreen |
| 5 | ✅ assignment | Find | FindScreen |
| 6 | ✏️ edit | Write | WriteScreen |
| 7 | 👤 person | Profile | ProfileScreen |

## 🎯 Các tính năng chi tiết

### ✅ Avatar Generator
```dart
String _getInitials(String? name) {
  if (name == null || name.isEmpty) return '?';
  final parts = name.trim().split(' ');
  
  if (parts.length == 1) {
    return parts[0][0].toUpperCase();
  } else {
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }
}
```

### ✅ Logout Confirmation Dialog
```dart
AlertDialog(
  title: 'Đăng xuất',
  content: 'Bạn có chắc chắn muốn đăng xuất?',
  actions: [
    'Hủy' button,
    'Đăng xuất' button (red)
  ]
)
```

### ✅ Info Card Widget
Hiển thị thông tin dạng card với:
- Icon bên trái (trong container màu pastel)
- Title và Value
- Shadow và border-radius

### ✅ Error Handling
- Loading state khi đọc user data
- Retry button nếu lỗi
- SnackBar thông báo lỗi

## 🔐 Bảo mật

### Session Management
- Token được xóa khỏi SharedPreferences khi đăng xuất
- User data cũng được xóa
- Không thể quay lại MainScreen sau khi đăng xuất (routes bị clear)

### Auto-logout
Nếu token hết hạn hoặc không hợp lệ:
1. App sẽ redirect về LoginScreen
2. User phải đăng nhập lại

## 🎨 Responsive Design

### Màu sắc
- Background: `Color(0xFFFFDAC1)`
- AppBar: Transparent với title container
- Cards: White với shadow
- Avatar: `Color.fromARGB(255, 156, 107, 75)`
- Logout button: Red
- Icons: `Color.fromARGB(255, 160, 95, 41)`

### Spacing
- Padding: 20px
- Card margin: 12px vertical
- Avatar radius: 60px
- Button height: 55px

## 🆕 Test thử

### 1. Xem Profile
```bash
flutter run -d emulator-5554
```
1. Đăng nhập với: `admin@example.com` / `123456`
2. Nhấn tab **Profile** (icon người)
3. Xem thông tin: Avatar, tên, email, username, ngày tham gia

### 2. Đăng xuất
1. Ở trang Profile, scroll xuống
2. Nhấn nút **"Đăng xuất"**
3. Xác nhận trong dialog
4. App chuyển về LoginScreen
5. Thử đăng nhập lại

### 3. Kiểm tra Avatar
- Đăng nhập với các user khác nhau:
  - `admin@example.com` → "A"
  - `user1@example.com` → "NA" (Nguyễn Văn A)
  - `user2@example.com` → "TB" (Trần Thị B)

## 🐛 Troubleshooting

### Avatar không hiển thị đúng
- Kiểm tra fullName và username trong database
- Avatar sẽ dùng fullName nếu có, không thì dùng username

### Không thể đăng xuất
- Kiểm tra console có lỗi không
- Kiểm tra Auth.logout() có hoạt động không
- Xem SharedPreferences có được clear không

### Thông tin user không hiển thị
- Kiểm tra đã đăng nhập chưa
- Xem SharedPreferences có lưu user data không
- Retry bằng nút "Thử lại"

## 🎯 Tính năng có thể mở rộng

1. **Edit Profile** - Chỉnh sửa thông tin cá nhân
2. **Change Avatar** - Tải ảnh avatar từ thư viện
3. **Change Password** - Đổi mật khẩu
4. **Settings** - Cài đặt ứng dụng (ngôn ngữ, theme, notification)
5. **Account Statistics** - Thống kê học tập
6. **Achievements** - Huy hiệu và thành tích
7. **Theme Switcher** - Đổi theme (light/dark mode)
8. **Language Switcher** - Đổi ngôn ngữ (VN/EN)

## 📝 Code Structure

```
lib/
├── screens/
│   ├── profile_screen.dart    ← Profile UI & Logic
│   ├── main_screen.dart        ← Updated with Profile tab
│   └── login_screen.dart       ← Destination after logout
├── utils/
│   └── auth.dart              ← Auth.logout() method
└── Models/
    └── User.dart              ← User model
```

## 🎉 Kết luận

Bây giờ app của bạn có:
- ✅ Trang Profile đầy đủ thông tin
- ✅ Avatar tự động generate từ tên
- ✅ Info cards đẹp mắt
- ✅ Nút đăng xuất với confirmation
- ✅ Loading và error handling
- ✅ Navigation mượt mà
- ✅ UI/UX chuyên nghiệp

**Giờ user có thể xem thông tin cá nhân và đăng xuất một cách an toàn!** 🚀

---

**Happy Coding! 💻✨**
