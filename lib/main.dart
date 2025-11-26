// ============================================================================
// FILE: main.dart
// MÔ TẢ: File chính của ứng dụng NFC - Điểm khởi đầu của toàn bộ app
// CHỨC NĂNG:
//   - Khởi tạo kết nối MongoDB và tải dữ liệu từ vựng
//   - Kiểm tra trạng thái đăng nhập của người dùng
//   - Điều hướng người dùng đến màn hình phù hợp (Login/Main)
//   - Hiển thị splash screen trong quá trình khởi tạo
// ============================================================================

import 'package:flutter/material.dart';
import 'package:nfc_01/screens/main_screen.dart';
import 'package:nfc_01/screens/login_screen.dart';
import 'package:nfc_01/Models/API.dart';
import 'package:nfc_01/utils/auth.dart';

/// ============================================================================
/// HÀM MAIN - ĐIỂM KHỞI ĐẦU CỦA ỨNG DỤNG
/// ============================================================================
/// Hàm main là điểm vào chính của ứng dụng Flutter
/// Được đánh dấu 'async' vì cần thực hiện các tác vụ bất đồng bộ
/// trước khi khởi chạy app (kết nối DB, tải dữ liệu)
/// ============================================================================
void main() async {
  // Đảm bảo Flutter framework được khởi tạo trước khi thực hiện các tác vụ async
  // Bắt buộc phải gọi khi sử dụng async trong main()
  WidgetsFlutterBinding.ensureInitialized();

  // ===== KHỞI TẠO KẾT NỐI MONGODB VÀ TẢI DỮ LIỆU =====
  // Tạo instance của API để kết nối với MongoDB Atlas
  final api = Testapi();
  
  try {
    // Tải dữ liệu từ vựng từ MongoDB trước khi app chạy
    // Điều này giúp app có dữ liệu sẵn sàng ngay khi người dùng vào
    await api.fetchWordData();
  } catch (e) {
    // Nếu kết nối thất bại, in lỗi ra console
    // App vẫn tiếp tục chạy, sẽ sử dụng dữ liệu cache (SharedPreferences)
    print('Error initializing MongoDB: $e');
  }

  // Khởi chạy ứng dụng Flutter với widget gốc là MyApp
  runApp(const MyApp());
}

/// ============================================================================
/// CLASS: MyApp
/// ============================================================================
/// Widget gốc của toàn bộ ứng dụng
/// Là StatelessWidget vì không cần quản lý state ở cấp độ này
/// ============================================================================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Tiêu đề ứng dụng (hiển thị khi switch apps trên Android/iOS)
      title: 'NFC App',
      
      // Cấu hình theme (giao diện) cho toàn bộ app
      theme: ThemeData(
        // Bảng màu chủ đạo dựa trên màu tím đậm
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        // Sử dụng Material Design 3 (phiên bản mới nhất)
        useMaterial3: true,
      ),
      
      // Màn hình đầu tiên khi mở app
      // AuthChecker sẽ kiểm tra đăng nhập và điều hướng phù hợp
      home: const AuthChecker(),
      
      // Ẩn banner "DEBUG" ở góc trên phải (chỉ hiện ở debug mode)
      debugShowCheckedModeBanner: false,
    );
  }
}

/// ============================================================================
/// CLASS: AuthChecker (StatefulWidget)
/// ============================================================================
/// Widget kiểm tra trạng thái đăng nhập khi khởi động app
/// 
/// LUỒNG HOẠT ĐỘNG:
/// 1. Hiển thị splash screen (màn hình chờ với logo và loading)
/// 2. Kiểm tra token đăng nhập trong SharedPreferences
/// 3. Điều hướng đến:
///    - MainScreen nếu đã đăng nhập (có token hợp lệ)
///    - LoginScreen nếu chưa đăng nhập (không có token)
/// 
/// LÝ DO SỬ DỤNG StatefulWidget:
/// - Cần initState() để tự động chạy kiểm tra khi widget được tạo
/// - Có thể cần setState() nếu muốn cập nhật UI (tùy chọn)
/// ============================================================================
class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

/// ============================================================================
/// CLASS: _AuthCheckerState
/// ============================================================================
/// State class cho AuthChecker widget
/// Quản lý logic kiểm tra authentication và navigation
/// ============================================================================
class _AuthCheckerState extends State<AuthChecker> {
  
