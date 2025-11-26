// ============================================================================
// FILE: verify_code_screen.dart
// MÔ TẢ: Màn hình xác thực OTP - Bước 2 của flow reset password
// CHỨC NĂNG:
//   - Nhập mã OTP 6 chữ số (nhận qua email)
//   - Xác thực OTP với database
//   - Countdown timer (5 phút) - hết hạn thì OTP không còn hợp lệ
//   - Resend OTP nếu chưa nhận được
//   - Chuyển sang ResetPasswordScreen khi verify thành công
// PROPS: email (String) - Email của user đang reset password
// FLOW: ForgotPassword -> VerifyCode -> ResetPassword -> Login
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nfc_01/screens/reset_password_screen.dart';
import '../utils/auth.dart';

/// ===== CLASS: VerifyCodeScreen =====
/// Màn hình xác thực OTP - Nhập mã 6 chữ số
class VerifyCodeScreen extends StatefulWidget {
  final String email;  // Email user đang reset password

  const VerifyCodeScreen({super.key, required this.email});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );
  bool _isLoading = false;
  bool _canResend = false;
  int _countdown = 60;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  /// Đếm ngược thời gian để gửi lại mã
  void _startCountdown() {
    setState(() {
      _canResend = false;
      _countdown = 60;
    });

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      
      setState(() {
        _countdown--;
      });

      if (_countdown <= 0) {
        setState(() {
          _canResend = true;
        });
        return false;
      }
      return true;
    });
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

  /// Xác thực mã OTP
  Future<void> _verifyCode() async {
    // Lấy mã OTP từ 6 ô input
    String otp = _controllers.map((c) => c.text).join();

    if (otp.length != 6) {
      _showMessage('Vui lòng nhập đủ 6 chữ số', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Gọi API xác thực OTP
      var result = await Auth.verifyResetCode(widget.email, otp);

      if (!mounted) return;

      if (result['success']) {
        _showMessage(result['message']);

        // Chờ 0.5 giây rồi chuyển sang màn hình đổi mật khẩu
        await Future.delayed(const Duration(milliseconds: 500));

        if (!mounted) return;

        // Chuyển sang ResetPasswordScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordScreen(
              email: widget.email,
              otp: otp,
            ),
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

  /// Gửi lại mã OTP
  Future<void> _resendCode() async {
    if (!_canResend) return;

    setState(() {
      _isLoading = true;
    });

    try {
      var result = await Auth.sendResetCode(widget.email);

      if (!mounted) return;

      if (result['success']) {
        _showMessage('Đã gửi lại mã xác thực!');
        _startCountdown();
        
        // Xóa các ô input
        for (var controller in _controllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();
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
        title: const Text('Xác thực OTP'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icon
                Icon(
                  Icons.mail_lock,
                  size: 100,
                  color: Colors.blue.shade300,
                ),
                const SizedBox(height: 32),

                // Tiêu đề
                Text(
                  'Nhập mã xác thực',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                ),
                const SizedBox(height: 16),

                // Mô tả
                Text(
                  'Mã xác thực đã được gửi đến',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.email,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 32),

                // 6 ô nhập OTP
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 50,
                      child: TextFormField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Colors.blue, width: 2),
                          ),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 5) {
                            // Chuyển sang ô tiếp theo
                            _focusNodes[index + 1].requestFocus();
                          } else if (value.isEmpty && index > 0) {
                            // Quay lại ô trước
                            _focusNodes[index - 1].requestFocus();
                          }

                          // Tự động xác thực khi nhập đủ 6 số
                          if (index == 5 && value.isNotEmpty) {
                            _verifyCode();
                          }
                        },
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 32),

                // Nút xác thực
                ElevatedButton(
                  onPressed: _isLoading ? null : _verifyCode,
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
                          'Xác thực',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 16),

                // Gửi lại mã
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Không nhận được mã? ',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    TextButton(
                      onPressed: _canResend && !_isLoading ? _resendCode : null,
                      child: Text(
                        _canResend
                            ? 'Gửi lại'
                            : 'Gửi lại ($_countdown giây)',
                        style: TextStyle(
                          color: _canResend ? Colors.blue : Colors.grey,
                          fontWeight: FontWeight.bold,
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
    );
  }
}
