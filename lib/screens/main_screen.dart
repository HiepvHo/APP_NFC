import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nfc_01/screens/list_screen.dart';
import 'package:nfc_01/screens/scan_screen.dart';
import 'package:nfc_01/screens/write_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'word_screen.dart';
import 'find_screen.dart';
import '../Models/WordData.dart';
import 'package:nfc_01/Models/API.dart';

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
      HomeScreen(), // Truyền dữ liệu vào màn hình
      ListScreen(),
      ScanScreen(),
      WordScreen(),
      FindScreen(),
      WriteScreen(),
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