  /// ========================================================================
  /// LIFECYCLE METHOD: initState()
  /// ========================================================================
  /// Được gọi tự động khi widget được tạo lần đầu tiên
  /// Đây là nơi tốt nhất để thực hiện các tác vụ khởi tạo một lần
  /// ========================================================================
  @override
  void initState() {
    super.initState();
    // Bắt đầu quá trình kiểm tra đăng nhập ngay khi widget được mount
    _checkLoginStatus();
  }

  /// ========================================================================
  /// METHOD: _checkLoginStatus()
  /// ========================================================================
  /// Kiểm tra trạng thái đăng nhập của user và điều hướng phù hợp
  /// 
  /// FLOW:
  /// 1. Delay 1 giây để người dùng thấy splash screen
  /// 2. Gọi Auth.isLoggedIn() để check token trong SharedPreferences
  /// 3. Điều hướng dựa trên kết quả:
  ///    - true: Đi đến MainScreen (đã có token)
  ///    - false: Đi đến LoginScreen (chưa có token hoặc token hết hạn)
  /// 
  /// LƯU Ý: 
  /// - Sử dụng mounted check để tránh setState() trên widget đã dispose
  /// - Sử dụng pushReplacement để xóa AuthChecker khỏi navigation stack
  /// ========================================================================
  Future<void> _checkLoginStatus() async {
    // Đợi 1 giây để hiển thị splash screen
    // Tạo trải nghiệm mượt mà, tránh chuyển màn hình quá nhanh
    await Future.delayed(const Duration(seconds: 1));
    
    // Kiểm tra xem widget còn trong cây widget không
    // Nếu user tắt app trong lúc delay, mounted = false
    if (!mounted) return;

    // Gọi Auth service để kiểm tra token trong SharedPreferences
    // Trả về true nếu có token hợp lệ, false nếu không
    final isLoggedIn = await Auth.isLoggedIn();
    
    // Kiểm tra mounted lần nữa sau khi await
    // Đảm bảo widget chưa bị dispose trong quá trình async
    if (!mounted) return;

    // ===== ĐIỀU HƯỚNG DỰA TRÊN TRẠNG THÁI ĐĂNG NHẬP =====
    if (isLoggedIn) {
      // ✅ ĐÃ ĐĂNG NHẬP
      // User có token hợp lệ -> Chuyển thẳng vào app
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      // ❌ CHƯA ĐĂNG NHẬP
      // Không có token hoặc token hết hạn -> Yêu cầu đăng nhập
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  /// ========================================================================
  /// METHOD: build()
  /// ========================================================================
  /// Xây dựng UI cho màn hình Splash Screen
  /// Hiển thị logo, tên app và loading indicator trong khi kiểm tra auth
  /// 
  /// THIẾT KẾ:
  /// - Background: Màu cam nhạt (#FFBAC1) - tone màu chính của app
  /// - Center content: Logo NFC + Tên app + Loading spinner
  /// - Màu sắc nhất quán: Nâu/cam đậm cho text và icon
  /// ========================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Màu nền chính của app (cam nhạt)
      backgroundColor: const Color(0xFFFFDAC1),
      
      body: Center(
        child: Column(
          // Căn giữa theo trục dọc
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ===== LOGO APP =====
            // Icon NFC đại diện cho chức năng chính của app
            const Icon(
              Icons.nfc,                              // Icon NFC từ Material Icons
              size: 100,                              // Kích thước lớn để nổi bật
              color: Color.fromARGB(255, 160, 95, 41), // Màu nâu/cam đậm
            ),
            
            // Khoảng cách giữa logo và text
            const SizedBox(height: 20),
            
            // ===== TÊN ỨNG DỤNG =====
            const Text(
              'NFC App',
              style: TextStyle(
                fontSize: 32,                          // Font size lớn
                fontWeight: FontWeight.bold,           // In đậm
                color: Color.fromARGB(255, 160, 95, 41), // Cùng màu với icon
              ),
            ),
            
            // Khoảng cách giữa text và loading indicator
            const SizedBox(height: 40),
            
            // ===== LOADING INDICATOR =====
            // Vòng tròn quay để báo hiệu app đang xử lý
            const CircularProgressIndicator(
              // Màu của vòng tròn loading (cùng tone màu app)
              valueColor: AlwaysStoppedAnimation<Color>(
                Color.fromARGB(255, 160, 95, 41),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// KẾT THÚC FILE main.dart
// ============================================================================
