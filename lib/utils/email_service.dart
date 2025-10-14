import 'dart:math';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

/// Service để gửi email xác thực
class EmailService {
  // Cấu hình Gmail SMTP
  // LÀM CHU Ý: Bạn cần tạo App Password từ Google Account
  // https://myaccount.google.com/apppasswords
  static const String _username = 'tk04052k4@gmail.com'; // Thay bằng email của bạn
  static const String _password = 'bxkamcwgatogndzl'; // Thay bằng App Password (BỎ HẾT DẤU CÁCH)

  /// Gửi mã xác thực đến email
  /// Returns: mã OTP 6 chữ số được gửi đi
  static Future<String?> sendResetCode(String recipientEmail) async {
    try {
      // Tạo mã OTP 6 chữ số ngẫu nhiên
      final otp = _generateOTP();
      
      // Cấu hình SMTP server của Gmail
      final smtpServer = gmail(_username, _password);
      
      // Tạo nội dung email
      final message = Message()
        ..from = Address(_username, 'NFC Words App')
        ..recipients.add(recipientEmail)
        ..subject = 'Mã xác thực đặt lại mật khẩu - NFC Words'
        ..html = '''
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <h2 style="color: #2196F3;">Đặt lại mật khẩu</h2>
            <p>Bạn đã yêu cầu đặt lại mật khẩu cho tài khoản NFC Words của mình.</p>
            <p>Mã xác thực của bạn là:</p>
            <div style="background-color: #f5f5f5; padding: 20px; text-align: center; border-radius: 8px; margin: 20px 0;">
              <h1 style="color: #2196F3; letter-spacing: 5px; margin: 0;">$otp</h1>
            </div>
            <p>Mã này sẽ hết hạn sau <strong>10 phút</strong>.</p>
            <p>Nếu bạn không yêu cầu đặt lại mật khẩu, vui lòng bỏ qua email này.</p>
            <hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;">
            <p style="color: #666; font-size: 12px;">Email này được gửi tự động, vui lòng không trả lời.</p>
          </div>
        ''';
      
      // Gửi email
      final sendReport = await send(message, smtpServer);
      print('Email sent: ${sendReport.toString()}');
      
      return otp;
    } catch (e) {
      print('Error sending email: $e');
      return null;
    }
  }
  
  /// Tạo mã OTP 6 chữ số ngẫu nhiên
  static String _generateOTP() {
    final random = Random();
    final otp = random.nextInt(900000) + 100000; // Tạo số từ 100000 đến 999999
    return otp.toString();
  }
  
  /// Kiểm tra email có hợp lệ không
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}
