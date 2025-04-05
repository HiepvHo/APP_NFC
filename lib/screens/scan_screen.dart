import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' as io;
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
  bool isProcessingImage = false;
  dynamic _capturedImage;
  List<WordData> wordList = [];
  final Testapi _api = Testapi();
  bool _mounted = true;
  String _errorMessage = '';

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
      final detectedWord = WordData(
        id: 0, // ID tạm thời
        en: result['english'] as String,
        vn: result['vietnamese'] as String,
        image: result['image'] as String,
        audioEn: result['englishAudio'] as String,
        audioVn: result['vietnameseAudio'] as String,
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

  Future<void> _captureImage() async {
    setState(() {
      _errorMessage = '';
    });

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null && _mounted) {
      setState(() {
        _capturedImage = kIsWeb ? pickedFile : io.File(pickedFile.path);
        isProcessingImage = true;
        scannedWord = '';
        matchedWord = null;
      });

      try {
        var request = http.MultipartRequest('POST',
            Uri.parse('https://05ca-35-227-97-23.ngrok-free.app/predict'));

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
              ElevatedButton(
                onPressed: isProcessingImage ? null : _captureImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 156, 107, 75),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: Text(
                  isProcessingImage ? 'Đang xử lý...' : 'Chụp ảnh',
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
