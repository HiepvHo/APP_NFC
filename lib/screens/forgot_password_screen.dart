// ============================================================================
// FILE: forgot_password_screen.dart
// MÔ TẢ: Màn hình quên mật khẩu - Bước 1 của flow reset password
// CHỨC NĂNG:
//   - Nhập email để nhận mã OTP
//   - Validate email tồn tại trong database
//   - Tạo mã OTP 6 chữ số ngẫu nhiên
//   - Gửi OTP qua email (SMTP)
//   - Lưu OTP vào DB với expiry time (5 phút)
//   - Chuyển sang VerifyCodeScreen
// FLOW: ForgotPassword -> VerifyCode -> ResetPassword -> Login
// ============================================================================

import 'package:flutter/material.dart';
import 'package:nfc_01/screens/verify_code_screen.dart';
import '../utils/auth.dart';

/// ===== CLASS: ForgotPasswordScreen =====
/// Màn hình quên mật khẩu - Nhập email để nhận mã xác thực
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// Hiển thị thông báo SnackBar
  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Gửi mã xác thực đến email
  Future<void> _sendResetCode() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String email = _emailController.text.trim();
      
      // Gọi API gửi mã xác thực
      var result = await Auth.sendResetCode(email);

      if (!mounted) return;

      if (result['success']) {
        _showMessage(result['message']);
        
        // Chờ 1 giây rồi chuyển sang màn hình nhập OTP
        await Future.delayed(const Duration(seconds: 1));
        
        if (!mounted) return;
        
        // Chuyển sang VerifyCodeScreen và truyền email
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyCodeScreen(email: email),
          ),
        );
      } else {
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
      appBar: AppBar(
        title: const Text('Quên mật khẩu'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
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
                  // Icon
                  Icon(
                    Icons.lock_reset,
                    size: 100,
                    color: Colors.blue.shade300,
                  ),
                  const SizedBox(height: 32),

                  // Tiêu đề
                  Text(
                    'Đặt lại mật khẩu',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                  ),
                  const SizedBox(height: 16),

                  // Mô tả
                  Text(
                    'Nhập email của bạn để nhận mã xác thực',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 32),

                  // Email field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Nhập email của bạn',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Email không hợp lệ';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Nút gửi mã
                  ElevatedButton(
                    onPressed: _isLoading ? null : _sendResetCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Gửi mã xác thực',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Quay lại đăng nhập
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Quay lại đăng nhập',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
