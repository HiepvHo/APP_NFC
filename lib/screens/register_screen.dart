// ============================================================================
// FILE: register_screen.dart
// MÔ TẢ: Màn hình đăng ký tài khoản mới
// CHỨC NĂNG:
//   - Đăng ký với username, email, password, fullname (optional)
//   - Validation đầy đủ (email format, password length, confirm password)
//   - Kiểm tra username/email unique trong database
//   - Hash password trước khi lưu (SHA-256)
//   - Tạo user mới trong MongoDB
//   - Chuyển về LoginScreen sau khi đăng ký thành công
// ============================================================================

import 'package:flutter/material.dart';
import 'package:nfc_01/screens/login_screen.dart';
import '../utils/auth.dart';

/// ===== CLASS: RegisterScreen =====
/// Màn hình đăng ký tài khoản mới
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Form key để validate form
  final _formKey = GlobalKey<FormState>();
  
  // Controllers để lấy dữ liệu từ TextField
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  
  // Biến trạng thái
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    // Giải phóng bộ nhớ khi widget bị hủy
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  /// Hiển thị SnackBar thông báo
  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Xử lý đăng ký
  Future<void> _handleRegister() async {
    // Validate form trước khi submit
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Gọi API đăng ký
      final result = await Auth.register(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim().isEmpty 
            ? null 
            : _fullNameController.text.trim(),
      );

      if (!mounted) return;

      if (result['success']) {
        // Đăng ký thành công
        _showMessage(result['message']);
        
        // Chờ 1.5 giây rồi chuyển sang LoginScreen
        await Future.delayed(const Duration(milliseconds: 1500));
        
        if (!mounted) return;
        
        // Chuyển sang LoginScreen và xóa tất cả route trước đó
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      } else {
        // Đăng ký thất bại
        _showMessage(result['message'], isError: true);
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Đã xảy ra lỗi: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFDAC1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color.fromARGB(255, 160, 95, 41),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo hoặc Icon app
                  const Icon(
                    Icons.person_add_outlined,
                    size: 80,
                    color: Color.fromARGB(255, 160, 95, 41),
                  ),
                  const SizedBox(height: 20),
                  
                  // Tiêu đề
                  const Text(
                    'Đăng ký',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 160, 95, 41),
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  const Text(
                    'Tạo tài khoản mới',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Username Field
                  _buildTextField(
                    controller: _usernameController,
                    label: 'Tên đăng nhập',
                    hint: 'username',
                    icon: Icons.person_outlined,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập tên đăng nhập';
                      }
                      if (value.trim().length < 3) {
                        return 'Tên đăng nhập phải có ít nhất 3 ký tự';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Full Name Field (Optional)
                  _buildTextField(
                    controller: _fullNameController,
                    label: 'Họ và tên (Tùy chọn)',
                    hint: 'Nguyễn Văn A',
                    icon: Icons.badge_outlined,
                  ),
                  const SizedBox(height: 16),
                  
                  // Email Field
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'example@email.com',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập email';
                      }
                      if (!Auth.isValidEmail(value.trim())) {
                        return 'Email không hợp lệ';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Password Field
                  _buildTextField(
                    controller: _passwordController,
                    label: 'Mật khẩu',
                    hint: 'Ít nhất 6 ký tự',
                    icon: Icons.lock_outlined,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập mật khẩu';
                      }
                      if (!Auth.isValidPassword(value)) {
                        return 'Mật khẩu phải có ít nhất 6 ký tự';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Confirm Password Field
                  _buildTextField(
                    controller: _confirmPasswordController,
                    label: 'Xác nhận mật khẩu',
                    hint: 'Nhập lại mật khẩu',
                    icon: Icons.lock_outlined,
                    obscureText: _obscureConfirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng xác nhận mật khẩu';
                      }
                      if (value != _passwordController.text) {
                        return 'Mật khẩu không khớp';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  
                  // Nút đăng ký
                  SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 156, 107, 75),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Đăng ký',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Chuyển về đăng nhập
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Đã có tài khoản? ',
                        style: TextStyle(fontSize: 16),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text(
                          'Đăng nhập',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 160, 95, 41),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Widget helper để build TextField với decoration đồng nhất
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          suffixIcon: suffixIcon,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: validator,
      ),
    );
  }
}
