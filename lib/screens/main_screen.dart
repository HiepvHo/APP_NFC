// ============================================================================
// FILE: main_screen.dart
// MÔ TẢ: Màn hình chính với Bottom Navigation Bar
// CHỨC NĂNG:
//   - Quản lý navigation giữa 4 màn hình chính: Home, Scan, List, Profile
//   - Hiển thị Bottom Navigation Bar
//   - Giữ state của từng tab khi chuyển đổi
//   - Custom AppBar cho từng màn hình
// ============================================================================

import 'package:flutter/material.dart';
import 'package:nfc_01/screens/list_screen.dart';
import 'package:nfc_01/screens/scan_screen.dart';
import 'package:nfc_01/screens/write_screen.dart';
import 'package:nfc_01/screens/profile_screen.dart';
import 'home_screen.dart';
import 'word_screen.dart';
import 'find_screen.dart';
import '../Models/WordData.dart';
import 'package:nfc_01/Models/API.dart';

// ===== DANH SÁCH TỪ VỰNG MẪU =====
// Dữ liệu backup khi không kết nối được MongoDB
List<WordData> wordListReal = [
  WordData(
    id: 1,
    en: "banana",
    vn: "quả chuối",
    audioEn: "audio/en/banana.mp3",
    audioVn: "audio/vn/banana.mp3",
    image: "assets/images/banana.jpg",
  ),
  WordData(
    id: 2,
    en: "grape",
    vn: "quả nho",
    audioEn: "audio/en/grape.mp3",
    audioVn: "audio/vn/grape.mp3",
    image: "assets/images/grape.jpg",
  ),
  WordData(
    id: 3,
    en: "orange",
    vn: "quả cam",
    audioEn: "audio/en/orange.mp3",
    audioVn: "audio/vn/orange.mp3",
    image: "assets/images/orange.jpg",
  ),
  WordData(
    id: 4,
    en: "watermelon",
    vn: "quả dưa hấu",
    audioEn: "audio/en/watermelon.mp3",
    audioVn: "audio/vn/watermelon.mp3",
    image: "assets/images/watermelon.jpg",
  ),
];

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool isLoading = false;

  // List of screens
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    loadWords();

    _screens = [
      HomeScreen(), // Trang chủ
      ListScreen(), // Danh sách từ vựng
      ScanScreen(), // Nhận diện
      WordScreen(), // Chọn từ đúng
      FindScreen(), // Tìm kiếm
      WriteScreen(), // Ghi thẻ NFC
      ProfileScreen(), // Hồ sơ người dùng
    ];
  }

  Future<void> loadWords() async {
    Testapi testApi = Testapi();
    testApi.fetchWordData();
  }

  Color _getIconColor(int index) {
    return _currentIndex == index ? Colors.pink.shade300 : Colors.pink.shade300;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _screens[_currentIndex], // Render the selected screen
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Update the current index on tap
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: _getIconColor(0)), // Trang chủ
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt, color: _getIconColor(0)), // Trang chủ
            label: 'List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info,
                color: _getIconColor(1)), // Đọc & hiển thị thông tin thẻ
            label: 'Read',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz,
                color: _getIconColor(2)), // Trò chơi chọn đúng từ
            label: 'Choose',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_turned_in_outlined,
                color: _getIconColor(3)), // Trò chơi tìm thẻ
            label: 'Find',
          ),
          BottomNavigationBarItem(
            icon:
                Icon(Icons.edit, color: _getIconColor(4)), // Ghi thông tin thẻ
            label: 'Write',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: _getIconColor(5)), // Hồ sơ
            label: 'Profile',
          ),
        ],
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFFFFFFF),
        selectedItemColor: Colors.pink.shade300,
        unselectedItemColor: Colors.transparent,
        elevation: 10,
      ),
    );
  }
}
