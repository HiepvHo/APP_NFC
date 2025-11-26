// ============================================================================
// FILE: list_screen.dart
// MÔ TẢ: Màn hình danh sách tất cả từ vựng
// CHỨC NĂNG:
//   - Hiển thị ListView tất cả từ trong MongoDB
//   - Search/Filter từ vựng
//   - Tap vào item để xem chi tiết (WordDisplay widget)
//   - Pull to refresh để tải lại dữ liệu
//   - Loading state khi fetch data
// ============================================================================

import 'package:flutter/material.dart';
import '../Models/WordData.dart';
import '../Models/API.dart';
import '../widgets/word_display.dart';

/// ===== CLASS: ListScreen =====
/// Hiển thị danh sách từ vựng dạng list
class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  List<WordData> wordList = [];  // Danh sách từ vựng từ MongoDB
  final Testapi _api = Testapi();  // API instance
  bool _mounted = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadWords();
  }

  Future<void> loadWords() async {
    try {
      var words = await _api.fetchWordData();
      if (_mounted) {
        setState(() {
          wordList = words;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading words: $e');
      if (_mounted) {
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
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 160, 95, 41),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Danh sách từ vựng',
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
          : wordList.isEmpty
              ? const Center(
                  child: Text(
                    'Không có từ vựng',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: wordList.length,
                  itemBuilder: (context, index) {
                    return WordDisplay(word: wordList[index]);
                  },
                ),
    );
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }
}
