// ============================================================================
// FILE: write_screen.dart
// MÔ TẢ: Màn hình ghi dữ liệu vào thẻ NFC
// CHỨC NĂNG:
//   - Hiển thị danh sách từ vựng có thể chọn
//   - Chọn từ vựng muốn ghi
//   - Ghi thông tin vào thẻ NFC theo format NDEF
//   - Hiển thị trạng thái ghi (đang ghi, thành công, thất bại)
//   - Xác nhận ghi thành công với dialog
// FORMAT GHI: "EN:english|VN:vietnamese|IMG:imagePath"
// ============================================================================

import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import '../Models/WordData.dart';
import '../Models/API.dart';
import '../widgets/word_display.dart';

/// ===== CLASS: WriteScreen =====
/// Màn hình ghi từ vựng vào thẻ NFC
class WriteScreen extends StatefulWidget {
  const WriteScreen({super.key});

  @override
  State<WriteScreen> createState() => _WriteScreenState();
}

class _WriteScreenState extends State<WriteScreen> {
  List<WordData> wordList = [];  // Danh sách từ có thể ghi
  final Testapi _api = Testapi();
  bool _mounted = true;
  bool _isLoading = true;
  bool _isWriting = false;
  WordData? selectedWord;

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

  void _selectWord(WordData word) {
    setState(() {
      selectedWord = word;
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

  /// Ghi từ vựng vào thẻ NFC
  Future<void> _writeToNFC() async {
    if (selectedWord == null) {
      _showMessage('Vui lòng chọn một từ trước!', isError: true);
      return;
    }

    setState(() {
      _isWriting = true;
    });

    try {
      // Kiểm tra NFC có khả dụng không
      bool isAvailable = await NfcManager.instance.isAvailable();
      if (!isAvailable) {
        _showMessage('NFC không khả dụng trên thiết bị này!', isError: true);
        setState(() {
          _isWriting = false;
        });
        return;
      }

      // Tạo dữ liệu để ghi
      // Format: "EN:english|VN:vietnamese|IMG:imagePath"
      String dataToWrite = 'EN:${selectedWord!.en}|VN:${selectedWord!.vn}|IMG:${selectedWord!.image}';

      _showMessage('Đang chờ thẻ NFC... Vui lòng đưa thẻ lại gần!');

      // Bắt đầu session ghi NFC
      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          try {
            var ndef = Ndef.from(tag);

            if (ndef == null) {
              _showMessage('Thẻ không hỗ trợ NDEF!', isError: true);
              await NfcManager.instance.stopSession(
                errorMessage: 'Thẻ không hỗ trợ NDEF',
              );
              return;
            }

            if (!ndef.isWritable) {
              _showMessage('Thẻ NFC này không thể ghi!', isError: true);
              await NfcManager.instance.stopSession(
                errorMessage: 'Thẻ không thể ghi',
              );
              return;
            }

            // Kiểm tra dung lượng thẻ
            int dataSize = dataToWrite.length;
            int maxSize = ndef.maxSize;
            
            if (dataSize > maxSize) {
              _showMessage(
                'Dữ liệu quá lớn! ($dataSize bytes > $maxSize bytes)',
                isError: true,
              );
              await NfcManager.instance.stopSession(
                errorMessage: 'Dữ liệu quá lớn',
              );
              return;
            }

            // Tạo NDEF message
            NdefMessage message = NdefMessage([
              NdefRecord.createText(dataToWrite),
            ]);

            // Ghi vào thẻ
            await ndef.write(message);

            _showMessage('✅ Ghi thành công từ "${selectedWord!.en}"!');
            
            await NfcManager.instance.stopSession();
            
            if (mounted) {
              setState(() {
                selectedWord = null; // Reset selection
              });
            }
          } catch (e) {
            _showMessage('Lỗi khi ghi thẻ: $e', isError: true);
            await NfcManager.instance.stopSession(
              errorMessage: 'Lỗi: $e',
            );
          }
        },
      );
    } catch (e) {
      _showMessage('Lỗi: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isWriting = false;
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
            'Chọn từ để ghi',
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
          : Column(
              children: [
                if (selectedWord != null) ...[
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Từ đã chọn:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  WordDisplay(word: selectedWord!),
                  ElevatedButton(
                    onPressed: _isWriting ? null : _writeToNFC,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 156, 107, 75),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: _isWriting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Ghi vào thẻ NFC',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ],
                Expanded(
                  child: wordList.isEmpty
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
                            return GestureDetector(
                              onTap: () => _selectWord(wordList[index]),
                              child: Card(
                                color: selectedWord?.id == wordList[index].id
                                    ? Colors.pink[100]
                                    : Colors.white,
                                child: ListTile(
                                  title: Text(
                                    wordList[index].en!,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    wordList[index].vn!,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }
}
