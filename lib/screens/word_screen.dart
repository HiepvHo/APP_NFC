// ============================================================================
// FILE: word_screen.dart
// MÔ TẢ: Màn hình hiển thị chi tiết một từ vựng ngẫu nhiên
// CHỨC NĂNG:
//   - Chọn ngẫu nhiên 1 từ vựng từ MongoDB
//   - Hiển thị hình ảnh, text EN/VN
//   - Phát audio (tiếng Anh và tiếng Việt)
//   - Button "Next" để xem từ ngẫu nhiên khác
//   - Sử dụng WordDisplay widget để hiển thị
// ============================================================================

import 'dart:math';
import 'package:flutter/material.dart';
import '../Models/WordData.dart';
import '../Models/API.dart';
import '../widgets/word_display.dart';

/// ===== CLASS: WordScreen =====
/// Hiển thị từ vựng ngẫu nhiên với audio
class WordScreen extends StatefulWidget {
  const WordScreen({super.key});

  @override
  State<WordScreen> createState() => _WordScreenState();
}

class _WordScreenState extends State<WordScreen> {
  WordData? currentWord;  // Từ vựng hiện tại đang hiển thị
  List<WordData> wordList = [];
  final Testapi _api = Testapi();
  bool _mounted = true;
  List<WordData> options = [];
  bool showResult = false;
  bool? isCorrect;

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
          getNewQuestion();
        });
      }
    } catch (e) {
      print('Error loading words: $e');
    }
  }

  void getNewQuestion() {
    if (wordList.isEmpty) return;

    setState(() {
      showResult = false;
      isCorrect = null;

      // Chọn từ ngẫu nhiên làm đáp án đúng
      Random random = Random();
      currentWord = wordList[random.nextInt(wordList.length)];

      // Tạo danh sách các lựa chọn
      options = [currentWord!];

      // Thêm 3 lựa chọn sai ngẫu nhiên
      while (options.length < 4) {
        WordData randomWord = wordList[random.nextInt(wordList.length)];
        if (!options.contains(randomWord)) {
          options.add(randomWord);
        }
      }

      // Xáo trộn các lựa chọn
      options.shuffle();
    });
  }

  void checkAnswer(WordData selectedWord) {
    setState(() {
      showResult = true;
      isCorrect = selectedWord.id == currentWord?.id;
    });

    // Đợi 1.5 giây trước khi chuyển sang câu hỏi mới
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (_mounted) {
        getNewQuestion();
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
            'Chọn từ đúng',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: currentWord == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    WordDisplay(word: currentWord!),
                    const SizedBox(height: 20),
                    ...options.map((word) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: ElevatedButton(
                            onPressed:
                                showResult ? null : () => checkAnswer(word),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: showResult
                                  ? word.id == currentWord?.id
                                      ? Colors.green
                                      : Colors.red
                                  : Colors.pink[100],
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: Text(
                              word.vn!,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )),
                    if (showResult) ...[
                      const SizedBox(height: 20),
                      Icon(
                        isCorrect! ? Icons.check_circle : Icons.cancel,
                        color: isCorrect! ? Colors.green : Colors.red,
                        size: 60,
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }
}
