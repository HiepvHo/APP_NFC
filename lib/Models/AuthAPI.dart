import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../Models/User.dart';
import '../utils/email_service.dart';

/// Service xử lý Authentication với MongoDB trực tiếp
class AuthAPI {
  Db? _db;
  DbCollection? _userCollection;

  // MongoDB connection URI - Giống với connection của WordData
  final String mongoUri =
      'mongodb+srv://hvhhhta1:mPYTbvj5cOolUUWf@hiep.lezxu.mongodb.net/nfc_words?retryWrites=true&w=majority&appName=Hiep';

  // Key để lưu token trong SharedPreferences
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  /// Khởi tạo kết nối MongoDB
  Future<void> _initMongoDB() async {
    if (_db == null || !(_db?.isConnected ?? false)) {
      try {
        _db = await Db.create(mongoUri);
        await _db?.open();
        _userCollection = _db?.collection('users'); // Collection users
        debugPrint('MongoDB connected successfully for AuthAPI');
      } catch (e) {
        debugPrint('MongoDB connection error in AuthAPI: $e');
        throw Exception('Failed to connect to MongoDB');
      }
    }
  }

  /// Hash mật khẩu bằng SHA256
  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Tạo token đơn giản (trong thực tế nên dùng JWT)
  String _generateToken(String userId) {
    var timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    var data = '$userId:$timestamp';
    var bytes = utf8.encode(data);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Đăng ký user mới
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      await _initMongoDB();

      if (_userCollection == null) {
        throw Exception('User collection not initialized');
      }

      // Kiểm tra email đã tồn tại chưa
      var existingEmail = await _userCollection!.findOne(where.eq('email', email));
      if (existingEmail != null) {
        return {
          'success': false,
          'message': 'Email đã được đăng ký!',
        };
      }

      // Kiểm tra username đã tồn tại chưa
      var existingUsername = await _userCollection!.findOne(where.eq('username', username));
      if (existingUsername != null) {
        return {
          'success': false,
          'message': 'Tên đăng nhập đã tồn tại!',
        };
      }

      // Tạo user mới
      var userId = ObjectId();
      var hashedPassword = _hashPassword(password);
      
      var newUser = {
        '_id': userId,
        'username': username,
        'email': email,
        'password': hashedPassword,
        if (fullName != null && fullName.isNotEmpty) 'fullName': fullName,
        'createdAt': DateTime.now().toIso8601String(),
      };

      // Lưu vào database
      await _userCollection!.insert(newUser);

      // Tạo User object (không bao gồm password)
      var user = User(
        id: userId.toHexString(),
        username: username,
        email: email,
        fullName: fullName,
        createdAt: DateTime.now(),
      );

      // KHÔNG tự động đăng nhập - user phải đăng nhập thủ công
      return {
        'success': true,
        'message': 'Đăng ký thành công! Vui lòng đăng nhập.',
        'user': user,
      };
    } catch (e) {
      debugPrint('Error in register: $e');
      return {
        'success': false,
        'message': 'Lỗi khi đăng ký: ${e.toString()}',
      };
    }
  }

  /// Đăng nhập
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      await _initMongoDB();

      if (_userCollection == null) {
        throw Exception('User collection not initialized');
      }

      // Tìm user theo email
      var userDoc = await _userCollection!.findOne(where.eq('email', email));

      if (userDoc == null) {
        return {
          'success': false,
          'message': 'Email không tồn tại!',
        };
      }

      // Kiểm tra mật khẩu
      var hashedPassword = _hashPassword(password);
      if (userDoc['password'] != hashedPassword) {
        return {
          'success': false,
          'message': 'Mật khẩu không đúng!',
        };
      }

      // Tạo token
      var userId = userDoc['_id'].toHexString();
      var token = _generateToken(userId);

      // Lưu token
      await _saveToken(token);

      // Tạo User object (không bao gồm password)
      var user = User(
        id: userId,
        username: userDoc['username'],
        email: userDoc['email'],
        fullName: userDoc['fullName'],
        createdAt: userDoc['createdAt'] != null
            ? DateTime.parse(userDoc['createdAt'])
            : null,
      );

      await _saveUserData(user);

      return {
        'success': true,
        'message': 'Đăng nhập thành công!',
        'user': user,
        'token': token,
      };
    } catch (e) {
      debugPrint('Error in login: $e');
      return {
        'success': false,
        'message': 'Lỗi khi đăng nhập: ${e.toString()}',
      };
    }
  }

  /// Lưu token vào SharedPreferences
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  /// Lấy token từ SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  /// Lưu thông tin user vào SharedPreferences
  Future<void> _saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userKey, json.encode(user.toJson()));
  }

  /// Lấy thông tin user từ SharedPreferences
  Future<User?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(userKey);
    if (userData != null) {
      return User.fromJson(json.decode(userData));
    }
    return null;
  }

  /// Kiểm tra xem user đã đăng nhập chưa
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Đăng xuất - Xóa token và thông tin user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
    await prefs.remove(userKey);
  }

  /// Đóng kết nối MongoDB khi không sử dụng
  Future<void> dispose() async {
    if (_db != null && _db!.isConnected) {
      await _db!.close();
    }
  }

  // ==================== QUÊN MẬT KHẨU ====================
  
  /// Lưu mã OTP và thời gian hết hạn vào bộ nhớ tạm
  static final Map<String, Map<String, dynamic>> _otpStorage = {};
  
  /// Gửi mã xác thực đến email
  Future<Map<String, dynamic>> sendResetCode(String email) async {
    try {
      await _initMongoDB();

      // Kiểm tra email có tồn tại trong database không
      var userDoc = await _userCollection!.findOne(where.eq('email', email));
      
      if (userDoc == null) {
        return {
          'success': false,
          'message': 'Email không tồn tại trong hệ thống!',
        };
      }

      // Gửi email thực tế với EmailService
      final otp = await EmailService.sendResetCode(email);
      
      if (otp == null) {
        return {
          'success': false,
          'message': 'Không thể gửi email. Vui lòng kiểm tra cấu hình email!',
        };
      }
      
      // Lưu OTP và thời gian hết hạn (10 phút)
      _otpStorage[email] = {
        'otp': otp,
        'expiry': DateTime.now().add(const Duration(minutes: 10)),
      };
      
      // Debug log (có thể bỏ trong production)
      debugPrint('OTP sent to $email: $otp');

      return {
        'success': true,
        'message': 'Mã xác thực đã được gửi đến email của bạn!',
      };
    } catch (e) {
      debugPrint('Error in sendResetCode: $e');
      return {
        'success': false,
        'message': 'Lỗi khi gửi mã xác thực: ${e.toString()}',
      };
    }
  }
  
  /// Xác thực mã OTP
  Future<Map<String, dynamic>> verifyResetCode(String email, String otp) async {
    try {
      // Kiểm tra xem có OTP cho email này không
      if (!_otpStorage.containsKey(email)) {
        return {
          'success': false,
          'message': 'Không tìm thấy mã xác thực. Vui lòng yêu cầu gửi lại!',
        };
      }
      
      var otpData = _otpStorage[email]!;
      
      // Kiểm tra thời gian hết hạn
      if (DateTime.now().isAfter(otpData['expiry'])) {
        _otpStorage.remove(email); // Xóa OTP đã hết hạn
        return {
          'success': false,
          'message': 'Mã xác thực đã hết hạn. Vui lòng yêu cầu gửi lại!',
        };
      }
      
      // Kiểm tra mã OTP
      if (otpData['otp'] != otp) {
        return {
          'success': false,
          'message': 'Mã xác thực không đúng!',
        };
      }
      
      return {
        'success': true,
        'message': 'Xác thực thành công!',
      };
    } catch (e) {
      debugPrint('Error in verifyResetCode: $e');
      return {
        'success': false,
        'message': 'Lỗi khi xác thực: ${e.toString()}',
      };
    }
  }
  
  /// Đặt lại mật khẩu mới
  Future<Map<String, dynamic>> resetPassword(
    String email,
    String otp,
    String newPassword,
  ) async {
    try {
      await _initMongoDB();

      // Xác thực OTP trước
      var verifyResult = await verifyResetCode(email, otp);
      if (!verifyResult['success']) {
        return verifyResult;
      }

      // Hash mật khẩu mới
      var hashedPassword = _hashPassword(newPassword);

      // Cập nhật mật khẩu trong database
      var result = await _userCollection!.update(
        where.eq('email', email),
        modify.set('password', hashedPassword),
      );

      if (result['nModified'] == 0 && result['n'] == 0) {
        return {
          'success': false,
          'message': 'Không thể cập nhật mật khẩu!',
        };
      }

      // Xóa OTP sau khi đổi mật khẩu thành công
      _otpStorage.remove(email);

      return {
        'success': true,
        'message': 'Đổi mật khẩu thành công! Vui lòng đăng nhập lại.',
      };
    } catch (e) {
      debugPrint('Error in resetPassword: $e');
      return {
        'success': false,
        'message': 'Lỗi khi đổi mật khẩu: ${e.toString()}',
      };
    }
  }
}
