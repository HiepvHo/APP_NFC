// ============================================================================
// FILE: profile_screen.dart
// MÔ TẢ: Màn hình hồ sơ người dùng
// CHỨC NĂNG:
//   - Hiển thị thông tin user (Avatar, Username, Email, Full Name)
//   - Thống kê học tập cá nhân (Words, Quizzes, Practice time)
//   - Settings menu (Đổi mật khẩu, Ngôn ngữ, Thông báo)
//   - Đăng xuất (Clear token và về LoginScreen)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:nfc_01/utils/auth.dart';
import 'package:nfc_01/screens/login_screen.dart';
import '../Models/User.dart';

/// ===== CLASS: ProfileScreen =====
/// Màn hình hiển thị thông tin người dùng và các tùy chọn
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Tải thông tin user từ SharedPreferences
  Future<void> _loadUserData() async {
    try {
      final user = await Auth.getUserData();
      if (mounted) {
        setState(() {
          _currentUser = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print('Error loading user data: $e');
    }
  }

  /// Hiển thị dialog xác nhận đăng xuất
  Future<void> _showLogoutDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Đăng xuất'),
          content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text(
                'Đăng xuất',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (result == true) {
      _handleLogout();
    }
  }

  /// Xử lý đăng xuất
  Future<void> _handleLogout() async {
    // Hiển thị loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Đăng xuất
      await Auth.logout();

      if (!mounted) return;

      // Đóng loading dialog
      Navigator.of(context).pop();

      // Chuyển về màn hình đăng nhập và xóa tất cả route trước đó
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );

      // Hiển thị thông báo
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã đăng xuất thành công!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      // Đóng loading dialog
      Navigator.of(context).pop();

      // Hiển thị lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi đăng xuất: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Lấy chữ cái đầu của tên để làm avatar
  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    } else {
      return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFDAC1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 160, 95, 41),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Hồ sơ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentUser == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Không thể tải thông tin người dùng',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadUserData,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Avatar và tên
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Avatar
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: const Color.fromARGB(255, 156, 107, 75),
                              child: Text(
                                _getInitials(_currentUser!.fullName ?? _currentUser!.username),
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Tên đầy đủ
                            Text(
                              _currentUser!.fullName ?? _currentUser!.username,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 160, 95, 41),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            
                            // Username
                            if (_currentUser!.fullName != null)
                              Text(
                                '@${_currentUser!.username}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Thông tin chi tiết
                      _buildInfoCard(
                        icon: Icons.email_outlined,
                        title: 'Email',
                        value: _currentUser!.email,
                      ),
                      const SizedBox(height: 12),
                      
                      _buildInfoCard(
                        icon: Icons.person_outline,
                        title: 'Tên đăng nhập',
                        value: _currentUser!.username,
                      ),
                      const SizedBox(height: 12),
                      
                      if (_currentUser!.createdAt != null)
                        _buildInfoCard(
                          icon: Icons.calendar_today_outlined,
                          title: 'Ngày tham gia',
                          value: _formatDate(_currentUser!.createdAt!),
                        ),
                      const SizedBox(height: 30),
                      
                      // Nút đăng xuất
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton.icon(
                          onPressed: _showLogoutDialog,
                          icon: const Icon(Icons.logout, color: Colors.white),
                          label: const Text(
                            'Đăng xuất',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Thông tin phiên bản app (optional)
                      Text(
                        'NFC App v1.0.0',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  /// Widget hiển thị thông tin dạng card
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFDAC1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: const Color.fromARGB(255, 160, 95, 41),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Format ngày tháng
  String _formatDate(DateTime date) {
    final months = [
      'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4',
      'Tháng 5', 'Tháng 6', 'Tháng 7', 'Tháng 8',
      'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12'
    ];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }
}
