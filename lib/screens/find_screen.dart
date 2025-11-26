// ============================================================================
// FILE: find_screen.dart
// MÔ TẢ: Màn hình tìm kiếm từ vựng nâng cao
// CHỨC NĂNG:
//   - Search bar để tìm từ (theo EN hoặc VN)
//   - Realtime filter khi gõ
//   - Hiển thị kết quả search dạng list
//   - Tap vào item để xem chi tiết (WordDisplay)
//   - Clear search để reset
// ============================================================================

import 'package:flutter/material.dart';
import '../Models/WordData.dart';
import '../Models/API.dart';
import '../widgets/word_display.dart';

/// ===== CLASS: FindScreen =====
/// Tìm kiếm từ vựng với search bar
class FindScreen extends StatefulWidget {
  const FindScreen({super.key});

  @override
  State<FindScreen> createState() => _FindScreenState();
}

class _FindScreenState extends State<FindScreen> {
  List<WordData> wordList = [];        // Toàn bộ từ vựng
  List<WordData> filteredWords = [];   // Kết quả sau khi filter
  final Testapi _api = Testapi();
  bool _mounted = true;
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadWords();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> loadWords() async {
    try {
      var words = await _api.fetchWordData();
      if (_mounted) {
        setState(() {
          wordList = words;
          filteredWords = words;
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

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredWords = wordList;
      } else {
        filteredWords = wordList.where((word) {
          return word.en!.toLowerCase().contains(query) ||
              word.vn!.toLowerCase().contains(query);
        }).toList();
      }
    });
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
            'Tìm kiếm từ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Nhập từ cần tìm...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredWords.isEmpty
                    ? const Center(
                        child: Text(
                          'Không tìm thấy từ nào',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredWords.length,
                        itemBuilder: (context, index) {
                          return WordDisplay(word: filteredWords[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mounted = false;
    super.dispose();
  }
}
