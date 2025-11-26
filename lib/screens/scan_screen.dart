// ============================================================================
// FILE: scan_screen.dart
// MÔ TẢ: Màn hình quét NFC và nhận diện hình ảnh
// CHỨC NĂNG:
//   - Quét thẻ NFC (NDEF format): Đọc dữ liệu từ vựng từ thẻ
//   - Chụp ảnh: Mở camera để chụp đối tượng
//   - Chọn ảnh: Chọn từ thư viện
//   - AI Recognition: Gửi ảnh đến API nhận diện và trả về từ vựng
//   - Hiển thị WordData: Hình ảnh, text EN/VN, phát audio
// NFC FORMAT: "EN:english|VN:vietnamese|IMG:imagePath"
// ============================================================================

import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import '../Models/WordData.dart';
import '../Models/API.dart';
import '../widgets/word_display.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  String scannedWord = '';
  WordData? matchedWord;
  bool isScanning = false;
  bool isScanningNFC = false;
  bool isProcessingImage = false;
  List<WordData> wordList = [];
  final Testapi _api = Testapi();
  bool _mounted = true;
  String _errorMessage = '';
  String _nfcMessage = '';

  String _canonicalize(String s) {
    return s.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '');
  }

  String _assetAudioEn(String key) => 'assets/audio/en/$key.mp3';
  String _assetAudioVn(String key) => 'assets/audio/vn/$key.mp3';
  String _assetImage(String key) => 'assets/images/$key.jpg';

  String _ensureAssetPrefix(String path) {
    if (path.startsWith('http')) return path;
    return path.startsWith('assets/') ? path : 'assets/$path';
  }
 
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
        });
      }
    } catch (e) {
      print('Error loading words: $e');
    }
  }

  void _processAPIResponse(Map<String, dynamic> result) {
    if (!_mounted) return;

    try {
      // Tạo WordData mới từ response API
      final enRaw = (result['english'] as String?) ?? '';
      final vnRaw = (result['vietnamese'] as String?) ?? '';
      final imgRaw = (result['image'] as String?) ?? '';
      final enAudioRaw = (result['englishAudio'] as String?) ?? '';
      final vnAudioRaw = (result['vietnameseAudio'] as String?) ?? '';
      final canonical = _canonicalize(enRaw);

      final detectedWord = WordData(
        id: 0, // ID tạm thời
        en: enRaw,
        vn: vnRaw,
        image: imgRaw.isNotEmpty ? _ensureAssetPrefix(imgRaw) : _assetImage(canonical),
        audioEn: enAudioRaw.isNotEmpty ? _ensureAssetPrefix(enAudioRaw) : _assetAudioEn(canonical),
        audioVn: vnAudioRaw.isNotEmpty ? _ensureAssetPrefix(vnAudioRaw) : _assetAudioVn(canonical),
      );

      setState(() {
        matchedWord = detectedWord;
        scannedWord = detectedWord.vn!;
        isProcessingImage = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi xử lý dữ liệu: $e';
        isProcessingImage = false;
      });
    }
  }

  /// Quét thẻ NFC để đọc từ vựng
  Future<void> _scanNFC() async {
    setState(() {
      _errorMessage = '';
      _nfcMessage = '';
      isScanningNFC = true;
      matchedWord = null;
    });

    try {
      // Kiểm tra NFC có khả dụng không
      bool isAvailable = await NfcManager.instance.isAvailable();
      if (!isAvailable) {
        setState(() {
          _errorMessage = 'NFC không khả dụng trên thiết bị này!';
          isScanningNFC = false;
        });
        return;
      }

      setState(() {
        _nfcMessage = 'Đang chờ thẻ NFC... Vui lòng đưa thẻ lại gần!';
      });

      // Bắt đầu session đọc NFC
      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          try {
            var ndef = Ndef.from(tag);

            if (ndef == null) {
              setState(() {
                _errorMessage = 'Thẻ không hỗ trợ NDEF!';
                _nfcMessage = '';
              });
              await NfcManager.instance.stopSession(
                errorMessage: 'Thẻ không hỗ trợ NDEF',
              );
              return;
            }

            // Đọc dữ liệu từ thẻ
            NdefMessage ndefMessage = await ndef.read();

            if (ndefMessage.records.isEmpty) {
              setState(() {
                _errorMessage = 'Thẻ NFC trống hoặc không có dữ liệu!';
                _nfcMessage = '';
              });
              await NfcManager.instance.stopSession(
                errorMessage: 'Thẻ trống',
              );
              return;
            }

            // Lấy text từ record đầu tiên
            String rawData = '';
            for (var record in ndefMessage.records) {
              if (record.typeNameFormat == NdefTypeNameFormat.nfcWellknown) {
                // Payload của text record có format: [language_code_length][language_code][text]
                // Byte đầu tiên là length của language code
                var payload = record.payload;
                if (payload.isNotEmpty) {
                  int languageCodeLength = payload[0] & 0x3F; // 6 bits thấp
                  int textStart = 1 + languageCodeLength;
                  if (textStart < payload.length) {
                    rawData = String.fromCharCodes(payload.sublist(textStart));
                  }
                }
              }
            }

            if (rawData.isEmpty) {
              setState(() {
                _errorMessage = 'Không đọc được dữ liệu từ thẻ!';
                _nfcMessage = '';
              });
              await NfcManager.instance.stopSession(
                errorMessage: 'Không có dữ liệu',
              );
              return;
            }

            // Parse dữ liệu: "EN:english|VN:vietnamese|IMG:imagePath"
            Map<String, String> parsedData = {};
            var parts = rawData.split('|');
            for (var part in parts) {
              var keyValue = part.split(':');
              if (keyValue.length == 2) {
                parsedData[keyValue[0]] = keyValue[1];
              }
            }

            if (parsedData.isEmpty || !parsedData.containsKey('EN')) {
              setState(() {
                _errorMessage = 'Dữ liệu thẻ không đúng định dạng!';
                _nfcMessage = '';
              });
              await NfcManager.instance.stopSession(
                errorMessage: 'Dữ liệu không hợp lệ',
              );
              return;
            }

            // Tìm từ trong database theo tên tiếng Anh (chuẩn hóa: loại khoảng trắng, chữ thường)
            String englishWordRaw = parsedData['EN']!;
            String englishWordCanonical = _canonicalize(englishWordRaw);

            WordData? foundWord = wordList.firstWhere(
              (word) => _canonicalize(word.en ?? '') == englishWordCanonical,
              orElse: () => WordData(
                id: 0,
                en: parsedData['EN'],
                vn: parsedData['VN'] ?? 'Không có dịch',
                image: (parsedData['IMG'] ?? '').isNotEmpty
                    ? _ensureAssetPrefix(parsedData['IMG']!)
                    : _assetImage(englishWordCanonical),
                audioEn: _assetAudioEn(englishWordCanonical),
                audioVn: _assetAudioVn(englishWordCanonical),
              ),
            );

            setState(() {
              matchedWord = foundWord;
              scannedWord = foundWord.en ?? '';
              _nfcMessage = '';
            });

            await NfcManager.instance.stopSession();
          } catch (e) {
            setState(() {
              _errorMessage = 'Lỗi khi đọc thẻ: $e';
              _nfcMessage = '';
            });
            await NfcManager.instance.stopSession(
              errorMessage: 'Lỗi: $e',
            );
          }
        },
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi: $e';
        _nfcMessage = '';
      });
    } finally {
      if (_mounted) {
        setState(() {
          isScanningNFC = false;
        });
      }
    }
  }

  Future<void> _captureImage() async {
    setState(() {
      _errorMessage = '';
      _nfcMessage = '';
    });

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null && _mounted) {
      setState(() {
        isProcessingImage = true;
        scannedWord = '';
        matchedWord = null;
      });

      try {
        var request = http.MultipartRequest('POST',
            Uri.parse('https://unmouthable-mitzi-overdiffusely.ngrok-free.dev/predict'));

        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          request.files.add(http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: 'image.jpg',
            contentType: MediaType('image', 'jpeg'),
          ));
        } else {
          request.files.add(await http.MultipartFile.fromPath(
            'file',
            pickedFile.path,
          ));
        }

        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        if (_mounted) {
          if (response.statusCode == 200) {
            final result = jsonDecode(response.body);
            print('API Response: $result'); // Debug log

            if (result != null) {
              _processAPIResponse(result);
            } else {
              setState(() {
                _errorMessage = 'Không nhận diện được quả trong hình';
                isProcessingImage = false;
              });
            }
          } else {
            throw Exception(
                'API Error: ${response.statusCode}\nBody: ${response.body}');
          }
        }
      } catch (e) {
        if (_mounted) {
          setState(() {
            _errorMessage = 'Lỗi xử lý ảnh: $e';
            isProcessingImage = false;
          });
        }
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
            'Nhận diện',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isProcessingImage)
                Column(
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Đang xử lý ảnh...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              else if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              else if (matchedWord != null)
                Column(
                  children: [
                    Text(
                      'Đã nhận diện: ${matchedWord!.vn}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 16),
                    WordDisplay(word: matchedWord!),
                  ],
                )
              else
                const Text(
                  'Chụp ảnh để nhận diện quả',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 24),
              // Hiển thị thông báo NFC nếu đang quét
              if (_nfcMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        _nfcMessage,
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              // Nút quét NFC
              ElevatedButton.icon(
                onPressed: isScanningNFC || isProcessingImage ? null : _scanNFC,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 41, 128, 160),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                icon: Icon(
                  isScanningNFC ? Icons.hourglass_empty : Icons.nfc,
                  color: Colors.white,
                ),
                label: Text(
                  isScanningNFC ? 'Đang quét NFC...' : 'Quét thẻ NFC',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Nút chụp ảnh
              ElevatedButton.icon(
                onPressed: isProcessingImage || isScanningNFC ? null : _captureImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 156, 107, 75),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                icon: Icon(
                  isProcessingImage ? Icons.hourglass_empty : Icons.camera_alt,
                  color: Colors.white,
                ),
                label: Text(
                  isProcessingImage ? 'Đang xử lý...' : 'Chụp ảnh nhận diện',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
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
