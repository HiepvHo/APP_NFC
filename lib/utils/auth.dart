import '../Models/AuthAPI.dart';
import '../Models/User.dart';

/// Wrapper class cho AuthAPI để giữ tương thích với code cũ
/// Sử dụng MongoDB trực tiếp thay vì HTTP API
class Auth {
  static final AuthAPI _authAPI = AuthAPI();

  /// Đăng nhập
  /// Trả về Map với 'success' (bool) và 'message' (String)
  static Future<Map<String, dynamic>> login(String email, String password) async {
    return await _authAPI.login(email, password);
  }

  /// Đăng ký
  /// Trả về Map với 'success' (bool) và 'message' (String)
  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    String? fullName,
  }) async {
    return await _authAPI.register(
      username: username,
      email: email,
      password: password,
      fullName: fullName,
    );
  }

  /// Lấy token từ SharedPreferences
  static Future<String?> getToken() async {
    return await _authAPI.getToken();
  }

  /// Lấy thông tin user từ SharedPreferences
  static Future<User?> getUserData() async {
    return await _authAPI.getUserData();
  }

  /// Kiểm tra xem user đã đăng nhập chưa
  static Future<bool> isLoggedIn() async {
    return await _authAPI.isLoggedIn();
  }

  /// Đăng xuất - Xóa token và thông tin user
  static Future<void> logout() async {
    await _authAPI.logout();
  }

  /// Validate email format
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Validate password strength (ít nhất 6 ký tự)
  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  // ==================== QUÊN MẬT KHẨU ====================

  /// Gửi mã xác thực đến email
  static Future<Map<String, dynamic>> sendResetCode(String email) async {
    return await _authAPI.sendResetCode(email);
  }

  /// Xác thực mã OTP
  static Future<Map<String, dynamic>> verifyResetCode(
      String email, String otp) async {
    return await _authAPI.verifyResetCode(email, otp);
  }

  /// Đặt lại mật khẩu mới
  static Future<Map<String, dynamic>> resetPassword(
    String email,
    String otp,
    String newPassword,
  ) async {
    return await _authAPI.resetPassword(email, otp, newPassword);
  }
}
